Feature: Engine Installation into a Host App
  As an host application author
  I want to install an engine painlessly
  So that I can use it in my app

  Background:
    Given I have a finished engine application named my_engine
    And I have a new rails app named host, with the my_engine gem

  Scenario: Install my_engine
    When I rails g --help
    Then I should see output:
      """
        my_engine:install
      """

    When I rails g my_engine:install
    Then I should see output:
      """
             exist  lib/tasks
            create  lib/tasks/my_engine.rake
      """

    When I rake -T
    Then I should see output:
      """
      rake my_engine:assets                     # Copy my_engine's static assets to public
      rake my_engine:db:migrate                 # Copy new my_engine migrations for use
      rake my_engine:db:seed                    # Load my_engine's seed data
      rake my_engine:update                     # Update my_engine's static assets and migrations
      """
