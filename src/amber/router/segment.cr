module Amber::Router
  abstract class Segment(T)
    def self.type_for(segment : String)
    end

    property route_set : RouteSet(T)
    property segment : String

    def initialize(@segment)
      @route_set = RouteSet(T).new(false)
    end

    def inspect(*, ts = 0)
      tab = "  " * ts
      String.build do |s|
        s << "#{tab}|--#{segment}"

        s << "\n"
        if route_set.routes?
          s << route_set.inspect ts: ts + 1
        end
      end
    end

    def match?(segment : String) : Bool
      @segment == segment
    end

    def to_s(i : IO)
      i << segment
    end
  end
end

require "./segments/terminal_segment"
require "./segments/fixed_segment"
require "./segments/variable_segment"
require "./segments/glob_segment"
