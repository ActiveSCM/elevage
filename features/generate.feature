Feature: GENERATE new environment yml file

  As an Infracoder developing a command line tool
  I want to be able to automatically create a new environment file based on the platform definition
  In order to maintain the health of the elevage platform definition files

  Scenario: generate new environment file from the following platform definition

    Given a file named "platform.yml" with:
    """
    platform:
      name: app
      description: 'description of the app'

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
          ostype: 'linux'
          compute: nonprodweb
          port: 80
          runlist:
            - 'role[loc_uswest]'
            - 'role[base]'
          componentrole: 'role[#]'

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
      nonprod: &vcenter
        geo: west
        timezone: 085

        host: 'www.google.com'
        datacenter: 'WCDC NonProd'
        imagefolder: 'Corporate/Platform Services/Templates'
        destfolder: 'Corporate/Platform Services/app'
        resourcepool: 'App-Web Linux/Corporate'
        appendenv: true
        appenddomain: true
        datastore: 'NonProd_Cor'

        domain: dev.corp.local
        dnsips:
          - 10.10.10.5
          - 10.10.10.6

      prod:
        <<: *vcenter

        datacenter: 'WCDC Prod'
        datastore: 'Prod_Cor'

        domain: corp.local
        dnsips:
          - 10.20.100.5
          - 10.20.100.6
    """
    Given a file named "infrastructure/network.yml" with:
    """
  network:
      devweb:
        vlanid: DEV_WEB_NET
        gateway: 10.10.128.1
        netmask: 19

      devapp:
        vlanid: DEV_APP_NET
        gateway: 10.10.160.1
        netmask: 20

      prodweb:
        vlanid: PRD_WEB_NET
        gateway: 10.119.128.1
        netmask: 19

      prodapp:
        vlanid: PRD_APP_NET
        gateway: 10.119.160.1
        netmask: 20
    """
    Given a file named "infrastructure/compute.yml" with:
    """
    compute:
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

    When I run `elevage generate qa`
    Then the exit status should be 0
    And the output should contain "qa.yml added in environments folder"
    And the file "environments/qa.yml" should contain:
    """
    ? "%YAML 1.2"
    environment:
      vcenter:
      # Environment files are generated from the platform.yml defintion.
      #
      # You can override any of the default values based on the requirements
      # of this particular environment. Though typically you will only
      # want to override things like:
      #
      # count           The number of components in the load balance pool
      # compute         Size of compute resource to assign, defined in the compute.yml file
      # network         vlan the component nodes are attached
      # cspec           The name of any customization specification to apply
      #
      # Additionally, you must specify IP addresses for each node. The generate
      # command will create array placeholders based on the default Count
      #
      pools:
        webvmdefaults: &webvmdefaults
          network:

        appvmdefaults: &appvmdefaults
          <<: *webvmdefaults
          network:


      components:
        api:
          <<: *webvmdefaults
          addresses:
            -
            -

        cui:
          <<: *webvmdefaults
          addresses:
            -
            -

        terracotta:
          <<: *webvmdefaults
          addresses:
            -
            -

        email:
          <<: *appvmdefaults
          addresses:
            -
            -

        mq:
          <<: *appvmdefaults
          addresses:
            -
            -


    """
