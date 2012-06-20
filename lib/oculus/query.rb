require 'csv'

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
    attr_accessor :starred
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
        :starred     => starred,
        :thread_id   => thread_id
      }
      attrs[:error] = error if error
      attrs
    end

    def execute(connection)
      self.started_at = Time.now
      self.thread_id  = connection.thread_id
      self.save
      results = connection.execute(query)
    rescue Connection::Error => e
      error = e.message
    ensure
      reload
      self.results = results if results
      self.error   = error   if error
      self.finished_at = Time.now
      self.save
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

    def to_csv
      CSV.generate do |csv|
        results.each do |row|
          csv << row
        end
      end
    end

    class << self
      def create(attributes)
        query = new(attributes)
        query.save
        query
      end

      def find(id)
        new(Oculus.data_store.load_query(id))
      end
    end

    private

    def reload
      Oculus.data_store.load_query(id).each do |attr, value|
        send("#{attr}=", value)
      end
    end

  end
end
