module CineSync
  class FrameAnnotation
    attr_accessor :frame, :notes, :drawing_objects

    def initialize(frame_num)
      @frame = frame_num
      @notes = ''
      @drawing_objects = []
    end

    def default?
      notes.empty? and drawing_objects.empty?
    end

    def valid?
      frame >= 1
    end
  end
end
