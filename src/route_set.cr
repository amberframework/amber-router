require "./routed_result"

require "./terminal_segment"
require "./segment"
require "./fixed_segment"
require "./variable_segment"
require "./glob_segment"

module Amber::Router
  class RouteSet(T)
    @trunk : RouteSet(T)?
    @route : T?

    # A tree data structure (recursive). The initial construction has an segment
    # of "root" and no trunk. Subtrees must pass in these details upon creation.
    def initialize(@root = true)
      @segments = Array(Segment(T) | TerminalSegment(T)).new
    end

    # Look for or create a subtree matching a given segment.
    def find_subtree!(segment : String) : Segment(T)
      if subtree = find_subtree segment
        subtree
      else
        case
        when segment.starts_with? ':'
          new_segment = VariableSegment(T).new(segment)
        when segment.starts_with? '*'
          new_segment = GlobSegment(T).new(segment)
        else
          new_segment = FixedSegment(T).new(segment)
        end

        @segments.push new_segment
        new_segment
      end
    end

    # Look for and return a subtree matching a given segment.
    def find_subtree(url_segment : String) : Segment(T)?
      @segments.each do |segment|
        case segment
        when Segment
          break segment if segment.match? url_segment
        when TerminalSegment
          puts "terminal segment"
          next
        else
          puts "finding subtree else oops"
        end
      end
    end

    # Add a route to the tree.
    def add(path, route : T) : Nil
      segments = split_path path
      add(segments, route, path)
    end

    # Recursively find or create subtrees matching a given path, and store the
    # application route at the leaf.
    protected def add(url_segments : Array(String), route : T, full_path : String) : Nil
      puts "adding #{url_segments} (#{full_path})"

      unless url_segments.any?
        puts "terminal"
        @segments.push TerminalSegment(T).new(route, full_path)
        return
      end

      segment = find_subtree! url_segments.shift
      segment.route_set.add(url_segments, route, full_path)
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
      @segments.any?
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
    def select_routes!(path : Array(String)?, startpos = 0) : Bool
      if path.nil? || path.empty?
        return false
      end

      can_recurse = root? || startpos <= path.size - 2

      first_segment = path[startpos]
      reverse_match = false

      case
      when root?
        # check all branches against the full path
        startpos = -1
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
        match, _ = reverse_select_routes! path, startpos
        return match
      else
        if can_recurse
          @branches.select! do |subtree|
            subtree.select_routes! path, startpos + 1
          end
        else
          @branches = [] of RouteSet(T)
        end
      end

      @branches.any? || (routable? && ! can_recurse)
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
    def reverse_select_routes!(path : Array(String), startpos, endpos = nil)
      if endpos.nil?
        endpos = path.size - 1
      end

      was_leaf = leaf?

      @branches.select! do |subtree|
        match, modified_position = subtree.reverse_select_routes! path, startpos, endpos
        endpos = modified_position if match
        match
      end

      # If this wasn't a leaf and there are no branches left, it's not a match.
      return {false, endpos} unless @branches.any? || was_leaf

      # If this node is the glob, at least one subtree matched (or there are none).
      return {true, endpos} if glob?

      last_segment = path[endpos]

      matched = case
      when fixed?
        segment_match? last_segment
      when variable?
        true
      else
        false
      end

      {matched, endpos - 1}
    end

    # Find a route which has been assigned to a matching path
    # Weakness: assumes only one route will match the path query.
    def find(path) : RoutedResult(T)
      matches = deep_clone
      segments = split_path path

      matches.select_routes!(segments)

      if matches.size > 1
        puts "Warning: matched multiple routes for #{path}"
      end

      RoutedResult(T).new matches.route
    end

    # Produces a readable indented rendering of the tree, though
    # not really compatible with the other components of a deep object inspection
    def inspect(*, ts = 0)
      @segments.reduce("") do |s, segment|
        s + segment.inspect(ts: ts + 1)
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
