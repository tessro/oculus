require 'sequel'
require 'csv'

module Oculus
  module Storage
    class SequelStore
      attr_reader :table, :table_name, :db

      def initialize(uri, options = {})
        @db = Sequel.connect(uri)
        @table_name = options[:table] || :oculus
        @table = @db.from(@table_name)
      end

      def all_queries
        to_queries table.order(:id.desc)
      end

      def starred_queries
        to_queries table.where(:starred => true).order(:id.desc)
      end

      def save_query(query)
        attrs = serialize(query)
        if query.id
          table.where(:id => query.id).update(attrs)
        else
          query.id = table.insert(attrs)
        end
      end

      def load_query(id)
        if query = table.where(:id => id).first
          deserialize query
        else
          raise QueryNotFound, id
        end
      end

      def delete_query(id)
        raise ArgumentError unless id.to_i > 0
        raise QueryNotFound, id unless table.where(:id => id).delete == 1
      end

      def create_table
        db.create_table?(table_name) do
          primary_key :id
          Integer :thread_id
          String :name
          String :author
          File :query
          File :results
          Time :started_at
          Time :finished_at
          TrueClass :starred
          String :error
        end
      end

      def drop_table
        db.drop_table(table_name)
      end

      private

      def to_queries(rows)
        rows.map { |r| Query.new deserialize(r) }
      end

      def deserialize(row)
        row[:results] = row[:results] ? CSV.new(row[:results]).to_a : []
        row.delete(:error) unless row[:error]
        row
      end

      def serialize(query)
        attrs = query.attributes
        attrs[:starred] ||= false
        attrs[:results] = query.to_csv if query.results
        attrs
      end
    end
  end
end
