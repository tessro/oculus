module Oculus
  module Storage
    class QueryNotFound < RuntimeError; end
    class AdapterNotFound < StandardError; end

    def self.create(options)
      case options[:adapter]
      when 'file'
        require 'oculus/storage/file_store'
        FileStore
      when 'sequel'
        require 'oculus/storage/sequel_store'
        SequelStore
      else
        raise AdapterNotFound, "#{options[:adapter]} is not currently implemented. You should write it!"
      end.new(options)
    end
  end
end
