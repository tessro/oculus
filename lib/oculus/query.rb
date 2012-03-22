module Oculus
  class Query
    attr_reader :id
    attr_accessor :results

    def initialize(attributes = {})
      attributes.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    class << self
      attr_accessor :data_store

      def create(results)
        data_store.save_query(new)
      end

      def find(id)
        if attrs = data_store.find_query(id)
          new(attrs)
        end
      end
    end
  end
end
