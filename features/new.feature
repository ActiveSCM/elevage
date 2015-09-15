Feature: creating NEW platform definition files

  As an Infracoder developing a command line tool
  I want to test the accuracy of the files and folders created by the NEW command
  In order to maintain the health of the elevage generator commands

  Scenario: generating new platform

    When I run `elevage new app`
    Then the following files should exist:
      |platform.yml|
      |infrastructure/vcenter.yml|
      |infrastructure/compute.yml|
      |infrastructure/network.yml|
    And the file "platform.yml" should contain:
    """
    platform:
      name: app
    """
    And the file "infrastructure/vcenter.yml" should contain:
    """
    vcenter:
    """
    And the file "infrastructure/network.yml" should contain:
    """
    network:
    """
    And the file "infrastructure/compute.yml" should contain:
    """
    compute:
    """

  Scenario: generating new platform called when platform already exists

    Given a file named "platform.yml" with:
    """
    platform:
      name: app
    """
    When I run `elevage new app`
    Then the exit status should be 1
    And the output should contain "elevage: platform files already exist!"

#  Scenario: generating new platform with -chef option
#
#    When I run `elevage new app -chef`
#    Then the following files should exist:
#      |app_definition/platform.yml|
#      |app_definition/infrastructure/vcenter.yml|
#      |app_definition/infrastructure/compute.yml|
#      |app_definition/infrastructure/network.yml|
#    And the file "app_definition/platform.yml" should contain:
#    """
#    platform:
#      name: app
#    """
#    And the file "app_definition/infrastructure/vcenter.yml" should contain:
#    """
#    vcenter:
#    """
#    And the file "app_definition/infrastructure/network.yml" should contain:
#    """
#    network:
#    """
#    And the file "app_definition/infrastructure/compute.yml" should contain:
#    """
#    compute:
#    """
