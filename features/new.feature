Feature: creating NEW platform definition files

  As an Infracoder developing a command line tool
  I want to test the accuracy of the files and folders created by the NEW command
  In order to maintain the health of the elevage generator commands

  Scenario: generating new platform

    When I run `elevage new default_app`
    Then the following files should exist:
      |platform.yml|
      |infrastructure/vcenter.yml|
      |infrastructure/compute.yml|
      |infrastructure/network.yml|
    And the file "platform.yml" should contain:
    """
    platform:
      name: default_app
    """
    And the file "infrastructure/vcenter.yml" should contain:
    """
    vcenter:
      name: default_app
    """
    And the file "infrastructure/network.yml" should contain:
    """
    network:
      name: default_app
    """
    And the file "infrastructure/compute.yml" should contain:
    """
    compute:
      name: default_app
    """

  Scenario: new platform called when platform already exists

    Given a file named "platform.yml" with:
    """
    platform:
      name: default_app
    """
    When I run `elevage new default_app`
    Then the exit status should be 1
    And the result should contain "elevage: platform files already exist!"
