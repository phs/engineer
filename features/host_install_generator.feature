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
              rake  my_engine:assets my_engine:db:schema my_engine:db:migrate
      """

    And I should see output:
      """
      rm -rf /${HOST_PATH}/host/public/my_engine
      ln -s /${GEM_REPO}/gems/my_engine-0.0.0/public /${HOST_PATH}/host/public/my_engine
      """

    When I rake -T
    Then I should see output:
      """
      rake my_engine:assets[copy]               # Link (or copy) my_engine's static assets
      rake my_engine:db:migrate                 # Import my_engine's new db migrations
      rake my_engine:db:schema                  # Import my_engine's schema as a db migration
      rake my_engine:db:seed                    # Load my_engine's seed data
      rake my_engine:update                     # Import my_engine's assets and new db migrations
      """

    And I should see output:
      """
      rake engines:assets[copy]                 # Link (or copy) static assets from all engines
      rake engines:db:migrate                   # Import new migrations from all engines
      rake engines:db:seed                      # Load seed data from all engines
      rake engines:update                       # Import assets and new db migrations from all engines
      """

    When I rake my_engine:assets[true]
    Then I should see output:
      """
      rm -rf /${HOST_PATH}/host/public/my_engine
      cp -r /${GEM_REPO}/gems/my_engine-0.0.0/public /${HOST_PATH}/host/public/my_engine
      """
