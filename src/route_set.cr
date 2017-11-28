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

    # disable puts for performance testing
    macro puts(s)
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

    def select_routes(path : Array(String), startpos = 0) : Array(T)
      tab = "   " * startpos

      puts "#{tab} startpos: #{startpos} path size: #{path.size}"

      accepting_terminal_segments = startpos == path.size
      can_recurse = startpos <= path.size - 1

      puts "#{tab} terminal?: #{accepting_terminal_segments}"
      puts "#{tab} searching #{path}, options: #{@segments.map(&.to_s).join(", ")}"

      matches = [] of T

      @segments.each do |segment|
        puts "#{tab} checking #{segment.to_s}"
        case segment
        when TerminalSegment
          if accepting_terminal_segments
            puts "#{tab}\033[32m saving match!\033[0m"
            matches << segment.route
          end
        when Segment
          next unless can_recurse
          next unless segment.match? path[startpos]

          matched_routes = segment.route_set.select_routes(path, startpos + 1)
          matched_routes.each do |matched_route|
            matches << matched_route
          end
        end
      end

      puts "#{tab} finished checking #{@segments.map(&.to_s).join(", ")}"

      matches
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
    def reverse_select_routes(path : Array(String), startpos, endpos = nil)
      if endpos.nil?
        endpos = path.size - 1
      end

      was_leaf = leaf?

      @branches.select! do |subtree|
        match, modified_position = subtree.reverse_select_routes path, startpos, endpos
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
      puts "starting search for #{path}:"
      segments = split_path path
      matches = select_routes(segments)

      if matches.size > 1
        puts "Warning: matched multiple routes for #{path}"
        RoutedResult(T).new matches.first
      elsif matches.size == 0
        puts "Warning: matched zero routes."
        RoutedResult(T).new nil
      else
        puts "Should render a route"
        RoutedResult(T).new matches.first
      end
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
