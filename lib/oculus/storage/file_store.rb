require 'yaml'
require 'csv'

module Oculus
  module Storage
    class FileStore
      def initialize(root)
        @root = root
      end

      def all_queries
        Dir["#{root}/*.query"].map do |filename|
          yaml = ""
          File.open(filename) do |file|
            file.gets # discard header
            until (line = file.gets) == "---\n"
              yaml += line
            end
            YAML.parse(yaml)
          end
        end
      end

      def save_query(query)
        query.id = next_id

        File.open(filename_for_id(query.id), 'w') do |file|
          file.write_prelude(query.attributes)
          file.write_results(query.results)
        end
      end

      def load_query(id)
        path = filename_for_id(id)

        File.parse(path) if File.exist?(path)
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
        File.join(root, "#{id}.query")
      end

      def next_id
        id_file = File.open(File.join(root, 'NEXT_ID'), 'r+')
        id_file.flock(File::LOCK_EX)

        id = id_file.read.to_i

        id_file.rewind
        id_file.write(id + 1)
        id_file.flock(File::LOCK_UN)
        id_file.close

        id
      end

      attr_reader :root
    end
  end
end
