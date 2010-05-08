module CineSync
  class PlayRange
    attr_accessor :in_frame, :out_frame, :play_only_range

    alias_method :play_only_range?, :play_only_range

    def initialize
      @in_frame = nil
      @out_frame = nil
      @play_only_range = true
    end

    def default?
      in_frame.nil? and out_frame.nil? and play_only_range?
    end

    def valid?
      default? or (in_frame >= 1 and out_frame >= 1 and out_frame >= in_frame) rescue false
    end
  end
end
