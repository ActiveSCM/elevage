Feature: GUARD platform yml file health status

  As an Infracoder developing a command line tool
  I want to test the accuracy of the files created by the GENERATE command as edited
  In order to maintain the health of the elevage platform desired state files

  Scenario: General guard banner works

    Given a file named "platform.yml" with:
    """
    platform:
      name: default_app
    """
    When I run `elevage guard`
    Then the output should display the results from the guard health check
    And the exit status should be 0

  Scenario: Guard command called outside of platform definition folder

    When I run `elevage guard`
    Then the exit status should be 1
    And the output should contain the Platform Not Found error