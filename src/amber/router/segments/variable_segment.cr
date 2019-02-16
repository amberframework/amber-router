module Amber::Router
  class VariableSegment(T) < Segment(T)
    def initialize(segment, @pattern : Regex? = nil)
      super segment
    end

    def match?(segment : String) : Bool
      if pattern = @pattern
        !(segment =~ pattern).nil?
      else
        true
      end
    end

    def parametric? : Bool
      true
    end

    def parameter : String
      if segment.starts_with?('{') && segment.ends_with?('}')
        segment.lchop('{').rchop('}')
      else
        segment.lchop(':')
      end
    end
  end
end
