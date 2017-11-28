require "./routed_result"

module Amber::Router
  class RouteSet(T)
    @trunk : RouteSet(T)?
    @route : T?

    property segment : String
    property segment_type = 0
    property full_path : String?

    ROOT = 1
    FIXED = 2
    VARIABLE = 4
    GLOB = 8

    # A tree data structure (recursive). The initial construction has an segment
    # of "root" and no trunk. Subtrees must pass in these details upon creation.
    def initialize(@segment = "#", @trunk = nil)
      @branches = Array(RouteSet(T)).new

      if @trunk
        @segment_type = FIXED

        if @segment.starts_with? ':'
          @segment_type = VARIABLE
        end

        if @segment.starts_with? '*'
          @segment_type = GLOB
        end

      else
        @segment_type = ROOT
      end
    end

    def deep_clone : RouteSet(T)
      clone = {{@type}}.allocate
      clone.initialize_copy(self)
      clone
    end

    protected def initialize_copy(other) : Nil
      @route = other.@route
      @trunk = nil
      @segment = other.@segment

      @segment_type = other.@segment_type
      @full_path = other.@full_path

      @branches = other.@branches.map { |s| s.deep_clone.as(RouteSet(T)) }
    end

    # Look for or create a subtree matching a given segment.
    def find_subtree!(segment : String) : RouteSet(T)
      if subtree = find_subtree segment
        subtree
      else
        RouteSet(T).new(segment, self).tap do |subtree|
          @branches.push subtree
        end
      end
    end

    # Look for and return a subtree matching a given segment.
    def find_subtree(segment : String) : RouteSet(T)?
      @branches.each do |subtree|
        break subtree if subtree.segment_match? segment
      end
    end

    def segment_match?(segment : String) : Bool
      segment == @segment
    end

    def root? : Bool
      @segment_type == ROOT
    end

    def fixed? : Bool
      @segment_type == FIXED
    end

    def variable? : Bool
      @segment_type == VARIABLE
    end

    def glob? : Bool
      @segment_type == GLOB
    end

    def leaf? : Bool
      @branches.size == 0
    end

    def routable? : Bool
      @route != nil
    end

    def routes? : Bool
      @branches.any?
    end

    # Recursively count the number of discrete paths remaining in the tree.
    def size
      return 1 if leaf?

      @branches.reduce 0 do |count, branch|
        count += branch.size
      end
    end

    # Recursively descend to find the attached application route.
    # Weakness: assumes only one path remains in the tree.
    def route
      return @route if leaf?
      @branches.first.route
    end

    # Recursively _prunes_ the route tree by matching segments
    # against path segment strings.
    #
    # A destructive breadth first search.
    #
    # return true if any routes matched.
    def select_routes!(path : Array(String)?) : Bool
      if path.nil? || path.empty?
        return false
      end

      first_segment = path.shift
      reverse_match = false

      case
      when root?
        # select all branches that match the full path
        path.unshift first_segment
      when fixed?
        # select branches only if this segment matches
        unless segment_match? first_segment
          return false
        end
      when variable?
        # always match
      when glob?
        reverse_match = true
      end

      if reverse_match
        match, _ = reverse_select_routes! path
        return match
      else
        @branches.select! do |subtree|
          subtree.select_routes! path.clone
        end
      end

      @branches.any? || (leaf? && path.empty?)
    end

    # Recursively matches the right hand side of a glob segment.
    # Allows for routes like /a/b/*/d/e and /a/b/*/f/g to coexist.
    # This is a modified version of a destructive depth first search.
    #
    # Importantly, each subtree must pass back up the remaining part
    # of the path so it can be matched against the parent, so this
    # method somewhat awkwardly returns:
    #
    #   Tuple(subtree_match : Bool, path_for_trunk_to_match : String)
    #
    def reverse_select_routes!(path : Array(String)) : Tuple(Bool, Array(String))
      remaining_path = [] of String
      was_leaf = leaf?

      @branches.select! do |subtree|
        match, modified_path = subtree.reverse_select_routes! path
        if match

          unless remaining_path.empty?
            raise "warning: overwriting remnant path"
          end

          remaining_path = modified_path
        end
      end

      # If this segment started as a leaf, no remant path exists. Match against the whole path.
      remaining_path = path if was_leaf

      # If this wasn't a leaf and there are no branches left, it's not a match.
      return {false, [] of String} unless @branches.any? || was_leaf

      # If this node is the glob, at least one subtree matched (or there are none).
      return {true, [] of String} if glob?

      last_segment = remaining_path.pop

      matched = case
      when fixed?
        segment_match? last_segment
      when variable?
        true
      else
        false
      end

      {matched, path.clone}
    end

    # Add a route to the tree.
    def add(path, route : T) : Nil
      segments = split_path path
      add(segments, route, path)
    end

    # Recursively find or create subtrees matching a given path, and store the
    # application route at the leaf.
    protected def add(segments : Array(String), route : T, full_path : String) : Nil
      if segments.empty?
        if @route.nil?
          @route = route
          @full_path = full_path
          return
        else
          raise "Unable to store route: #{full_path}, route is already defined as #{@full_path}"
        end
      end

      first_segment = segments.shift
      subtree = find_subtree! first_segment
      subtree.add(segments, route, full_path)
    end

    # Find a route which has been assigned to a matching path
    # Weakness: assumes only one route will match the path query.
    def find(path) : RouteSet(T)
      matches = deep_clone
      segments = split_path path

      matches.select_routes!(segments)

      if matches.size > 1
        puts "Warning: matched multiple routes for #{path}"
        p matches
      end
      return matches

      RoutedResult(T).new matches.route
    end

    # Produces a readable indented rendering of the tree, though
    # not really compatible with the other components of a deep object inspection
    def inspect(*, ts = 0)

      title = "  " * ts

      unless root?
        title += "|-"
      end

      title += @segment
      title += " (#{full_path})" if routable?
      title += "\n"

      @branches.reduce(title) do |s, subtree|
        s += subtree.inspect(ts: ts + 1)
        s
      end
    end

    # Split a path by slashes, remove blanks, and compact the path array.
    # E.g. split_path("/a/b/c/d") => ["a", "b", "c", "d"]
    private def split_path(path : String) : Array(String)
      path.split("/").map do |segment|
        next nil if segment.blank?
        segment
      end.compact
    end

  end
end
