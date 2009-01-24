module Termtter
  class Hook
    attr_accessor :name, :points, :exec_proc

    def initialize(args)
      raise ArgumentError, ":name is not given." unless args.has_key?(:name)
      @name = args[:name].to_sym
      @points = args[:points] ? args[:points].map {|i| i.to_sym } : []
      @exec_proc = args[:exec_proc] || proc {}
    end

    def match?(point)
      points.include?(point)
    end
  end
end
