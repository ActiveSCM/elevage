Feature: Generating platform definition files

  In order to maintain the generator commands that create the provisioning file structure
  As a developer using Cucumber
  I want to test the accuracy of the files and folders created by the NEW command

  Scenario: new platform
    When I run `elevage new default_app`
    Then the following files should exist:
      | default_app/platform.yml |
      | default_app/environments/dev.yml |
    Then the file "default_app/platform.yml" should contain:
    """
      name: default_app
    """
    Then the file "default_app/environments/dev.yml" should contain:
    """
      name: dev
    """

  Scenario: new platform called when platform already exists
    Given a directory named "default_app"
    When I run `elevage new default_app`
    Then the exit status should be 2
