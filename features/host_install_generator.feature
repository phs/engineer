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
    