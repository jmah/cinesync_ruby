require 'uri'
require 'cgi'
require 'tmpdir'

module CineSync
  module Commands
    class <<self
      def opens_url(*syms)
        syms.each do |sym|
          self.class.send(:define_method, :"#{sym}!") {|*args| CineSync::UI.open_url(send(sym, *args)) }
        end
      end
    end

    opens_url :open_session_file, :create_session, :join_session, :run_script

    def self.open_session_file(path, merge_with_existing = true)
      op = merge_with_existing ? 'merge' : 'replace'
      "cinesync://file/#{op}?path=#{CGI.escape(path)}"
    end

    def self.create_session(username = nil, password = nil)
      "cinesync://session/new" + if username
        "?username=#{CGI.escape(username)}" + if password
          "&password=#{CGI.escape(password)}"
        else '' end
      else '' end
    end

    def self.join_session(session_key)
      "cinesync://session/#{URI.escape(session_key)}"
    end

    def self.run_script(script_name, query = nil)
      "cinesync://script/#{URI.escape(script_name)}#{query ? "?#{query}" : ''}"
    end


    opens_url :open_session

    IllegalFileChars = /[^\w ~!@#\$%&\(\)_\-\+=\[\]\{\}',\.]/

    def self.open_session(session, name = nil, merge_with_existing = true)
      name ||= "untitled session"
      path = File.join(Dir.tmpdir, name.gsub(IllegalFileChars, '_') + ".csc")
      File.open(path, "w") {|f| f.puts session.to_xml }
      open_session_file(path, merge_with_existing)
    end
  end
end
