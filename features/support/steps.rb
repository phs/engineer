require File.expand_path(File.dirname(__FILE__) + '/env')

Given %r{I have a new rails app named (.*), with the (.*) gems?} do |name, gems|
  generate_rails_app name
  gems.split(',').each do |gem_name|
    gem_name.strip!
    if gem_name == 'engineer'
      gem_file = ENGINEER_GEM_FILE
    else
      gem_file = Dir["#{in_current_scenario(gem_name)}/pkg/#{gem_name}-*.gem"].first
    end
    add_gem gem_file
  end
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
  in_current_scenario do
    File.read(file).should include content
  end
end

Then "I should see a $file file" do |file|
  in_current_scenario do
    File.exists?(file).should be_true
  end
end

Given "I have a finished engine application named $engine" do |engine|
  Given "I have a new rails app named #{engine}, with the engineer gem"
    And "I rails g engineer:install"
    And "I rake version:write"
    And "I fill out my Rakefile gemspec"
    And "I rake build"
end

Given 'I even get here' do
  puts "I got here!"
end
