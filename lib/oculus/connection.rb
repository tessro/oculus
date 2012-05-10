require 'oculus/connection/mysql2'
require 'oculus/connection/postgres'

module Oculus
  module Connection
    class Error < StandardError; end

    def self.connect(options)
      case options[:adapter]
      when 'mysql'
        Mysql2
      when 'postgres', 'pg'
        Postgres
      end.new(options)
    end
  end
end
