# Inspiration shamelessly stolen from
# http://gravityblast.com/2009/08/11/testing-rails-generators-with-cucumber/

# $:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rubygems"
gem "railties", ">= 3.0.0.beta2"

require "fileutils"
require "tempfile"

class String
  def strip_ansi
    gsub /\e\[\d+m/, ''
  end
end

module GeneratorHelpers
  if ENV['VERBOSE'] == 'true'
    include FileUtils::Verbose
  else
    include FileUtils
  end
  
  def generate_rails_app(name = 'rails_app')
    @current_app = name
    workspace do
      run "rails #{name}"
    end
  end
  
  def add_engineer_gem
    install_engineer_gem_to_workspace_repo
    workspace @current_app do
      File.open('Gemfile', 'a') do |gemfile|
        gemfile << "gem 'engineer', '>= 0.0.0'\n"
      end
      run "GEM_HOME='#{workspace 'gemrepo'}' bundle install"
    end
  end

  def generate(generator)
    workspace @current_app do
      run "rails g #{generator}"
    end
  end

  def rake(rake_task)
    workspace @current_app do
      run "rake #{rake_task}"
    end
  end
  
  def latest_output
    @latest_output
  end
  
private

  def install_engineer_gem_to_workspace_repo
    @engineer_gem_installed_to_workspace_repo ||= begin
      repo_path = workspace 'gemrepo'
      mkdir_p repo_path
      run "GEM_HOME='#{repo_path}' gem install --no-rdoc --no-ri #{engineer_gem_file}"
      true
    end
  end

  def engineer_gem_file
    project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    Dir["#{project_root}/pkg/engineer*gem"].first
  end

  def run(cmd)
    log cmd
    (`#{cmd}`).tap do |output|
      @latest_output = output
      log output
      fail unless $?.to_i == 0
    end
  end
  
  def workspace(path = nil)
    @workspace ||= File.join(Dir::tmpdir, "engineer-cucumber-#{$$}").tap do |tmpdir|
      mkdir_p tmpdir
      at_exit { rm_rf tmpdir }
    end
    
    absolute_path = path ? File.join(@workspace, path) : @workspace
    
    if block_given?
      Dir.chdir(absolute_path) do
        log "cd #{absolute_path}"
        yield
      end
    else
      absolute_path
    end
  end
  
  def log(message)
    puts message if ENV['VERBOSE'] == 'true'
  end

end

World(GeneratorHelpers)

Given "I have a new rails app named $name" do |name|
  generate_rails_app name
end

Given "I have a new rails app" do
  generate_rails_app
end

Given "I add the engineer gem" do
  add_engineer_gem
end

When "I rails g $generator" do |generator|
  generate generator
end

Then "I should see output:" do |command_output|
  latest_output.strip_ansi.strip.should include command_output.strip
end

When "I rake $rake_task" do |rake_task|
  rake rake_task
end
