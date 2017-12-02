module Amber::Router
  # Represents a "match anything" url segment.
  #
  # In the url `/products/:23/&lowast;`, the first segment, `&lowast;` is a glob segment.
  class GlobSegment(T) < Segment(T)
    def match?(segment : String)
      true
    end

    def parametric?
      parameter.size > 0
    end

    def parameter
      segment[1..-1]
    end
  end
end
