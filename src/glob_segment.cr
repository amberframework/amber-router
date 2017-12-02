module Amber::Router
  # Represents a "match anything" url segment.
  #
  # In the url `/products/:23/&lowast;`, the first segment, `&lowast;` is a glob segment.
  class GlobSegment(T) < Segment(T)
  end
end
