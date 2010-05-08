module CineSync
  class Mask
    attr_accessor :alpha, :center, :scale_factor
    attr_accessor :width, :height

    def initialize(ratio_or_width = nil, height = nil)
      @alpha = 1.0
      @center = [0.5, 0.5]
      @scale_factor = 1.0
      if ratio_or_width and height.nil?
        self.ratio = ratio_or_width
      elsif ratio_or_width and height
        @width = Float(ratio_or_width)
        @height = Float(height)
      else
        @width = 1
        @height = 1
      end
    end

    def ratio
      wh = [width, height]
      # Convert to ints if the float represents an int
      wh.map {|f| (f == f.floor) ? f.to_i : f }.map {|num| num.to_s }.join(':')
    end

    def ratio=(rat)
      @width, @height = rat.split(':', 2).map(&:to_f)
    end

    def default?
      alpha == 1.0 and center == [0.5, 0.5] and scale_factor == 1.0 and
      width > 0.0 and width == height
    end

    def valid?
      default? or (width > 0.0 and height > 0.0 and center.length == 2 and
      [alpha, scale_factor, *center].all? {|f| (0.0..1.0) === f }) rescue false
    end
  end
end
