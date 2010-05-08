require 'cinesync/play_range'
require 'cinesync/zoom_state'
require 'cinesync/pixel_ratio'
require 'cinesync/mask'
require 'cinesync/color_grading'
require 'cinesync/frame_annotation'


module CineSync
  class MediaBase
    attr_accessor :user_data, :active, :current_frame
    attr_accessor :groups, :play_range

    alias_method :active?, :active

    def initialize
      @user_data = ''
      @active = false
      @current_frame = 1

      @groups = []
      @play_range = PlayRange.new
    end

    def uses_pro_features?
      false
    end

    def valid?
      current_frame >= 1 and play_range.valid?
    end
  end


  class MediaFile < MediaBase
    attr_accessor :name, :locator, :notes
    attr_reader :annotations
    attr_accessor :zoom_state, :pixel_ratio, :mask, :color_grading

    def initialize(locator_arg = nil)
      super()
      @name = ''
      @notes = ''
      @annotations = Hash.new {|h,k| h[k] = FrameAnnotation.new(k) }
      def @annotations.<<(ann)
        self[ann.frame] = ann
      end

      @locator = MediaLocator.new(locator_arg)
      @name = File.basename(@locator.path || @locator.url.andand.path || '')

      @zoom_state = ZoomState.new
      @pixel_ratio = PixelRatio.new
      @mask = Mask.new
      @color_grading = ColorGrading.new
    end

    def uses_pro_features?
      super || [zoom_state, pixel_ratio, mask, color_grading].any? {|x| not x.default? }
    end

    def valid?
      super and
      name.length >= 1 and
      locator and locator.valid? and
      annotations.values.all? {|ann| ann.valid? } and
      [zoom_state, pixel_ratio, mask, color_grading].all? {|x| x.valid? }
    end
  end


  class GroupMovie < MediaBase
    attr_accessor :group

    def initialize(grp)
      super()
      @group = grp
    end

    def uses_pro_features?
      true
    end

    def valid?
      super and group and not group.empty?
    end
  end


  class MediaLocator
    attr_accessor :path, :url, :short_hash

    def initialize(path_or_url_or_hash = nil)
      @path = nil
      @url = nil
      @short_hash = nil

      s = String(path_or_url_or_hash)
      unless s.empty?
        maybe_uri = URI::parse(s) rescue nil

        if File.exist? s
          @path = s
          @short_hash = CineSync::short_hash(@path)
        elsif maybe_uri and maybe_uri.scheme
          # The argument could be parsed as a URI (use it as a URL)
          @url = maybe_uri
        elsif s =~ /^[0-9a-f]{40}$/
          # Length is 40 characters and consists of all hex digits; assume this is a short hash
          @short_hash = s
        else
          # Finally, assume it's a file path
          @path = s
        end
      end
    end

    def valid?
      path or url or short_hash
    end
  end
end
