module CineSync
  class Session
    attr_reader :file_version
    attr_accessor :user_data, :media, :groups, :notes
    attr_accessor :chat_elem, :stereo_elem

    def initialize
      @file_version = SessionV3XMLFileVersion
      @user_data = ''
      @media = []
      @groups = []
      @notes = ''
    end

    def session_features
      (stereo_elem or media.any? {|m| m.uses_pro_features? }) ? :pro : :standard
    end

    def valid?
      file_version == SessionV3XMLFileVersion and
      media.all? {|m| m.valid? }
    end
  end
end
