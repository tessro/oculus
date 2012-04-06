require 'delegate'

module Oculus
  module Presenters
    class QueryPresenter < SimpleDelegator
      def formatted_date
        date.strftime("%Y-%m-%d %H:%M") if date
      end

      def status
        if ready?
          "done"
        else
          "loading"
        end
      end
    end
  end
end
