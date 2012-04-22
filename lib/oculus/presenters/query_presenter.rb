require 'delegate'

module Oculus
  module Presenters
    class QueryPresenter < SimpleDelegator
      def formatted_date
        date.strftime("%Y-%m-%d %H:%M") if date
      end

      def status
        if complete?
          if error
            "error"
          else
            "done"
          end
        else
          "loading"
        end
      end

      def description
        description = __getobj__.description
        if description && description != ""
          description
        else
          query = __getobj__.query
          if query.length > 100
            "#{query[0..97]}..."
          else
            query
          end
        end
      end
    end
  end
end
