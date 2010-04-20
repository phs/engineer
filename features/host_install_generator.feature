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
      rake my_engine:assets                     # Link (or copy) my_engine's static assets
      rake my_engine:db:migrate                 # Import my_engine's migrations
      rake my_engine:db:seed                    # Load my_engine's seed data
      rake my_engine:update                     # Update all of my_engine's related resources
      """

    And I should see output:
      """
      rake engines:assets                       # Link (or copy) static assets from all engines
      rake engines:db:migrate                   # Import migrations from all engines
      rake engines:db:seed                      # Load seed data from all engines
      rake engines:update                       # Update related resources from all engines
      """
