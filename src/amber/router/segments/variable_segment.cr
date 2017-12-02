module Amber::Router
  class VariableSegment(T) < Segment(T)
    def match?(segment : String) : Bool
      true
    end

    def parametric? : Bool
      true
    end

    def parameter : String
      segment[1..-1]
    end
  end
end
