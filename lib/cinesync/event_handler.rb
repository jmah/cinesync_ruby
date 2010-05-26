require 'pathname'


module CineSync
  class EventHandler
    attr_reader :save_format, :save_ext, :save_parent, :url, :session_key, :session

    def initialize(argv, session)
      @save_format = arg_value(argv, :save_fmt).downcase.to_sym
      @save_ext = { :jpeg => 'jpg', :png => 'png' }[@save_format]
      sp = arg_value(argv, :save_path, false)
      @save_parent = Pathname.new(sp) if sp

      @url = arg_value(argv, :url, false)

      key_val = arg_value(argv, :key)
      @session_key = key_val if key_val != OfflineKey

      @session = session
    end

    def offline?
      @session_key.nil?
    end

    def saved_frame_path(media_file, frame)
      return nil unless save_parent

      base = ('%s-%05d' % [media_file.name, frame])
      i = 1; p2 = nil
      begin
        p = p2
        p2, i = saved_frame_ver_path(base, i)
      end while p2.exist?
      p
    end


    private

    ArgMatchers = { :key          => /^--key=(\w+)$/,
                    :save_fmt     => /^--save-format=(.+)$/,
                    :save_path    => /^--save-dir=(.+)$/,
                    :url          => /^--url=(.+)$/ }

    def arg_value(argv, arg_key, required = true)
      re = ArgMatchers[arg_key]
      fail "Unknown symbolic argument key: #{arg_key.inspect}" unless re
      args = argv.select {|a| a =~ re }
      if args.empty?
        if required
          fail "Unable to find argument matching #{re.inspect} (argument key: #{arg_key.inspect})"
        else
          return nil
        end
      end
      fail "Found multiple arguments matching #{re.inspect}: #{args.inspect}" if args.size > 1
      args[0].match(re)[1]
    end

    def saved_frame_ver_path(base, version)
      basename = base + (version == 1 ? '' : " (#{version})") + '.' + save_ext
      [save_parent + basename, version + 1]
    end
  end
end
