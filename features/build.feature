Feature: Provisioning platform vm's

  As an Infracoder developing a command line tool
  I want to test the accuracy of the vm provisioning ability of the Build command
  In order to maintain the health of the elevage tool

  Scenario: build new environment

    Given a file named "platform.yml" with:
    """
    platform:
      name: app
      description: 'description of the app'

      environments:
        - int
        - qa
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

    Given a file named "environments/qa.yml" with:
    """
    environment:
      vcenter: nonprod

      pools:
        webvmdefaults: &webvmdefaults
          network: devweb

        appvmdefaults: &appvmdefaults
          <<: *webvmdefaults
          network: devapp

      components:
        api:
          <<: *webvmdefaults
          addresses:
            - 10.10.137.151
            - 10.10.137.152

        cui:
          <<: *webvmdefaults
          addresses:
            - 10.10.137.161
            - 10.10.137.162

        terracotta:
          <<: *webvmdefaults
          addresses:
            - 10.10.137.171
            - 10.10.137.172

        email:
          <<: *appvmdefaults
          addresses:
            - 10.10.161.111
            - 10.10.161.112

        mq:
          <<: *appvmdefaults
          addresses:
            - 10.10.161.121
            - 10.10.161.122

    """

    When I run `elevage build qa --component=mq --node=1 --dry-run`
    Then the exit status should be 0
#    And the output should contain:
#    """
#    Dry run requested, forcing concurrency to '1'.
#    Running Tasks: 0
#    Max Concurrency: 1
#    Wait status interval: 60
#    Current Child processes:
#    Queued Provisioners:
#     - qa-mq-01w
#    """
#    And the file "logs/qa-mq-01w.log" should contain:
#    """
#    knife vsphere vm clone --vsinsecure --start --vsuser svc_provisioner --vspass changeme --vshost www.google.com --folder Corporate/Platform Services/Templates --template centos32g-6.5-x86_64-20140714 --vsdc WCDC NonProd --dest-folder Corporate/Platform Services/default_app --datastore NonProd_Cor_25 --resource-pool App-Web Linux/Corporate --ccpu 2 --cram 12 --cvlan DEV_APP_NET --cips 10.10.161.121/20 --cdnsips 10.10.10.5,10.10.10.6 --cgw 10.10.160.1 --chostname qa-mq-01w --ctz 085 --cdomain app.dev.corp.local --cdnssuffix app.dev.corp.local --bootstrap --template-file chef-rull.erb --fqdn 10.10.161.121 --ssh-user knife --identity-file knife_rsa --node-name qa-mq-01w.app.dev.corp.local --run-list role[loc_uswest],role[base],role[aw-mq] --environment qa --bootstrap-version 11.4.0 qa-mq-01w.app.dev.corp.local
#    """
