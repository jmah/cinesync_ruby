# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cinesync}
  s.version = "0.9.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonathon Mah", "Rising Sun Research"]
  s.date = %q{2010-05-08}
  s.description = %q{      This gem provides a Ruby interface to the cineSync session file format,
      which is used by cineSync's scripting system. Use it to integrate
      cineSync into your workflow.
}
  s.email = ["jmah@cinesync.com", "info@cinesync.com"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "Samples/Export Notes to CSV.rb",
     "VERSION",
     "cineSync Session v3 Schema.rnc",
     "lib/cinesync.rb",
     "lib/cinesync/color_grading.rb",
     "lib/cinesync/event_handler.rb",
     "lib/cinesync/frame_annotation.rb",
     "lib/cinesync/mask.rb",
     "lib/cinesync/media_file.rb",
     "lib/cinesync/pixel_ratio.rb",
     "lib/cinesync/play_range.rb",
     "lib/cinesync/session.rb",
     "lib/cinesync/ui.rb",
     "lib/cinesync/ui/standard_additions.rb",
     "lib/cinesync/ui/win32_save_file_dialog.rb",
     "lib/cinesync/xml.rb",
     "lib/cinesync/zoom_state.rb",
     "test/helper.rb"
  ]
  s.homepage = %q{http://github.com/jmah/cinesync}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Library for scripting the cineSync collaborative video review tool}
  s.test_files = [
    "test/helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3"])
      s.add_runtime_dependency(%q<andand>, [">= 1.3.1"])
      s.add_runtime_dependency(%q<builder>, [">= 2.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3"])
      s.add_dependency(%q<andand>, [">= 1.3.1"])
      s.add_dependency(%q<builder>, [">= 2.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3"])
    s.add_dependency(%q<andand>, [">= 1.3.1"])
    s.add_dependency(%q<builder>, [">= 2.1"])
  end
end

