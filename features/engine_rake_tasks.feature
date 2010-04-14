Feature: Rake Tasks added to Engines
  As an engine author
  I want to pack my app as a gem the same way I do with jeweler
  Since I probably already know how to use jeweler
  
  Background:
    Given I have a new rails app named engine
    And I add the engineer gem
    And I rails g engineer:install
  
  Scenario: Creating initial VERSION file
    When I try to rake version:bump:patch
    Then I should see output:
      """
      Expected VERSION or VERSION.yml to exist. See version:write to create an initial one.
      """
    
    When I rake version:write
    Then engine/VERSION should contain:
      """
      0.0.0
      """
  
  Scenario: Bumping versions
    Given I rake version:write
    When I rake version:bump:patch
    Then I should see output:
      """
      Current version: 0.0.0
      Updated version: 0.0.1
      """
  
    When I rake version:bump:major
    Then I should see output:
      """
      Current version: 0.0.1
      Updated version: 1.0.0
      """
  
  Scenario: Building a gem
    Given I rake version:write
    And I fill out my Rakefile gemspec
    When I rake build
    Then I should see a engine/engine.gemspec file
    And I should see a engine/pkg/engine-0.0.0.gem file