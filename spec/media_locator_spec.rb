$: << File.expand_path(File.dirname(__FILE__))
require 'spec_helper'

describe "media locators" do
  it "should represent empty locators" do
    ml = CineSync::MediaLocator.new
    ml.should.not.be.valid?
    ml.path.should.be.nil?
    ml.url.should.be.nil?
    ml.short_hash.should.be.nil?
  end

  it "should accept a url location" do
    url = "http://example.com/random_file.mov"
    ml = CineSync::MediaLocator.new(url)
    ml.should.be.valid?
    ml.path.should.be.nil?
    ml.url.to_s.should == url
    ml.short_hash.should.be.nil?

    ml.url.scheme.should == "http"
    ml.url.host.should == "example.com"
    ml.url.path.should == "/random_file.mov"
  end

  it "should set short hash for an existing path" do
    path = "/Volumes/Oyama/Streams/cineSync Test Files/movies/nasa_shuttle_m420p.mov"
    ml = CineSync::MediaLocator.new(path)
    ml.should.be.valid?
    ml.path.should == path
    ml.url.should.be.nil?
    ml.short_hash.should == "08e5628d51b14278f73f36afebf0506afc2bfcf8"
  end

  it "should accept path to non-existent file" do
    path = "/path/to/nonexistent/file.mov"
    ml = CineSync::MediaLocator.new(path)
    ml.should.be.valid?
    ml.path.should == path
    ml.url.should.be.nil?
    ml.short_hash.should.be.nil?
  end

  it "should accept dos path" do
    path = 'C:\path\to\myMovie.mov'
    ml = CineSync::MediaLocator.new(path)
    ml.should.be.valid?
    ml.path.should == path
    ml.url.should.be.nil?
    ml.short_hash.should.be.nil?
  end

  it "should accept short hash as locator" do
    hash = "08e5628d51b14278f73f36afebf0506afc2bfcf8"
    ml = CineSync::MediaLocator.new(hash)
    ml.should.be.valid?
    ml.path.should.be.nil?
    ml.url.should.be.nil?
    ml.short_hash.should == hash
  end

  it "should convert relative paths to absolute" do
    rel_path = "../nonexist-test.mov"
    abs_path = File.expand_path(rel_path)
    ml = CineSync::MediaLocator.new(rel_path)
    ml.path.should == abs_path
  end
end
