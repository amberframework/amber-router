module Amber::Router
  class RoutedResult(T)
    getter payload
    def initialize(@payload : T?)
    end

    def found?
      ! payload.nil?
    end
  end
end
