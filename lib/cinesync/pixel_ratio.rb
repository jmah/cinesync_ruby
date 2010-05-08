module CineSync
  class PixelRatio
    attr_accessor :source_width, :source_height
    attr_accessor :target_width, :target_height

    def initialize
      @source_width  = 1.0
      @source_height = 1.0
      @target_width  = 1.0
      @target_height = 1.0
    end

    def default?
      source_width > 0.0 and source_width == source_height and
      target_width > 0.0 and target_width == target_height
    end

    def valid?
      default? or ([source_width, source_height, target_width, target_height].all? {|x| x > 0.0 }) rescue false
    end
  end
end
