$: << File.expand_path(File.dirname(__FILE__))
require 'spec_helper'

describe "cineSync utilities" do
  it "correctly hashes big file" do
    CineSync.short_hash("/Volumes/Oyama/Streams/cineSync Test Files/movies/nasa_shuttle_m420p.mov").should == "08e5628d51b14278f73f36afebf0506afc2bfcf8"
  end

  it "correctly hashes small file" do
    CineSync.short_hash("spec/small.txt").should == '1e40efb84050f92618e2c430742f44254771cf6b'
  end
end
