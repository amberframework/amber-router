module Amber::Router
  class VariableSegment(T) < Segment(T)
    def initialize(segment, @pattern : Regex? = nil)
      super segment
    end

    def match?(segment : String) : Bool
      (p = @pattern) ? !(segment =~ p).nil? : true
    end

    def parametric? : Bool
      true
    end

    def parameter : String
      segment[1..-1]
    end
  end
end
