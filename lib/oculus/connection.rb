module Oculus
  module Connection
    class Error < StandardError; end
    class AdapterNotFound < Error; end

    def self.connect(options)
      case options[:adapter]
      when 'mysql'
        require 'oculus/connection/mysql2'
        Mysql2
      when 'postgres', 'pg'
        require 'oculus/connection/postgres'
        Postgres
      else
        raise AdapterNotFound, "#{options[:adapter]} is not currently implemented. You should write it!"
      end.new(options)
    end
  end
end
