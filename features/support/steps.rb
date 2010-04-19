require File.expand_path(File.dirname(__FILE__) + '/env')

Given %r{I have a new rails app named (.*), with the (.*) gems?} do |name, gems|
  gem_files = gems.split(',').collect do |gem_name|
    gem_name.strip!
    if gem_name == 'engineer'
      ENGINEER_GEM_FILE
    else
      Dir["#{in_current_scenario(gem_name)}/pkg/#{gem_name}-*.gem"].first
    end
  end

  generate_rails_app name, gem_files
end

When "I rails g $generator" do |generator|
  generate generator
end

When "I try to rails g $generator" do |generator|
  generate generator, :may_fail => true
end

When "I rake $rake_task" do |rake_task|
  rake rake_task
end

When "I try to rake $rake_task" do |rake_task|
  rake rake_task, :may_fail => true
end

When "I fill out my Rakefile gemspec" do
  fill_out_the_rakefile_gemspec
end

Then "I should see output:" do |command_output|
  latest_output.strip_ansi.strip.should include command_output.strip
end

Then "$file should contain:" do |file, content|
  File.read(in_current_app file).should match strip_wildcards(content)
end

Then "$file should not contain:" do |file, content|
  File.read(in_current_app file).should_not match strip_wildcards(content)
end

Then "I should see a $file file" do |file|
  File.exists?(in_current_app file).should be_true
end

Given "I have a finished engine application named $engine" do |engine|
  Given "I have a new rails app named #{engine}, with the engineer gem"
    And "I rails g engineer:install"
    And "I rake version:write"
    And "I fill out my Rakefile gemspec"
    And "I rake build"
end
