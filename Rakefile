require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cinesync"
    gem.summary = %Q{Library for scripting the cineSync collaborative video review tool}
    gem.description = <<-EOF
      This gem provides a Ruby interface to the cineSync session file format,
      which is used by cineSync's scripting system. Use it to integrate
      cineSync into your workflow.
    EOF
    gem.email = ["jmah@cinesync.com", "info@cinesync.com"]
    gem.homepage = "http://github.com/jmah/cinesync"
    gem.authors = ["Jonathon Mah", "Rising Sun Research"]
    gem.add_dependency "activesupport", ">= 2.3"
    gem.add_dependency "andand", ">= 1.3.1"
    gem.add_dependency "builder", ">= 2.1"
    gem.add_development_dependency "bacon", ">= 1.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |spec|
    spec.libs << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cinesync #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
