module CineSync
  class ZoomState
    attr_accessor :center, :scale_factor

    def initialize
      @center = [0.5, 0.5]
      @scale_factor = 1.0
    end

    def default?
      center == [0.5, 0.5] and scale_factor == 1.0
    end

    def valid?
      default? or (center.length == 2 and center.all? {|p| (0.0..1.0) === p } and scale_factor > 0.0) rescue false
    end
  end
end
