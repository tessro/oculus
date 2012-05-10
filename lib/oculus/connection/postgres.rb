require 'pg'

module Oculus
  module Connection
    class Postgres
      def initialize(options = {})
        @connection = ::PG::Connection.new(options[:host],
                                           options[:port],
                                           nil, nil,
                                           options[:database],
                                           options[:username],
                                           options[:password])
      end

      def execute(sql)
        results = @connection.exec(sql)
        [results.fields] + results.values if results
      rescue ::PG::Error => e
        raise Connection::Error.new(e.message)
      end

      def kill(id)
        @connection.execute("SELECT pg_cancel_backend(#{id})")
      end

      def thread_id
        @connection.backend_pid
      end
    end
  end
end
