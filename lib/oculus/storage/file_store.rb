require 'yaml'
require 'csv'

module Oculus
  module Storage
    class FileStore
      def initialize(root)
        @root = root
      end

      def all_queries
        Dir["#{root}/*.query"].map do |path|
          File.parse(path)
        end.sort { |a,b| b.id <=> a.id }
      end

      def save_query(query)
        query.id = next_id if query.id.nil?

        File.open(filename_for_id(query.id), 'w') do |file|
          file.write_prelude(query.attributes)
          file.write_results(query.results) if query.results
        end
      end

      def load_query(id)
        path = filename_for_id(id)

        if File.exist?(path)
          File.parse(path)
        else
          raise QueryNotFound, id
        end
      end

      def delete_query(id)
        path = filename_for_id(id)

        if File.exist?(path)
          File.unlink(path)
        else
          raise QueryNotFound, id
        end
      end

      private

      class File < ::File
        def self.parse(path)
          file = File.open(path)
          attributes = file.attributes
          attributes[:results] = file.results
          Oculus::Query.new(attributes).tap do |query|
            query.id = File.basename(path).split('.').first.to_i
          end
        end

        def write_prelude(attributes)
          write(YAML.dump(attributes))
          puts("---")
        end

        def write_results(results)
          csv_data = CSV.generate do |csv|
            csv << results.first
            results[1..-1].each do |result|
              csv << result
            end
          end

          write csv_data
        end

        def attributes
          rewind

          raw = gets

          until (line = gets) == "---\n"
            raw += line
          end

          YAML.load(raw)
        end

        def results
          rewind

          section  = 0
          section += 1 if gets == "---\n" until section == 2

          CSV.new(read).to_a
        end
      end

      def filename_for_id(id)
        raise ArgumentError unless id.is_a?(Integer) || id =~ /^[0-9]+/
        File.join(root, "#{id}.query")
      end

      def next_id
        reset_primary_key unless File.exist?(primary_key_path)
        id_file = File.open(primary_key_path, 'r+')
        id_file.flock(File::LOCK_EX)

        id = id_file.read.to_i

        id_file.rewind
        id_file.write(id + 1)
        id_file.flock(File::LOCK_UN)
        id_file.close

        id
      end

      def reset_primary_key
        File.open(primary_key_path, 'w') do |file|
          file.puts '0'
        end
      end

      def primary_key_path
        File.join(root, 'NEXT_ID')
      end

      attr_reader :root
    end
  end
end
