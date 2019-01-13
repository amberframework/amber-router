module Amber::Router
  class RoutedResult(T)
    getter params = {} of String => String

    def initialize(@terminal_segment : TerminalSegment(T)?)
    end

    delegate :[], :[]=, to: @params

    def terminal_segment
      @terminal_segment.not_nil!
    end

    def path
      if @terminal_segment
        terminal_segment.full_path
      else
        raise "Cannot provide route path when no route was found. Ask first with #found?"
      end
    end

    def found?
      !!@terminal_segment
    end

    def payload?
      if found?
        terminal_segment.route
      else
        nil
      end
    end

    def payload
      payload?
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

    def formatted_s(io : IO)
      io << "#<RoutedResult "

      if found?
        io << "found "
        io << terminal_segment.full_path
      else
        io << "not found"
      end
      io << '>'
    end
  end
end
