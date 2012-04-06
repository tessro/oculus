module Oculus
  class Query
    attr_accessor :id
    attr_accessor :description
    attr_accessor :author
    attr_accessor :query
    attr_accessor :results
    attr_accessor :date

    def initialize(attributes = {})
      attributes.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def attributes
      { :description => description,
        :author      => author,
        :query       => query,
        :date        => date }
    end

    def save
      @date = Time.now
      Oculus.data_store.save_query(self)
    end

    def ready?
      !results.nil? && !results.empty?
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
