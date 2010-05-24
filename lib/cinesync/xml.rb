require 'active_support'
require 'andand'
require 'builder'
require 'rexml/document'
require 'uri'


module CineSync
  SessionV3Namespace = 'http://www.cinesync.com/ns/session/3.0'

  class Session
    # eSession = element session {
    #   attribute version { xsd:integer { minInclusive = "3" } } &
    #   attribute sessionFeatures { "standard" | "pro" } &
    #   aUserData? &
    #   eGroup* &
    #   eNotes? &
    #   eChat? &
    #   eMedia* }

    def to_xml
      fail "#{self.inspect}: Invalid" unless valid?

      x = Builder::XmlMarkup.new(:indent => 4)
      x.instruct!

      attrs = {}
      attrs['xmlns'] = SessionV3Namespace
      # Always write as the version we know, not the version we loaded
      attrs['version'] = SessionV3XMLFileVersion
      attrs['sessionFeatures'] = session_features
      attrs['userData'] = user_data unless user_data.empty?

      x.session(attrs) {
        groups.each {|g| x.group(g) }
        x.notes(notes) unless notes.empty?
        x << chat_elem.to_s if chat_elem
        x << stereo_elem.to_s if stereo_elem
        media.each {|m| m.to_xml(x) }
      }
    end


    def self.load(str_or_io, silent = false)
      doc = REXML::Document.new(str_or_io)

      # Do a few checks (the user should have already confirmed that the
      # document conforms to the schema, but we'll try to fail early in case)
      fail 'Expected to find root <session> element' unless doc.root.name == 'session'
      fail %Q[Root <session> element must have attribute xmlns="#{SessionV3Namespace}"] unless doc.root.attribute('xmlns').value == SessionV3Namespace

      doc_version = doc.root.attribute('version').value.to_i
      if doc_version > SessionV3XMLFileVersion
        $stderr.puts("Warning: Loading session file with a newer version (#{doc_version}) than this library (#{SessionV3XMLFileVersion})") unless silent
      end

      elem = doc.root

      returning self.new do |s|
        s.instance_variable_set(:@file_version, doc_version)

        s.user_data = elem.attribute('userData').andand.value || ''
        s.groups = elem.get_elements('group').map {|g_elem| g_elem.text }
        s.notes = elem.elements['notes'].andand.text || ''
        s.chat_elem = elem.get_elements('chat').andand[0]
        s.stereo_elem = elem.get_elements('stereo').andand[0]
        s.media = elem.get_elements('media').map {|e| MediaBase.load(e) }
      end
    end
  end


  class MediaBase
    # MediaBase =
    #   aUserData? &
    #   attribute active { tBool }? &
    #   attribute currentFrame { tFrameNumber }? &
    #   eGroup* &
    #   ePlayRange?

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?

      attrs = {}
      attrs['userData'] = user_data unless user_data.empty?
      attrs['active'] = active? if active?
      attrs['currentFrame'] = current_frame if current_frame != 1

      x.media(attrs) {
        yield x
        groups.each {|g| x.group(g) }
        play_range.to_xml(x)
      }
    end


    def self.load(elem)
      klass = elem.elements['groupMovie'] ? GroupMovie : MediaFile
      klass.load(elem)
    end

    protected
    def self.common_load(elem, inst)
      returning inst do |m|
        m.user_data = elem.attribute('userData').andand.value || ''
        m.active = elem.attribute('active').andand.value == 'true'
        m.current_frame = elem.attribute('currentFrame').andand.value.andand.to_i || 1
        m.groups = elem.get_elements('group').map {|g_elem| g_elem.text }

        play_range_elem = elem.elements['playRange']
        m.play_range = PlayRange.load(play_range_elem) if play_range_elem
      end
    end
  end


  class MediaFile < MediaBase
    # eMedia |= element media {
    #   # Normal media file
    #   MediaBase &
    #   element name { xsd:string { minLength = "1" } } &
    #   element locators { eLocator+ } &
    #   eNotes? &
    #   eZoomState? &
    #   ePixelRatio? &
    #   eMask? &
    #   eColorGrading? &
    #   eFrameAnnotation* }

    def to_xml(x)
      super(x) do |x|
        x.name(name)
        locator.to_xml(x)
        x.notes(notes) unless notes.empty?

        zoom_state.to_xml(x)
        pixel_ratio.to_xml(x)
        mask.to_xml(x)
        color_grading.to_xml(x)

        annotations.values.each {|ann| ann.to_xml(x) }
      end
    end


    def self.load(elem)
      returning self.new do |m|
        common_load(elem, m)

        m.name = elem.elements['name'].text
        m.locator = MediaLocator.load(elem.elements['locators'])
        m.notes = elem.elements['notes'].andand.text || ''

        elem.get_elements('annotation').each do |ann_elem|
          m.annotations << FrameAnnotation.load(ann_elem)
        end

        # Load optional structures
        %w(zoomState pixelRatio mask colorGrading).each do |camel_name|
          set_sym = (camel_name + '=').underscore.to_sym
          e = elem.elements[camel_name]
          next if e.nil?

          obj = ('CineSync::' + camel_name.camelize).constantize.load(e)
          m.send(set_sym, obj)
        end
      end
    end
  end


  class GroupMovie < MediaBase
    # eMedia |= element media {
    #   # Group movie
    #   MediaBase &
    #   element groupMovie { eGroup } }

    def to_xml(x)
      super(x) do |x|
        x.groupMovie {
          x.group(group)
        }
      end
    end


    def self.load(elem)
      group = elem.elements['groupMovie/group'].text
      returning self.new(group) do |m|
        common_load(elem, m)
      end
    end
  end


  class MediaLocator
    # eLocator |= element path       { tFilePath }
    # eLocator |= element shortHash  { tShortHash }
    # eLocator |= element url        { tURL }

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?

      x.locators {
        x.path(path) if path
        x.shortHash(short_hash) if short_hash
        x.url(String(url)) if url
      }
    end


    def self.load(elem)
      returning self.new do |loc|
        loc.path = elem.elements['path'].andand.text
        loc.short_hash = elem.elements['shortHash'].andand.text
        if elem.elements['url']
          loc.url = URI::parse(elem.elements['url'].text)
        end
      end
    end
  end


  class PlayRange
    # ePlayRange = element playRange {
    #   element inFrame       { attribute value { tFrameNumber } } &
    #   element outFrame      { attribute value { tFrameNumber } } &
    #   element playOnlyRange { aBoolValue } }

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?
      return if default?

      x.playRange {
        x.inFrame(:value => in_frame)
        x.outFrame(:value => out_frame)
        x.playOnlyRange(:value => play_only_range?)
      }
    end


    def self.load(elem)
      returning self.new do |pr|
        pr.in_frame = elem.elements['inFrame/attribute::value'].value.to_i
        pr.out_frame = elem.elements['outFrame/attribute::value'].value.to_i
        pr.play_only_range = elem.elements['playOnlyRange/attribute::value'].value == 'true'
      end
    end
  end


  class ZoomState
    # eZoomState = element zoomState {
    #   element center { aXY } &
    #   eScaleFactor }

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?
      return if default?

      x.zoomState {
        x.center(:x => center[0], :y => center[1])
        x.scaleFactor(:value => scale_factor)
      }
    end


    def self.load(elem)
      returning self.new do |zs|
        x = elem.elements['center/attribute::x'].value.to_f
        y = elem.elements['center/attribute::y'].value.to_f
        zs.center = [x, y]
        zs.scale_factor = elem.elements['scaleFactor/attribute::value'].value.to_f
      end
    end
  end


  class PixelRatio
    # ePixelRatio = element pixelRatio {
    #   element source { aRatio } &
    #   element target { aRatio } }
    # aRatio  &= attribute width  { tPositiveFloat }
    # aRatio  &= attribute height { tPositiveFloat }

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?
      return if default?

      x.pixelRatio {
        x.source(:width => source_width, :height => source_height)
        x.target(:width => target_width, :height => target_height)
      }
    end


    def self.load(elem)
      returning self.new do |pr|
        pr.source_width  = elem.elements['source/attribute::width'].value.to_f
        pr.source_height = elem.elements['source/attribute::height'].value.to_f
        pr.target_width  = elem.elements['target/attribute::width'].value.to_f
        pr.target_height = elem.elements['target/attribute::height'].value.to_f
      end
    end
  end


  class Mask
    # eMask = element mask {
    #   aAlpha &
    #   element center { aXY } &
    #   element ratio { aRatio } &
    #   eScaleFactor }

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?
      return if default?

      x.mask(:alpha => alpha) {
        x.center(:x => center[0], :y => center[1])
        x.ratio(:width => width, :height => height)
        x.scaleFactor(:value => scale_factor)
      }
    end


    def self.load(elem)
      returning self.new do |mask|
        mask.alpha = elem.attribute('alpha').value.to_f
        x = elem.elements['center/attribute::x'].value.to_f
        y = elem.elements['center/attribute::y'].value.to_f
        mask.center = [x, y]
        mask.width  = elem.elements['ratio/attribute::width'].value.to_f
        mask.height = elem.elements['ratio/attribute::height'].value.to_f
        mask.scale_factor = elem.elements['scaleFactor/attribute::value'].value.to_f
      end
    end
  end


  class ColorGrading
    # eColorGrading = element colorGrading {
    #   element offset {
    #     attribute red  	 	{ tColorOff } &
    #     attribute green	 	{ tColorOff } &
    #     attribute blue 	 	{ tColorOff } }? &
    #
    #   element brightness {
    #     attribute rgb  	 	{ tColorExp } &
    #     attribute red  	 	{ tColorExp } &
    #     attribute green	 	{ tColorExp } &
    #     attribute blue 	 	{ tColorExp } }? &
    #
    #   element saturation  { attribute value { tColorExp } }? &
    #   element gamma       { attribute value { tColorExp } }? &
    #   element contrast    { attribute value { tColorExp } }? &
    #
    #   element linearToLog { aBoolValue }? &
    #   element lutPath     { attribute value { tFilePath } }? }

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?
      return if default?

      x.colorGrading {
        x.offset(:red => offset[:r], :green => offset[:g], :blue => offset[:b])
        br = brightness
        x.brightness(:rgb => br[:rgb], :red => br[:r], :green => br[:g], :blue => br[:b])
        x.saturation(:value => saturation)
        x.gamma(:value => gamma)
        x.contrast(:value => contrast)
        x.linearToLog(:value => linear_to_log?)
        x.lutPath(:value => lut_path) if lut_path
      }
    end


    def self.load(elem)
      returning self.new do |cg|
        offset_elem = elem.elements['offset']
        if offset_elem
          %w(red green blue).each do |attr|
            cg.offset[attr] = offset_elem.attribute(attr).value.to_f
          end
        end

        brightness_elem = elem.elements['brightness']
        if brightness_elem
          %w(rgb red green blue).each do |attr|
            cg.brightness[attr] = brightness_elem.attribute(attr).value.to_f
          end
        end

        # Everything is optional
        (cg.saturation = elem.elements['saturation/attribute::value'].value.to_f) rescue :ignore
        (cg.gamma      = elem.elements['gamma/attribute::value'].value.to_f     ) rescue :ignore
        (cg.contrast   = elem.elements['contrast/attribute::value'].value.to_f  ) rescue :ignore

        (cg.linear_to_log = elem.elements['linearToLog/attribute::value'].value == 'true') rescue :ignore
        (cg.lut_path = elem.elements['lutPath/attribute::value']) rescue :ignore
      end
    end
  end


  class FrameAnnotation
    # eFrameAnnotation = element annotation {
    #   attribute frame { tFrameNumber } &
    #   eNotes? &
    #   eObject* }
    DrawingObjectElements = %w(line erase circle arrow text)

    def to_xml(x)
      fail "#{self.inspect}: Invalid" unless valid?
      return if default?

      attrs = {}
      attrs['frame'] = frame

      x.annotation(attrs) {
        x.notes(notes) unless notes.empty?
        drawing_objects.each {|obj| x << obj.to_s }
      }
    end


    def self.load(elem)
      returning self.new(elem.attribute('frame').value.to_i) do |ann|
        ann.notes = elem.elements['notes'].andand.text || ''
        DrawingObjectElements.each do |obj_name|
          ann.drawing_objects += elem.get_elements(obj_name)
        end
      end
    end
  end
end
