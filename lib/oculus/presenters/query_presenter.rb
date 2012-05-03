require 'delegate'

module Oculus
  module Presenters
    class QueryPresenter < SimpleDelegator
      def formatted_start_time
        started_at.strftime("%Y-%m-%d %I:%M %p") if started_at
      end

      def formatted_finish_time
        finished_at.strftime("%Y-%m-%d %I:%M %p") if finished_at
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
        if name && name != ""
          name
        else
          query = self.query
          if query && query.length > 100
            "#{query[0..97]}..."
          else
            query
          end
        end
      end

      def named?
        !!name
      end
    end
  end
end
