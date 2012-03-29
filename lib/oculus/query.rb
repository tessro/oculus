module Oculus
  class Query
    attr_accessor :id
    attr_accessor :description
    attr_accessor :author
    attr_accessor :query
    attr_accessor :results

    def initialize(attributes = {})
      attributes.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def attributes
      { :description => description,
        :author      => author,
        :query       => query }
    end

    class << self
      def create(attributes)
        new(attributes).tap do |query|
          Oculus.data_store.save_query(query)
        end
      end

      def find(id)
        Oculus.data_store.load_query(id)
      end
    end
  end
end
