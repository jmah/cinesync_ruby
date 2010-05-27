$: << File.expand_path(File.dirname(__FILE__))
require 'spec_helper'

describe "XML serialization" do
  it "should serialize empty session" do
    s = CineSync::Session.new
    xml = s.to_xml
    xml.should.not.be.empty?

    doc = REXML::Document.new(xml)
    doc.root.name.should == "session"
    doc.root.namespace.should == CineSync::SessionV3Namespace
    doc.root.attributes["version"].to_i.should == CineSync::SessionV3XMLFileVersion
    doc.root.attributes["sessionFeatures"].should == s.session_features.to_s
    doc.root.attributes["userData"].should.be.nil?
    doc.root.elements["notes"].should.be.nil?
  end

  it "should fail when writing an invalid session" do
    s = CineSync::Session.new
    s.media << CineSync::MediaFile.new
    s.should.not.be.valid?
    should.raise(Exception) { s.to_xml }
  end

  it "should load basic session" do
    path = File.join("spec", "v3 files", "v3-basic.csc")
    s = File.open(path) {|f| CineSync::Session.load(f) }
    s.file_version.should == 3
    s.user_data.should == "sessionUserData blah bloo blee"
    s.media.length.should == 3
    s.notes.should == "These are my session notes.\nnewline."
    s.should.be.valid?

    s.media[0].should.be.valid?
    s.media[0].name.should == "024b_fn_079_v01_1-98.mov"
    s.media[0].locator.path.should == "/Volumes/Scratch/test_files/movies/024b_fn_079_v01_1-98.mov"
    s.media[0].should.not.be.active?
    s.media[0].current_frame.should == 1
    s.media[0].user_data.should == ""
    s.media[0].groups.should == []

    s.media[1].should.be.valid?
    s.media[1].name.should == "sample_mpeg4.mp4"
    s.media[1].locator.url.to_s.should == "http://example.com/test_files/movies/sample_mpeg4.mp4"
    s.media[1].locator.short_hash.should == "e74db5de61fa5483c541a3a3056f22d158b44ace"
    s.media[1].should.be.active?
    s.media[1].current_frame.should == 65
    s.media[1].user_data.should == ""
    s.media[1].groups.should == []

    s.media[2].should.be.valid?
    s.media[2].name.should == "Test_MH 2fps.mov"
    s.media[2].locator.short_hash.should == "f9f0c5d3e3e340bcc9486abbb01a71089de9b886"
    s.media[2].should.not.be.active?
    s.media[2].current_frame.should == 1
    s.media[2].user_data.should == "myPrivateInfo"
    s.media[2].groups.should == []
    s.media[2].notes.should == "These notes on the last movie."
    s.media[2].annotations[1].notes.should == "This is a note on the first frame of the last movie."
    s.media[2].annotations[88].notes.should == ""
  end

  it "should load group movies" do
    path = File.join("spec", "v3 files", "v3-refmovie.csc")
    s = File.open(path) {|f| CineSync::Session.load(f) }
    s.file_version.should == 3
    s.user_data.should == "sessionUserData blah bloo blee"
    s.media.length.should == 3
    s.notes.should == "These are my session notes.\nnewline."
    s.should.be.valid?

    s.media[0].should.be.valid?
    s.media[0].name.should == "024b_fn_079_v01_1-98.mov"
    s.media[0].locator.path.should == "/Volumes/Scratch/test_files/movies/024b_fn_079_v01_1-98.mov"
    s.media[0].should.not.be.active?
    s.media[0].current_frame.should == 1
    s.media[0].user_data.should == ""
    s.media[0].groups.should == ["myGroup"]

    s.media[1].should.be.valid?
    s.media[1].name.should == "sample_mpeg4.mp4"
    s.media[1].locator.url.to_s.should == "http://example.com/test_files/movies/sample_mpeg4.mp4"
    s.media[1].locator.short_hash.should == "e74db5de61fa5483c541a3a3056f22d158b44ace"
    s.media[1].should.not.be.active?
    s.media[1].current_frame.should == 1
    s.media[1].user_data.should == ""
    s.media[1].groups.should == []

    s.media[2].should.be.valid?
    s.media[2].group.should == "myGroup"
    s.media[2].should.not.be.active?
    s.media[2].current_frame.should == 1
    s.media[2].user_data.should == ""
  end

  it "should load higher version" do
    xml_str = <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
      <session xmlns="http://www.cinesync.com/ns/session/3.0" version="4" sessionFeatures="standard">
      </session>
    XML
    s = CineSync::Session.load(xml_str, true)
    s.should.not.be.valid?
    s.user_data.should == ""
    s.file_version.should == 4
    s.notes.should == ""
    s.session_features.should == :standard
  end

  it "should load groups" do
    xml_str = <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
      <session xmlns="http://www.cinesync.com/ns/session/3.0" version="3" sessionFeatures="standard">
        <group>Group 1</group>
        <group>second&gt;group</group>
        <media userData="media data" currentFrame="12">
          <name>First movie</name>
          <locators><shortHash>f9f0c5d3e3e340bcc9486abbb01a71089de9b886</shortHash></locators>
          <group>Group 1</group>
        </media>
      </session>
    XML
    s = CineSync::Session.load(xml_str)
    s.should.be.valid?
    s.groups.should == ["Group 1", "second>group"]
    s.media[0].current_frame.should == 12
    s.media[0].groups.should == ["Group 1"]
  end

  it "should load session and media notes" do
    xml_str = <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
      <session xmlns="http://www.cinesync.com/ns/session/3.0" version="3" sessionFeatures="standard">
        <media userData="media data">
          <name>First movie</name>
          <locators><path>/does/not/exist.mov</path></locators>
          <notes>Media notes that come first in the file</notes>
        </media>
        <notes>session notes</notes>
      </session>
    XML
    s = CineSync::Session.load(xml_str)
    s.notes.should == "session notes"
    s.media[0].current_frame.should == 1
    s.media[0].user_data.should == "media data"
    s.media[0].notes.should == "Media notes that come first in the file"
  end

  it "should preserve drawing objects" do
    path = File.join("spec", "v3 files", "v3-groups.csc")
    s = File.open(path) {|f| CineSync::Session.load(f) }
    s.file_version.should == 3
    s.notes.should == ""
    s.should.be.valid?

    mf = s.media[0]
    mf.annotations.length.should == 13
    mf.annotations[1].drawing_objects[0].name.should.satisfy do |tag|
      CineSync::FrameAnnotation::DrawingObjectElements.include? tag
    end

    doc = REXML::Document.new(s.to_xml)
    doc.root.get_elements("media").length.should == s.media.length
    doc.root.get_elements("group").length.should == s.groups.length
    doc.root.get_elements("media")[0].get_elements("annotation").length.should == 13
  end

  it "should write basic session" do
    s = CineSync::Session.new
    path = "/path/to/nonexistent/file.mov"
    s.media << CineSync::MediaFile.new(path)
    xml = s.to_xml
    xml.should.not.be.nil?
    xml.should.not.be.empty?

    doc = REXML::Document.new(xml)
    doc.root.name.should == "session"
    doc.root.attributes["sessionFeatures"].should == s.session_features.to_s
    doc.root.get_elements("media").length.should == 1
    media_elem = doc.root.get_elements("media")[0]
    media_elem.get_elements("groups").length.should == 0
    media_elem.elements[".//locators/path"].text.should == path
  end

  it "should write short hash locators" do
    s = CineSync::Session.new
    path = "/Volumes/Oyama/Streams/cineSync Test Files/movies/nasa_shuttle_m420p.mov"
    mf = CineSync::MediaFile.new(path)
    s.media << mf

    doc = REXML::Document.new(s.to_xml)
    media_elem = doc.root.get_elements("media")[0]
    loc_elem = media_elem.get_elements("locators")[0]
    loc_elem.elements["path"].text.should == mf.locator.path
    loc_elem.elements["shortHash"].text.should == mf.locator.short_hash
    loc_elem.elements["url"].should.be.nil?
  end

  it "should write url locators" do
    s = CineSync::Session.new
    url = "http://example.com/random_file.mov"
    mf = CineSync::MediaFile.new(url)
    s.media << mf

    doc = REXML::Document.new(s.to_xml)
    media_elem = doc.root.get_elements("media")[0]
    loc_elem = media_elem.get_elements("locators")[0]
    loc_elem.elements["path"].should.be.nil?
    loc_elem.elements["shortHash"].should.be.nil?
    loc_elem.elements["url"].text.should == url
    loc_elem.elements["url"].text.should == String(mf.locator.url)
  end

  it "should write groups" do
    s = CineSync::Session.new
    s.groups = %w(Draft Final)
    url = "http://example.com/random_file.mov"
    mf = CineSync::MediaFile.new(url)
    mf.groups << "Final"
    s.media << mf
    s.media << CineSync::MediaFile.new("http://example.com/random_file_2.mov")

    doc = REXML::Document.new(s.to_xml)
    top_groups = doc.root.get_elements("group")
    top_groups.length.should == 2
    top_groups.any? {|g| g.text == "Draft" }.should.be.true?
    top_groups.any? {|g| g.text == "Final" }.should.be.true?

    media_elems = doc.root.get_elements("media")
    media_elems[0].get_elements("group").length.should == 1
    media_elems[0].get_elements("group")[0].text.should == mf.groups[0]

    media_elems[1].get_elements("group").should.be.empty?
  end

  it "should write notes" do
    s = CineSync::Session.new
    s.notes = "asdf"
    mf = CineSync::MediaFile.new("http://example.com/random_file.mov")
    mf.notes = "fancy media notes!"
    s.media << mf

    doc = REXML::Document.new(s.to_xml)
    doc.root.get_elements("notes")[0].text.should == s.notes
    doc.root.elements["media/notes"].text.should == mf.notes
  end

  it "should write user data" do
    s = CineSync::Session.new
    s.user_data = "asdf"
    mf = CineSync::MediaFile.new("http://example.com/random_file.mov")
    mf.user_data = '{"id":"1234QWERTY"}'
    s.media << mf

    doc = REXML::Document.new(s.to_xml)
    doc.root.attributes["userData"].should == s.user_data
    doc.root.get_elements("media")[0].attributes["userData"].should == mf.user_data
  end

  it "should write frame notes" do
    s = CineSync::Session.new
    mf = CineSync::MediaFile.new("http://example.com/random_file.mov")
    mf.annotations[33].notes = "A note on frame 33"
    s.media << mf

    doc = REXML::Document.new(s.to_xml)
    ann_elem = doc.elements["session/media/annotation"]
    ann_elem.attributes["frame"].should == "33"
    ann_elem.elements["notes"].text.should == "A note on frame 33"
  end
end
