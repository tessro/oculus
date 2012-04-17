require 'mysql2'

module Oculus
  module Connection
    class Mysql2
      def initialize(options = {})
        @connection = ::Mysql2::Client.new(options)
      end

      def execute(sql)
        results = @connection.query(sql)
        [results.fields] + results.map(&:values)
      rescue ::Mysql2::Error => e
        raise Connection::Error.new(e.message)
      end

      def thread_id
        @connection.thread_id
      end
    end
  end
end
