module Oculus
  class Query
    attr_accessor :id
    attr_accessor :description
    attr_accessor :author
    attr_accessor :query
    attr_accessor :results
    attr_accessor :error
    attr_accessor :date
    attr_accessor :thread_id

    def initialize(attributes = {})
      attributes.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def attributes
      attrs = {
        :description => description,
        :author      => author,
        :query       => query,
        :date        => date,
        :thread_id   => thread_id
      }
      attrs[:error] = error if error
      attrs
    end

    def execute(connection)
      self.results = connection.execute(query)
    rescue Connection::Error => e
      self.error = e.message
    end

    def save
      @date = Time.now
      Oculus.data_store.save_query(self)
    end

    def complete?
      !!error || (!results.nil? && !results.empty?)
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
