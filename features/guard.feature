Feature: GUARD platform yml file health status

  As an Infracoder developing a command line tool
  I want to test the semantic accuracy of the platform definition files
  In order to maintain the health of the elevage platform desired state files


  Scenario: Guard simple command called where platform definition file is missing

    Given the following files exist:
      |infrastructure/vcenter.yml|
      |infrastructure/network.yml|
      |infrastructure/compute.yml|
    When I run `elevage guard simple`
    Then the exit status should be 1
    And the output should contain the platform Not Found error

  Scenario: Guard simple command called where vcenter definition file is missing

    Given the following files exist:
      |platform.yml|
      |infrastructure/network.yml|
      |infrastructure/compute.yml|
    When I run `elevage guard simple`
    Then the exit status should be 1
    And the output should contain the vcenter Not Found error

  Scenario: Guard simple command called where network definition file is missing

    Given the following files exist:
      |platform.yml|
      |infrastructure/vcenter.yml|
      |infrastructure/compute.yml|
    When I run `elevage guard simple`
    Then the exit status should be 1
    And the output should contain the network Not Found error

  Scenario: Guard simple command called where compute definition file is missing

    Given the following files exist:
      |platform.yml|
      |infrastructure/vcenter.yml|
      |infrastructure/network.yml|
    When I run `elevage guard simple`
    Then the exit status should be 1
    And the output should contain the compute Not Found error


  Scenario: Guard simple command called where environment definition file is missing

    Given a file named "platform.yml" with:
    """
    platform:
      name: default_app
      description: Description of the default_app

      environments:
        - dev
    """
    Given a file named "infrastructure/vcenter.yml" with:
    """
    vcenter:
      name: default_app
    """
    Given a file named "infrastructure/network.yml" with:
    """
    network:
      name: default_app
    """
    Given a file named "infrastructure/compute.yml" with:
    """
    compute:
      name: default_app
    """
    When I run `elevage guard simple`
    Then the exit status should be 1

  Scenario: Guard simple command called with all environment definition files present

    Given a file named "platform.yml" with:
    """
    platform:
      name: default_app
      description: Description of the default_app

      environments:
        - dev
    """
    Given a file named "infrastructure/vcenter.yml" with:
    """
    vcenter:
      name: default_app
    """
    Given a file named "infrastructure/network.yml" with:
    """
    network:
      name: default_app
    """
    Given a file named "infrastructure/compute.yml" with:
    """
    compute:
      name: default_app
    """
    Given a file named "environments/dev.yml" with:
    """
    environment:
      name: dev
    """
    When I run `elevage guard simple`
    Then the exit status should be 0
    Then the output should display simple health success in the results from the guard health check