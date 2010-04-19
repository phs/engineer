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

if ENV['VERBOSE'] == 'true'
  include FileUtils::Verbose
else
  include FileUtils
end

module Helpers
  def generate_rails_app(name = 'rails_app', gem_files = [])
    @current_app = name

    unless File.exists?(in_workspace "apps", name)
      in_workspace "apps" do
        run "rails #{name}"
      end

      in_workspace "apps", @current_app do
        gem_files.each do |gem_file|
          gem_name, version = File.basename(gem_file).match(/(.*)-(\d+\.\d+\.\d+)\.gem/)[1..2]
          install_gem gem_file
          File.open('Gemfile', 'a') do |gemfile|
            gemfile << "gem '#{gem_name}', '#{version}'\n"
          end
        end

        run "#{gem_home} bundle install"
      end
    end

    cp_r in_workspace("apps", @current_app), in_current_app
  end

  def generate(generator, options = {})
    in_current_app do
      run "#{gem_home} bundle exec rails g #{generator}", options
    end
  end

  def rake(rake_task, options = {})
    in_current_app do
      run "#{gem_home} bundle exec rake #{rake_task}", options
    end
  end

  def fill_out_the_rakefile_gemspec
    in_current_app do
      rakefile = File.read('Rakefile')
      rakefile.gsub! 'gem.summary = %Q{TODO: one-line summary of your engine}',       'gem.summary = %Q{My awesome engine}'
      rakefile.gsub! 'gem.description = %Q{TODO: longer description of your engine}', 'gem.description = %Q{My awesome, beautiful engine}'
      rakefile.gsub! 'gem.email = "TODO"',                                            'gem.email = "awesome-beautiful-me@example.com"'
      rakefile.gsub! 'gem.homepage = "TODO"',                                         'gem.homepage = "http://example.com/"'
      rakefile.gsub! 'gem.authors = ["TODO"]',                                        'gem.authors = ["Awesome, Beautiful Me"]'
      File.open('Rakefile', 'w') { |f| f << rakefile }
    end
  end

  def latest_output
    @latest_output
  end

private

  def install_gem(gem_file)
    @installed_gems ||= {}
    @installed_gems[gem_file] ||= begin
      run "#{gem_home} gem install --no-rdoc --no-ri #{gem_file}"
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

  def in_workspace(*path)
    absolute_path = File.join(WORKSPACE, *path)

    if block_given?
      Dir.chdir(absolute_path) do
        log "cd #{absolute_path}"
        yield
      end
    else
      absolute_path
    end
  end

  def in_current_scenario(*path, &block)
    in_workspace "current_scenario", *path, &block
  end

  def in_current_app(*path, &block)
    in_current_scenario @current_app, *path, &block
  end

  def gem_home
    @gem_home ||= begin
      repo_path = in_workspace 'gemrepo'
      mkdir_p repo_path
      "GEM_HOME='#{repo_path}'"
    end
  end

  def log(message)
    puts message if ENV['VERBOSE'] == 'true'
  end

end

# TODO: join from Dir::tmpdir once https://rails.lighthouseapp.com/projects/8994/tickets/4442 is in.
WORKSPACE = File.join("/tmp", "engineer-cucumber-#{$$}").tap do |tmpdir|
  mkdir_p tmpdir
  mkdir_p File.join(tmpdir, 'apps')
  at_exit { rm_rf tmpdir }
end

Before do
  mkdir_p in_current_scenario
end

After do
  rm_rf in_current_scenario
end

World(Helpers)
