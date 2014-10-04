require_relative 'constants'
require_relative 'platform'

Module Elevage
  class Provisioner

    def initialize(environment)

      @env = environment
      @vcenter = @env.vcenter
      @username = ENV['ELEVAGE_USER'] || ENV['USER']
      @password = ENV['ELEVAGE_PASSWORD']

    end

    # It'll all eventually boil down to building a massive 'knife vsphere' command
    # def build_knife_cmd
    #
    #   knife_cmd = "knife vsphere vm clone"
    #   knife_cmd << " --vsuser " << username
    #   knife_cmd << " --vspass " << password
    #   knife_cmd << " --vshost " << @env.vcenter['host']
    #   knife_cmd << " --vsdc " << @env.vcenter['datacenter']
    #   knife_cmd << " --dest-folder " << @env.vcenter['destfolder']
    #   knife_cmd << " --datastore " << @env.vcenter['datastores'][0]
    #   knife_cmd << " --cvlan " << @env.vcenter[rand(@env.vcenter.datastores.count)]
    #   knife_cmd << " --cips $cips"
    #   knife_cmd << " --cdnsips $cdnsips"
    #   knife_cmd << " --cgw $cgw"
    #   knife_cmd << " --chostname $chostname"
    #   knife_cmd << " --cdomain $cdomain"
    #   knife_cmd << " --cdnssuffix $cdnssuffix"
    #   knife_cmd << " --ctz $ctz"
    #   knife_cmd << " --ccpu $ccpu"
    #   knife_cmd << " --cram $cram"
    #   knife_cmd << " --start --vsinsecure"
    #   knife_cmd << " --folder $folder"
    #   knife_cmd << " --template $template"
    #   knife_cmd << " --resource-pool $resourcepool"
    #   knife_cmd << " --bootstrap"
    #   knife_cmd << " --template-file $templatefile"
    #   knife_cmd << " --fqdn $ipaddr"
    #   knife_cmd << " --ssh-user $sshuser"
    #   knife_cmd << " --identity-file $identityfile"
    #   knife_cmd << " --node-name $nodename"
    #   knife_cmd << " --run-list $runlist"
    #   knife_cmd << " --environment $chefenvironment"
    #   knife_cmd << " --bootstrap-version $bootstrapversion"
    #   knife_cmd << " $hname.$($config.environment.dns.cdomain)"
    #
    # end

  end
end