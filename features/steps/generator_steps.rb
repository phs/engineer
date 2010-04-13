require File.expand_path(File.dirname(__FILE__) + '/env')

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
