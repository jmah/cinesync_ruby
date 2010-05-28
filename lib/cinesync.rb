require 'cinesync/session'
require 'cinesync/media_file'
require 'cinesync/play_range'
require 'cinesync/zoom_state'
require 'cinesync/pixel_ratio'
require 'cinesync/mask'
require 'cinesync/color_grading'
require 'cinesync/xml'
require 'cinesync/event_handler'
require 'cinesync/commands'
require 'cinesync/ui'
require 'digest'


module CineSync
  SessionV3XMLFileVersion = 3
  ShortHashSampleSize = 2048
  AllFilesGroup = 'All Files'
  OfflineKey = '_OFFLINE_'

  # Utility functions
  def self.short_hash(path)
    File.open(path, 'rb') do |f|
      size = f.stat.size
      buf = ''

      if size <= ShortHashSampleSize
        buf << f.read(size)
        buf << [].pack('x' * (ShortHashSampleSize - size))
      else
        buf << f.read(ShortHashSampleSize / 2)
        f.seek(-ShortHashSampleSize / 2, IO::SEEK_END)
        buf << f.read(ShortHashSampleSize / 2)
      end
      Digest::SHA1.hexdigest([size].pack('N').reverse + buf)
    end
  end

  def self.event_handler(argv = ARGV, stdin = $stdin)
    session = Session::load(stdin) rescue nil
    yield CineSync::EventHandler.new(argv, session)
  end
end
