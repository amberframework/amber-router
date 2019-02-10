module Amber::Router
  class VariableSegment(T) < Segment(T)
    def initialize(segment, @pattern : (Regex | Symbol)? = nil)
      super segment
    end

    def match?(segment : String) : Bool
      case @pattern
      when :integer
        match_integer?(segment)
      when :uuid
        match_uuid?(segment)
      when :ascii
        segment.ascii_only?
      when Regex
        !(segment =~ @pattern).nil?
      else
        true
      end
    end

    def parametric? : Bool
      true
    end

    def parameter : String
      segment[1..-1]
    end

    private def match_integer?(segment : String) : Bool
      segment.each_byte do |byte|
        return false unless 48 <= byte <= 57
      end
      true
    end

    # This is a port of https://github.com/crystal-lang/crystal/blob/master/src/uuid.cr#L79
    private def match_uuid?(segment)
      return false if segment.bytesize != 36
      {8, 13, 18, 23}.each { |offset| return false if segment[offset] != '-' }
      {0, 2, 4, 6, 9, 11, 14, 16, 19, 21, 24, 26, 28, 30, 32, 34}.each do |offset|
        return false unless (ch1 = segment[offset].to_u8?(16)) && (ch2 = segment[offset + 1].to_u8?(16))
      end
      true
    end
  end
end
