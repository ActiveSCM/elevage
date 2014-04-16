module Elevage
  class Infrastructure
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
      puts "\t\t#{@geo}\n"
      puts "\t\t#{@timezone}\n"
      puts "\t\t#{@host}\n"
      puts "\t\t#{@datacenter}\n"
      puts "\t\t#{@imagefolder}\n"
      puts "\t\t#{@destfolder}\n"
      puts "\t\t#{@resourcepool}\n"
      puts "\t\t#{@appendenv}\n"
      puts "\t\t#{@appendtier}\n"
      puts "\t\t#{@datastore}\n"
      puts "\t\t#{@domain}\n"
      puts "\t\t#{@dnsips}\n"
    end
  end

  class Network
    attr_accessor :vlandid
    attr_accessor :gateway
    attr_accessor :netmask

    def initialize(networkdata)
      @vlandid = networkdata.fetch('vlanid')
      @gateway = networkdata.fetch('gateway')
      @netmask = networkdata.fetch('netmask')
    end

    def to_s
      "\t\t#{@vlanid}\n" + "\t\t#{@gateway}\n" + "\t\t#{@netmask}\n"
      # puts "\t\t#{@vlanid}\n"
      # puts "\t\t#{@gateway}\n"
      # puts "\t\t#{@netmask}\n"
    end
  end
end