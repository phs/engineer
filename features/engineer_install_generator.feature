Feature: Engineer Installation
  As an engine author
  I want to install engineer painlessly
  So that I can turn my rails app into an embeddable engine
  
  Background:
    Given I have a new rails app named my_engine, with the engineer gem
  
  Scenario: Install engineer, see my new rake tasks
    When I rails g engineer:install
    Then I should see output:
      """
             exist  lib
            create  lib/my_engine/engine.rb
            create  lib/my_engine.rb
            create  lib/generators/my_engine/install/install_generator.rb
            create  lib/generators/my_engine/install/templates/my_engine.rake
            create  lib/generators/my_engine/install/USAGE
            create  app/controllers/my_engine
            create  app/controllers/my_engine/application_controller.rb
            remove  app/controllers/application_controller.rb
            append  Rakefile
              gsub  config/routes.rb
      """

    And config/routes.rb should contain:
      """
      Rails.application.routes.draw
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
