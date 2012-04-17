require 'sinatra/base'
require 'oculus'
require 'oculus/presenters'

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
      @queries = Oculus.data_store.all_queries.map { |q| Oculus::Presenters::QueryPresenter.new(q) }

      erb :index
    end

    post '/queries/:id/cancel' do
      query = Oculus::Query.find(params[:id])
      connection = Oculus::Connection::Mysql2.new(Oculus.connection_options)
      connection.execute("KILL QUERY #{query.thread_id}")
      [200, "OK"]
    end

    post '/queries' do
      connection = Oculus::Connection::Mysql2.new(Oculus.connection_options)
      query = Oculus::Query.create(:author      => params[:author],
                                   :description => params[:description],
                                   :query       => params[:query],
                                   :thread_id   => connection.thread_id)

      pid = fork do
        query.execute(connection)
        query.save
      end

      Process.detach(pid)

      redirect "/queries/#{query.id}/loading"
    end

    get '/queries/:id' do
      @query = Oculus::Presenters::QueryPresenter.new(Oculus::Query.find(params[:id]))

      @headers, *@results = @query.results

      erb :show
    end

    get '/queries/:id/loading' do
      @query = Oculus::Presenters::QueryPresenter.new(Oculus::Query.find(params[:id]))

      erb :loading
    end

    get '/queries/:id/ready' do
      Oculus::Query.find(params[:id]).complete?.to_s
    end

    delete '/queries/:id' do
      Oculus.data_store.delete_query(params[:id])
      puts "true"
    end
  end
end
