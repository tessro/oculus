require 'sinatra/base'
require 'oculus'
require 'oculus/presenters'
require 'json'

module Oculus
  class Server < Sinatra::Base
    set :root, File.dirname(File.expand_path(__FILE__))

    set :static, true

    set :public_folder, Proc.new { File.join(root, "server", "public") }
    set :views,         Proc.new { File.join(root, "server", "views")  }

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    get '/' do
      erb :index
    end

    get '/history' do
      @queries = Oculus.data_store.all_queries.map { |q| Oculus::Presenters::QueryPresenter.new(q) }

      erb :history
    end

    post '/queries/:id/cancel' do
      query = Oculus::Query.find(params[:id])
      connection = Oculus::Connection::Mysql2.new(Oculus.connection_options)
      connection.execute("KILL QUERY #{query.thread_id}")
      [200, "OK"]
    end

    post '/queries' do
      connection = Oculus::Connection::Mysql2.new(Oculus.connection_options)
      query = Oculus::Query.create(:query     => params[:query],
                                   :thread_id => connection.thread_id)

      pid = fork do
        query.execute(connection)
        query.save
      end

      Process.detach(pid)

      [201, { :id => query.id }.to_json]
    end

    get '/queries/:id.json' do
      query = Oculus::Query.find(params[:id])

      if query.error
        { :error => query.error }
      else
        { :results => query.results }
      end.to_json
    end

    get '/queries/:id' do
      @query = Oculus::Presenters::QueryPresenter.new(Oculus::Query.find(params[:id]))

      @headers, *@results = @query.results

      erb :show
    end

    get '/queries/:id/status' do
      Oculus::Presenters::QueryPresenter.new(Oculus::Query.find(params[:id])).status
    end

    delete '/queries/:id' do
      Oculus.data_store.delete_query(params[:id])
      puts "true"
    end
  end
end
