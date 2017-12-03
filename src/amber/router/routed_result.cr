module Amber::Router
  class RoutedResult(T)
    getter params = {} of String => String

    def initialize(@terminal_segment : TerminalSegment(T)?)
    end

    delegate :[], :[]=, to: @params

    def terminal_segment
      @terminal_segment.not_nil!
    end

    def found?
      ! @terminal_segment.nil?
    end

    def payload?
      if found?
        terminal_segment.route
      else
        nil
      end
    end

    def payload
      if found?
        terminal_segment.route
      else
        raise "nil things"
      end
    end

    def priority
      if found?
        terminal_segment.priority
      else
        -1
      end
    end

    def <(other : RoutedResult(T))
      priority < other.priority
    end

    def <=(other : RoutedResult(T))
      priority <= other.priority
    end

    def to_s(io : IO)
      io << "RoutedResult("

      if found?
        io << "found "
        io << terminal_segment.full_path
      else
        io << "not found"
      end
      io << ")"
    end

    def inspect(io : IO)
      to_s(io)
    end
  end
end
