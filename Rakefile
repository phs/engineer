require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "engineer"
    gem.summary = %Q{Turn rails 3 applications into engines}
    gem.description = %Q{Turn your rails 3 app into an embeddable engine gem, with answers for db migrations, static assets and more.}
    gem.email = "phil.h.smith@gmail.com"
    gem.homepage = "http://github.com/phs/engineer"
    gem.authors = ["Phil Smith"]
    gem.files =  FileList["[A-Z]*", "{features,lib,spec}/**/*"]
    gem.add_dependency "jeweler", ">= 1.4.0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "cucumber", ">= 0.6.4"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => [:spec, :cucumber]

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "engineer #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format pretty}
end

desc "Remove build products"
task :clean do
  rm_rf 'pkg'
end

# Some steps expect the gem to be built, so it can be added to rails projects created in tests.
task :cucumber => [:clean, :build]
