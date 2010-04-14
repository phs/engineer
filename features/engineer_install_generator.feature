Feature: Engineer Installation
  As an engine author
  I want to install engineer painlessly
  So that I can turn my rails app into an embeddable engine
  
  Background:
    Given I have a new rails app named engine
    And I add the engineer gem
  
  Scenario: Install engineer, see my new rake tasks
    When I rails g engineer:install
    Then I should see output:
      """
            append  Rakefile
      """

    When I rake -T
    Then I should see output:
      """
      rake build                                # Build gem
      """
    And I should see output:
      """
      rake version:bump:major                   # Bump the gemspec by a major version.
      rake version:bump:minor                   # Bump the gemspec by a minor version.
      rake version:bump:patch                   # Bump the gemspec by a patch version.
      rake version:write                        # Writes out an explicit version.
      """
