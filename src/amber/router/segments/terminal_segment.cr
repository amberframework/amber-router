module Amber::Router
  class TerminalSegment(T)
    property route : T
    property full_path : String
    property priority : Int32

    def initialize(@route, @full_path)
      @priority = 0
    end

    def <(other : TerminalSegment(T))
      @priority < other.priority
    end

    def <=(other : TerminalSegment(T))
      @priority <= other.priority
    end

    def inspect(*, ts = 0)
      "#{"  " * ts}|--(#{full_path} P#{priority})\n"
    end
  end
end
