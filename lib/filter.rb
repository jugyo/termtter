module Termtter
  module Client
    @@filters = []

    class << self
      def add_filter(&filter)
        @@filters << filter
      end

      def clear_filters
        @@filters.clear
      end

      # memo: each filter must return Array of Status
      def apply_filters(statuses)
        filtered = statuses
        @@filters.each do |f|
          filtered = f.call(filtered)
        end
        filtered
      rescue => e
        puts "Error: #{e}"
        puts e.backtrace.join("\n")
        statuses
      end
    end
  end
end
