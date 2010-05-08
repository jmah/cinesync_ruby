module CineSync
  class ColorGrading
    attr_reader :offset, :brightness
    attr_accessor :saturation, :gamma, :contrast, :linear_to_log, :lut_path

    alias_method :linear_to_log?, :linear_to_log

    def initialize
      @offset = RGBArray.new([0.0] * 3)
      @brightness = BrightnessArray.new([1.0] * 4)
      @saturation = 1.0
      @gamma = 1.0
      @contrast = 1.0
      @linear_to_log = false
      @lut_path = nil
    end

    def default?
      offset == [0.0]*3 and brightness == [1.0]*4 and
      [saturation, gamma, contrast].all? {|f| f == 1.0 } and
      not linear_to_log? and lut_path.nil?
    end

    def valid?
      exp_range = Math.exp(-1)..Math.exp(1)
      default? or (offset.length == 3 and brightness.length == 4 and
      offset.all? {|o| (-0.2..0.2) === o } and
      [saturation, gamma, contrast, *brightness].all? {|b| exp_range === b }) rescue false
    end
  end


  class RGBArray < Array
    # Implements an array of three values (corresponding to red, green, and
    # blue) that can be indexed by position or string-convertible object:
    #  r,g,b = rgbary[0], rgbary[1], rgbary[2]
    #  r,g,b = rgbary['red'], rgbary[:green], rgbary[:b]

    def [](key)
      index = index_for_key(key)
      fail "Unknown key used to index #{self.class}: #{key.inspect}" unless index
      self.at(index)
    end

    def []=(key, value)
      index = index_for_key(key)
      fail "Unknown key used to index #{self.class}: #{key.inspect}" unless index
      super(index, value)
    end

    protected
    def index_for_key(key)
      if Fixnum === key then key
      elsif %w[red   r].include?(key.to_s.downcase) then 0
      elsif %w[green g].include?(key.to_s.downcase) then 1
      elsif %w[blue  b].include?(key.to_s.downcase) then 2
      end
    end
  end


  class BrightnessArray < RGBArray
    protected
    def index_for_key(key)
      if %w[all rgb].include?(key.to_s.downcase) then 3
      else super
      end
    end
  end
end
