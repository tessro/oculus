require 'sequel'
require 'csv'

module Oculus
  module Storage
    class SequelStore
      attr_reader :table_name

      def initialize(options = {})
        raise ArgumentError, "URI is required" unless options[:uri]
        @uri = options[:uri]
        @table_name = options[:table] || :oculus
        create_table
      end

      def with_db
        db = Sequel.connect(@uri, :encoding => 'utf8')
        result = yield db
        db.disconnect
        result
      end

      def with_table
        with_db { |db| yield db.from(@table_name) }
      end

      def all_queries
        with_table do |table|
          to_queries table.order(:id.desc)
        end
      end

      def starred_queries
        with_table do |table|
          to_queries table.where(:starred => true).order(:id.desc)
        end
      end

      def save_query(query)
        attrs = serialize(query)
        with_table do |table|
          if query.id
            table.where(:id => query.id).update(attrs)
          else
            query.id = table.insert(attrs)
          end
        end
      end

      def load_query(id)
        with_table do |table|
          if query = table.where(:id => id).first
            deserialize query
          else
            raise QueryNotFound, id
          end
        end
      end

      def delete_query(id)
        with_table do |table|
          raise ArgumentError unless id.to_i > 0
          raise QueryNotFound, id unless table.where(:id => id).delete == 1
        end
      end

      def create_table
        with_db do |db|
          db.create_table?(table_name) do
            primary_key :id
            Integer :thread_id
            String :name
            String :author
            String :query
            String :results
            Time :started_at
            Time :finished_at
            TrueClass :starred
            String :error
          end
        end
      end

      def drop_table
        with_db { |db| db.drop_table(table_name) }
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
