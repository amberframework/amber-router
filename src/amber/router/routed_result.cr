module Amber::Router
  class RoutedResult(T)
    getter payload : T?

    def initialize(terminal_segment : TerminalSegment(T)?)
      if segment = terminal_segment
        @payload = segment.route
      end
    end

    def found?
      ! payload.nil?
    end
  end
end
