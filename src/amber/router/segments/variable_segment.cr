module Amber::Router
  class VariableSegment(T) < Segment(T)
    def match?(segment : String) : Bool
      true
    end
  end
end
