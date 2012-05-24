require 'oculus/connection/mysql2'
require 'oculus/connection/postgres'

module Oculus
  module Connection
    class Error < StandardError; end
    class AdapterNotFound < Error; end

    def self.connect(options)
      case options[:adapter]
      when 'mysql'
        Mysql2
      when 'postgres', 'pg'
        Postgres
      else
        raise AdapterNotFound, "#{options[:adapter]} is not currently implemented. You should write it!"
      end.new(options)
    end
  end
end
