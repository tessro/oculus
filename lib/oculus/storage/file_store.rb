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
          Query.new(File.parse(path))
        end.sort { |a,b| b.id <=> a.id }
      end

      def starred_queries
        Dir["#{root}/starred/*.query"].map do |path|
          Query.new(File.parse(path))
        end.sort { |a,b| b.id <=> a.id }
      end

      def save_query(query)
        query.id = next_id if query.id.nil?

        File.open(filename_for_id(query.id), 'w') do |file|
          file.flock(File::LOCK_EX)
          file.write_prelude(query.attributes)
          file.write_results(query.results) if query.results && query.results.length > 0
          file.flock(File::LOCK_UN)
        end

        FileUtils.mkdir_p(File.join(root, "starred")) unless Dir.exist?(File.join(root, "starred"))
        star_path = starred_filename_for_id(query.id)

        if query.starred
          File.symlink(File.expand_path(filename_for_id(query.id)), star_path) unless File.exist?(star_path)
        elsif File.exist?(star_path)
          File.unlink(star_path)
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
        star_path = starred_filename_for_id(id)
        File.unlink(star_path) if File.exist?(star_path)

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

          file.flock(File::LOCK_EX)
          attributes = file.attributes
          attributes[:results] = file.results
          file.flock(File::LOCK_UN)

          attributes[:id] = File.basename(path).split('.').first.to_i
          attributes[:starred] ||= false
          attributes
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
          section += 1 if gets.rstrip == "---" until section == 2 || eof?

          CSV.new(read).to_a
        end
      end

      def starred_filename_for_id(id)
        raise ArgumentError unless id.is_a?(Integer) || id =~ /^[0-9]+/
        File.join(root, "starred", "#{id}.query")
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
