module Amber::Router
  class TerminalSegment(T)
    property route : T
    property full_path : String

    def initialize(@route, @full_path)
    end

    def inspect(*, ts = 0)
      "#{"  " * ts}|--(#{full_path})\n"
    end

    def to_s(i : IO)
      i << "(terminal: #{full_path})"
    end

  end
end
