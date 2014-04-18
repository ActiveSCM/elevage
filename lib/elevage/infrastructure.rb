module Elevage
  class Vcenter
    attr_accessor :geo
    attr_accessor :timezone
    attr_accessor :host
    attr_accessor :datacenter
    attr_accessor :imagefolder
    attr_accessor :destfolder
    attr_accessor :resourcepool
    attr_accessor :appendenv
    attr_accessor :appendtier
    attr_accessor :datastore
    attr_accessor :domain
    attr_accessor :dnsips

    def initialize(infradata)
      @geo = infradata.fetch('geo')
      @timezone = infradata.fetch('timezone')
      @host = infradata.fetch('host')
      @datacenter = infradata.fetch('datacenter')
      @imagefolder = infradata.fetch('imagefolder')
      @destfolder = infradata.fetch('destfolder')
      @resourcepool = infradata.fetch('resourcepool')
      @appendenv = infradata.fetch('appendenv')
      @appendtier = infradata.fetch('appendtier')
      @datastore = infradata.fetch('datastores')
      @domain = infradata.fetch('domain')
      @dnsips = infradata.fetch('dnsips')
    end

    def to_s
      s = "\t\tgeo: #{@geo}\n"
      s += "\t\ttimezone: #{@timezone}\n"
      s += "\t\thost: #{@host}\n"
      s += "\t\tdatacenter: #{@datacenter}\n"
      s += "\t\timagefolder: #{@imagefolder}\n"
      s += "\t\tdestfolder: #{@destfolder}\n"
      s += "\t\tresourcepool: #{@resourcepool}\n"
      s += "\t\tappendenv: #{@appendenv}\n"
      s += "\t\tappendtier: #{@appendtier}\n"
      @datastore.each do |store|
        s += "\t\t\t- #{store}\n"
      end
      s += "\t\tdomain: #{@domain}\n"
      @dnsips.each do |ip|
        s += "\t\t\t- #{ip}\n"
      end
      s
    end
  end

  class Network
    attr_accessor :vlandid
    attr_accessor :gateway
    attr_accessor :netmask

    def initialize(networkdata)
      @vlanid = networkdata.fetch('vlanid')
      @gateway = networkdata.fetch('gateway')
      @netmask = networkdata.fetch('netmask')
    end

    def to_s
      s = "\t\tvlanid: #{@vlanid}\n"
      s += "\t\tgateway: #{@gateway}\n"
      s += "\t\tnetmask: #{@netmask}\n"
      s
    end
  end
end