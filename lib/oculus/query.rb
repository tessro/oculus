module Oculus
  class Query
    attr_accessor :id
    attr_accessor :name
    attr_accessor :author
    attr_accessor :query
    attr_accessor :results
    attr_accessor :error
    attr_accessor :started_at
    attr_accessor :finished_at
    attr_accessor :thread_id

    def initialize(attributes = {})
      attributes.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def attributes
      attrs = {
        :name        => name,
        :author      => author,
        :query       => query,
        :started_at  => started_at,
        :finished_at => finished_at,
        :thread_id   => thread_id
      }
      attrs[:error] = error if error
      attrs
    end

    def execute(connection)
      self.started_at = Time.now
      self.results = connection.execute(query)
    rescue Connection::Error => e
      self.error = e.message
    ensure
      self.finished_at = Time.now
    end

    def save
      Oculus.data_store.save_query(self)
    end

    def complete?
      !!finished_at
    end

    def succeeded?
      complete? && !error
    end

    class << self
      def create(attributes)
        query = new(attributes)
        query.save
        query
      end

      def find(id)
        Oculus.data_store.load_query(id)
      end
    end
  end
end
