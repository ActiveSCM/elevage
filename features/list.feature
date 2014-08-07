Feature: LIST platform definition file items

  As an Infracoder developing a command line tool
  I want to display vcenters, networks, components, and other desired elements in the platform files
  In order to maintain the health of the elevage platform definition files

  Scenario: list desired state items for platform and environment definitions

    Given a file named "platform.yml" with:
    """
    platform:
      name: default_app
      description: 'description of the default_app'

      environments:
        - int
        - prod

      tiers:
        - Web
        - App

      nodenameconvention:
        - environment
        - '-'
        - component
        - '-'
        - instance
        - geo

      pools:
        webvmdefaults: &webvmdefaults
          count: 2
          tier: Web
          image: 'centos-6.5-x86_64-20140714'
          compute: nonprodweb
          port: 0

        appvmdefaults: &appvmdefaults
          <<: *webvmdefaults
          tier: App
          compute: nonprodapp

      components:
        api:
          <<: *webvmdefaults
          port: 8080

        cui:
          <<: *webvmdefaults
          port: 8082

        terracotta:
          <<: *webvmdefaults
          compute: nonprodtc
          image: 'centos32g-6.5-x86_64-20140714'

        email:
          <<: *appvmdefaults
          port: 8130

        mq:
          <<: *appvmdefaults
          port: 1234
          compute: nonprodmq
          image: 'centos32g-6.5-x86_64-20140714'
    """
    Given a file named "infrastructure/vcenter.yml" with:
    """
    vcenter:
      name: default_app

      locations:
        nonprod: &vcenter
          geo: west
          timezone: 085

          host: 'vcwest.corp.local'
          datacenter: 'WCDC NonProd'
          imagefolder: 'Corporate/Platform Services/Templates'
          destfolder: 'Corporate/Platform Services/default_app'
          resourcepool: 'App-Web Linux/Corporate'
          appendenv: true
          appenddomain: true
          datastores:
            - NonProd_Cor_25
            - NonProd_Cor_26
            - NonProd_Cor_38
            - NonProd_Cor_39

          domain: dev.corp.local
          dnsips:
            - 10.10.10.5
            - 10.10.10.6

        prod:
          <<: *vcenter

          datacenter: 'WCDC Prod'
          datastores:
            - Prod_Cor_03
            - Prod_Cor_04

          domain: corp.local
          dnsips:
            - 10.20.100.5
            - 10.20.100.6
    """
    Given a file named "infrastructure/network.yml" with:
    """
    network:
      name: default_app

      devweb:
        vlanid: DEV_WEB_NET
        gateway: '10.10.128.1'
        netmask: 19

      devapp:
        vlanid: DEV_APP_NET
        gateway: '10.10.160.1'
        netmask: 20

      prodweb:
        vlanid: PRD_WEB_NET
        gateway: '10.119.128.1'
        netmask: 19

      prodapp:
        vlanid: PRD_APP_NET
        gateway: '10.119.160.1'
        netmask: 20
    """
    Given a file named "infrastructure/compute.yml" with:
    """
    compute:
      name: default_app

      options:
        default: &default
          cpu: 2
          ram: 2

        nonprodweb:
          <<: *default

        nonprodapp:
          <<: *default
          ram: 6

        nonprodtc:
          <<: *default
          ram: 8

        nonprodmq:
          <<: *default
          ram: 12

        prodweb:
          <<: *default
          ram: 6

        prodapp:
          <<: *default
          ram: 6

        prodtc:
          <<: *default
          ram: 32

        prodmq:
          <<: *default
          cpu: 8
          ram: 32
    """
    Given a file named "environments/int.yml" with:
    """
    environment:
      vcenter: nonprod

      pool:
        webvmdefaults: &webvmdefaults
            network: devweb
            compute: nonprodweb

        appvmdefaults: &appvmdefaults
          <<: *webvmdefaults
          network: devapp
          compute: nonprodapp

      components:
        api:
            addresses:
                - 10.10.137.42
                - 10.10.137.43

        cui:
            addresses:
                - 10.10.137.64
                - 10.10.137.65

        terracotta:
            addresses:
                - 10.10.137.95
                - 10.10.137.96

        email:
            addresses:
                - 10.10.161.53
                - 10.10.161.54

        mq:
            addresses:
                - 10.10.161.77
                - 10.10.161.78
    """
    Given a file named "environments/prod.yml" with:
    """
    environment:
      vcenter: prod

      pool:
        webvmdefaults: &webvmdefaults
            network: prodweb
            count: 4
            compute: prodweb

        appvmdefaults: &appvmdefaults
          <<: *webvmdefaults
          network: prodapp
          compute: prodapp


      components:
        api:
            addresses:
                - 10.119.137.72
                - 10.119.137.73
                - 10.119.137.74
                - 10.119.137.75

        cui:
            addresses:
                - 10.119.137.133
                - 10.119.137.134
                - 10.119.137.135
                - 10.119.137.136

        terracotta:
            count: 2
            compute: prodtc
            addresses:
                - 10.119.137.218
                - 10.119.137.219
            port: 0000

        email:
            addresses:
                - 10.119.161.137
                - 10.119.161.138
                - 10.119.161.139
                - 10.119.161.140

        mq:
            count: 2
            compute: prodmq
            addresses:
                - 10.119.161.206
                - 10.119.161.207
    """


    When I run `elevage list environments`
    Then the exit status should be 0
    And the result should contain "int\nprod"

    When I run `elevage list tiers`
    Then the exit status should be 0
    And the result should contain "Web\nApp"

    When I run `elevage list pools`
    Then the exit status should be 0
    And the result should contain "appvmdefaults:\n  count: 2\n  tier: App\n  image: centos-6.5-x86_64-20140714\n  compute: nonprodapp\n  port: 0"

    When I run `elevage list components`
    Then the exit status should be 0
    And the result should contain "terracotta:\n  count: 2\n  tier: Web\n  image: centos32g-6.5-x86_64-20140714\n  compute: nonprodtc\n  port: 0"

    When I run `elevage list vcenter`
    Then the exit status should be 0
    And the result should contain "prod:\n  geo: west\n  timezone: 085\n  host: vcwest.corp.local\n  datacenter: WCDC Prod"

    When I run `elevage list compute`
    Then the exit status should be 0
    And the result should contain "prodtc:\n  cpu: 2\n  ram: 32"

    When I run `elevage list networks`
    Then the exit status should be 0
    And the result should contain "prodweb:\n  vlanid: PRD_WEB_NET"

    When I run `elevage list prod`
    Then the exit status should be 0
    And the result should contain "vlanid: PRD_WEB_NET"
    And the result should contain "cpu: 2"
    And the result should contain "datacenter: WCDC Prod"

    When I run `elevage list prod -n`
    Then the exit status should be 0
    And the result should contain "prod-email-01w"

    When I run `elevage list unknown`
    Then the exit status should be 1
    And the result should contain "unknown LIST command"