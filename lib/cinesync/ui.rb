module CineSync
  module UI
    def self.open_url(url)
      case RUBY_PLATFORM
      when /darwin/
        system('open', url)
      when /mswin32|mingw32/
        system('cmd', '/c', 'start', '', '/b', url) # Of course
      end
    end

    def self.show_dialog(msg)
      puts msg
      case RUBY_PLATFORM
      when /darwin/
        mac_osax.display_alert("cineSync Script", :message => msg) if mac_osax
      when /mswin32|mingw32/
        require 'dl'
        user32 = DL.dlopen('user32')
        msgbox = user32['MessageBoxA', 'ILSSI']
        msgbox.call(0, msg, "cineSync Script", 0x41000) # MB_TOPMOST | MB_SYSTEMMODAL
      end
    end

    def self.prompt_to_save(prompt, filename)
      default_path = File.expand_path("~/Desktop/") + filename
      default_new_path = default_path unless File.exist?(default_path)

      case RUBY_PLATFORM
      when /darwin/
        if mac_osax
          begin
            val = mac_osax.choose_file_name(:with_prompt => prompt, :default_name => filename)
            String(val)
          rescue Appscript::CommandError
            nil
          end
        else
          # Default to the Desktop
          puts "Unable to create scripting object; using Desktop as save location."
          default_new_path
        end
      when /mswin32|mingw32/
        require 'cinesync/ui/win32_save_file_dialog'
        opts = {:title => prompt}
        opts[:default_name] = filename
        opts[:extension] = File.extname(filename)
        dlg = CineSync::UI::Win32SaveFileDialog.new(opts)
        dlg.execute!
      else
        # Default to the Desktop
        default_new_path
      end
    end


    def self.mac_osax
      begin
        require 'appscript'
        require 'osax'
        require 'cinesync/ui/standard_additions' # Dumped terminology for 64-bit
        @mac_osax ||= OSAX::ScriptingAddition.new("StandardAdditions", CineSync::UI::StandardAdditions).by_name("cineSync")
      rescue
        $stderr.puts "Unable to create scripting object. Check that rb-appscript gem is installed."
      end
    end
  end
end
