Feature: GUARD platform yml file health status

  As an Infracoder developing a command line tool
  I want to test the semantic accuracy of the platform definition files
  In order to maintain the health of the platform desired state files for use with elevage


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


  Scenario: Guard platform called with configured files in healthy state

    Given a file named "platform.yml" with:
    """
    ? "%YAML 1.2"
    platform:
      name: AW
      description: 'ActiveWorks platform - includes markets'

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
        - geo1

      pool:

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

        #---------------------------------------------- Web tier

        api:
          <<: *webvmdefaults
          port: 8080

        cui:
          <<: *webvmdefaults
          port: 8082

        terracotta:
          <<: *webvmdefaults
          port: 0000
          compute: nonprodtc
          image: 'aw-nonprod-oel6-32g_20130815'

        #---------------------------------------------- App tier

        email:
          <<: *appvmdefaults
          port: 8130

        mq:
          <<: *appvmdefaults
          port: 1234
          compute: nonprodmq
          image: 'aw-nonprod-oel6-32g_20130815'
    """
    Given a file named "infrastructure/vcenter.yml" with:
    """
    ? "%YAML 1.2"
    vcenter:
      name: AW

      locations:
        nonprod: &vcenter
          geo: west
          timezone: 085

          host: 'vcwest.active.tan'
          datacenter: 'WCDC NonProd'
          imagefolder: 'Corporate - o4/Platform Services - o4.m7/Templates'
          destfolder: 'Corporate - o4/Platform Services - o4.m7/AW Platform - o4.m7.p159'
          resourcepool: 'App-Web Linux/Corporate - o4'
          appendenv: true
          appenddomain: true
          datastores:
            - NonProd_Cor_PlaSer_25_111
            - NonProd_Cor_PlaSer_26_111
            - NonProd_Cor_PlaSer_38_111
            - NonProd_Cor_PlaSer_39_111
            - NonProd_Cor_PlaSer_40_111
            - NonProd_Cor_PlaSer_41_111

          domain: dev.activenetwork.com
          dnsips:
            - 10.119.32.5
            - 10.119.32.6

        prod:
          <<: *vcenter

          datacenter: 'WCDC Prod'
          datastores:
            - Prod_Cor_PlaSer_03_237
            - Prod_Cor_PlaSer_04_237
            - Prod_Cor_PlaSer_06F9_473
            - Prod_Cor_PlaSer_06F9_473
            - Prod_Cor_PlaSer_080D_473
            - Prod_Cor_PlaSer_0812_473
            - Prod_Cor_PlaSer_08E0_473
            - Prod_Cor_PlaSer_08EA_473
            - Prod_Cor_PlaSer_08F4_473
            - Prod_Cor_PlaSer_0B89_473
            - Prod_Cor_PlaSer_0B93_473
            - Prod_Cor_PlaSer_847_473
            - Prod_Cor_PlaSer_851_473

          domain: active.tan
          dnsips:
            - 10.119.10.201
            - 10.73.100.21
    """
    Given a file named "infrastructure/network.yml" with:
    """
    ? "%YAML 1.2"
    network:
      name: AW

      devweb:
        vlanid: DEV_WEB_NET
        gateway: '10.219.128.1'
        netmask: 19

      devapp:
        vlanid: DEV_APP_NET
        gateway: '10.219.160.1'
        netmask: 20

      prodweb:
        vlanid: prd-web-10.119.128.0%2f20(2010)
        gateway: '10.119.128.1'
        netmask: 19

      prodapp:
        vlanid: prd-app-10.119.160.0%2f20(2020)
        gateway: '10.119.160.1'
        netmask: 20
    """
    Given a file named "infrastructure/compute.yml" with:
    """
    ? "%YAML 1.2"
    compute:
      name: AW

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

        nonprodpassporttc:
          <<: *default
          ram: 4

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

        prodpassporttc:
          <<: *default
          ram: 32

        prodsports:
          <<: *default
          ram: 3
    """
    Given a file named "environments/prod.yml" with:
    """
    ? "%YAML 1.2"
    environment:
      vcenter: prod

      tier: &tier
        Web:
          network: prodweb

        App:
          network: prodapp

      webvmdefaults: &webvmdefaults
        count: 4
        compute: prodweb

      appvmdefaults: &appvmdefaults
        <<: *webvmdefaults
        compute: prodapp


      components:

      #---------------------------------------------- Web tier

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

        #----------------------------------------------

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
    Given a file named "environments/int.yml" with:
    """
    ? "%YAML 1.2"
    environment:
      vcenter: nonprod

      tier: &tier
        Web:
          network: devweb

        App:
          network: devapp


      components:

      #---------------------------------------------- Web tier

        api:
            addresses:
                - 10.219.137.42
                - 10.219.137.43

        cui:
            addresses:
                - 10.219.137.64
                - 10.219.137.65

        terracotta:
            addresses:
                - 10.219.137.95
                - 10.219.137.96

        #---------------------------------------------- App tier

        email:
            addresses:
                - 10.219.161.53
                - 10.219.161.54

        mq:
            addresses:
                - 10.219.161.77
                - 10.219.161.78
    """
    When I run `elevage guard platform`
    Then the exit status should be 0