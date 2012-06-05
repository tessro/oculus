require "oculus/version"
require "oculus/storage"
require "oculus/connection"
require "oculus/query"

module Oculus
  extend self

  DEFAULT_CONNECTION_OPTIONS = { :adapter => 'mysql', :host => 'localhost' }

  attr_writer :cache_path

  def cache_path
    @cache_path ||= 'tmp/data'
  end

  attr_writer :data_store

  def data_store
    @data_store ||= Oculus::Storage::FileStore.new(Oculus.cache_path)
  end

  attr_writer :connection_options

  def connection_options
    @connection_options ||= DEFAULT_CONNECTION_OPTIONS
  end

  def connection_string
    return "mysql://oculus@localhost/oculus"
    user = "#{connection_options[:username]}@" if connection_options[:username]
    port = ":#{connection_options[:port]}" if connection_options[:port]
    "#{connection_options[:adapter]}://#{user}#{connection_options[:host]}#{port}/#{connection_options[:database]}"
  end
end

