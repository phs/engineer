# Inspiration shamelessly stolen from
# http://gravityblast.com/2009/08/11/testing-rails-generators-with-cucumber/

require "rubygems"
gem "railties", ">= 3.0.0.beta2"

require "fileutils"
require "tempfile"

class String
  def strip_ansi
    gsub /\e\[\d+m/, ''
  end
end

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
ENGINEER_GEM_FILE = Dir["#{PROJECT_ROOT}/pkg/engineer*gem"].first

module Helpers
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
      run "#{gem_home} bundle install"
    end
  end

  def generate(generator, options = {})
    workspace @current_app do
      run "#{gem_home} bundle exec rails g #{generator}", options
    end
  end

  def rake(rake_task, options = {})
    workspace @current_app do
      run "#{gem_home} bundle exec rake #{rake_task}", options
    end
  end

  def fill_out_the_rakefile_gemspec
    workspace @current_app do
      rakefile = File.read('Rakefile')
      rakefile.gsub! 'gem.name = "TODO"',                                          "gem.name = \"#{@current_app}\""
      rakefile.gsub! 'gem.summary = %Q{TODO: one-line summary of your gem}',       'gem.summary = %Q{My awesome engine}'
      rakefile.gsub! 'gem.description = %Q{TODO: longer description of your gem}', 'gem.description = %Q{My awesome, beautiful engine}'
      rakefile.gsub! 'gem.email = "TODO"',                                         'gem.email = "awesome-beautiful-me@example.com"'
      rakefile.gsub! 'gem.homepage = "TODO"',                                      'gem.homepage = "http://example.com/"'
      rakefile.gsub! 'gem.authors = ["TODO"]',                                     'gem.authors = ["Awesome, Beautiful Me"]'
      File.open('Rakefile', 'w') { |f| f << rakefile }
    end
  end
  
  def latest_output
    @latest_output
  end
  
private

  def install_engineer_gem_to_workspace_repo
    @engineer_gem_installed_to_workspace_repo ||= begin
      run "#{gem_home} gem install --no-rdoc --no-ri #{ENGINEER_GEM_FILE}"
      true
    end
  end

  def run(cmd, options = {})
    log cmd
    (`#{cmd} 2>&1`).tap do |output|
      @latest_output = output
      log output
      fail unless $?.to_i == 0 or options[:may_fail]
    end
  end
  
  def workspace(path = nil)
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
  
  def gem_home
    @gem_home ||= begin
      repo_path = workspace 'gemrepo'
      mkdir_p repo_path
      "GEM_HOME='#{repo_path}'"
    end
  end

  def log(message)
    puts message if ENV['VERBOSE'] == 'true'
  end

end

Before do
  @workspace ||= File.join(Dir::tmpdir, "engineer-cucumber-#{$$}").tap do |tmpdir|
    mkdir_p tmpdir
    at_exit { rm_rf tmpdir }
  end
end

After do
  rm_rf @workspace
end

World(Helpers)
