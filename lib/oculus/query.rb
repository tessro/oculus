module Oculus
  class Query
    attr_accessor :id
    attr_accessor :description
    attr_accessor :query
    attr_accessor :results

    def initialize(attributes = {})
      attributes.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def attributes
      { :description => description,
        :query       => query }
    end

    class << self
      attr_accessor :data_store

      def create(attributes)
        new(attributes).tap do |query|
          data_store.save_query(query)
        end
      end

      def find(id)
        data_store.load_query(id)
      end
    end
  end
end
