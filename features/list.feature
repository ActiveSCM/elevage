Feature: LIST platform definition file items

  As an Infracoder developing a command line tool
  I want to display vcenters, networks, components, and other desired elements in the platform files
  In order to maintain the health of the elevage platform definition files

  Scenario: list environments

    Given a file named "platform.yml" with:
    """
    platform:
      name: default_app
      description: Description of the default_app

      environments:
        - dev

      tiers:
        - web
        - db

      pools:
        webvmdefaults: &webvmdefaults
          count: 2
          tier: Web
          image: 'aw-nonprod-oel6_20130815'
          compute: nonprodweb

        appvmdefaults: &appvmdefaults
          <<: *webvmdefaults
          tier: App
          compute: nonprodapp

      components:
        api:
          <<: *webvmdefaults
          port: 8080
    """
    Given a file named "infrastructure/vcenter.yml" with:
    """
    vcenter:
      name: default_app

      locations:
        nonprod: &vcenter
    """
    Given a file named "infrastructure/network.yml" with:
    """
    network:
      name: default_app
      devweb:
        vlanid: DEV_WEB_NET
        gateway: '10.219.128.1'
        netmask: 19
    """
    Given a file named "infrastructure/compute.yml" with:
    """
    compute:
      name: default_app
      options:
        default: &default
          cpu: 2
          ram: 2
    """
    When I run `elevage list environments`
    Then the exit status should be 0
    And the result should contain "dev"

    When I run `elevage list tiers`
    Then the exit status should be 0
    And the result should contain "web\ndb"

    When I run `elevage list pools`
    Then the exit status should be 0
    And the result should contain "webvmdefaults"

    When I run `elevage list components`
    Then the exit status should be 0
    And the result should contain "api"

    When I run `elevage list vcenter`
    Then the exit status should be 0
    And the result should contain "nonprod"

    When I run `elevage list compute`
    Then the exit status should be 0
    And the result should contain "ram"

    When I run `elevage list networks`
    Then the exit status should be 0
    And the result should contain "devweb"

    When I run `elevage list unknown`
    Then the exit status should be 1
    And the result should contain "unknown LIST command"


