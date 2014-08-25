# rubocop:disable LineLength, StringLiterals
module Elevage
  # messages
  DESC_VERSION = 'Display installed elevage gem version (Can also use -v)'
  DESC_NEW = 'Prepare new platform files and folder structure at current location'
  DESC_LIST = 'List ITEMs from platform desired state yml files'
  DESC_LIST_NODES = 'used with environment name to list node names and ip addresses'
  DESC_HEALTH = 'Complete desired state yml files Health check'
  DESC_GENERATE = 'Generate new environment files based on platform template'

  LIST_CMDS = %w(environments tiers pools components network vcenter compute)
  VALID_IP = "/^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/"

  MSG_HEALTH_SUCCESS = 'All platform desired state files present and consistently configured'
  HEALTH_MSG = {
    empty_environments: "Empty environment definitions\n",
    empty_tiers: "Empty tier definitions\n",
    empty_nodenameconvention: "Empty nodenameconvention definitions\n",
    pool_count_size: "Must define 1 or more nodes in a pool\n",
    invalid_tiers: "Pool contains invalid tier reference\n",
    no_image_ref: "No vm image referenced in pool definition\n",
    invalid_compute: "Pool contains invalid compute reference\n",
    invalid_port: "Pool contains invalid port definition\n",
    invalid_runlist: "No pool runlist definition\n",
    invalid_componentrole: "Pool Componentrole missing #\n",
    invalid_geo: "no vCenter geo defined\n",
    invalid_timezone: "Invalid vCenter timezone\n",
    invalid_host: "vCenter host not accessible\n",
    invalid_datacenter: "No datacenter defined for vCenter\n",
    invalid_imagefolder: "No image location defined for vCenter build\n",
    invalid_destfolder: "No destination folder defined for vCenter build\n",
    invalid_appendenv: "Append environment to destination folder must be true or false\n",
    invalid_appenddomain: "prepend app name to domain must be true or false\n",
    empty_datastores: "No data stores defined for vCenter build\n",
    invalid_domain: "No domain defined for node fqdn\n",
    empty_dnsips: "No IP's defined for DNS lookup\n",
    invalid_ip: "Invalid IP's defined for DNS lookup\n"
  }

  # Templates
  TEMPLATE_PLATFORM = 'templates/platform.yml.tt'
  TEMPLATE_VCENTER = 'templates/vcenter.yml.tt'
  TEMPLATE_NETWORK = 'templates/network.yml.tt'
  TEMPLATE_COMPUTE = 'templates/compute.yml.tt'

  # filename defaults
  YML_PLATFORM = 'platform.yml'
  YML_VCENTER = 'infrastructure/vcenter.yml'
  YML_NETWORK = 'infrastructure/network.yml'
  YML_COMPUTE = 'infrastructure/compute.yml'
  ENV_FOLDER = 'environments/'

  # error messages
  ERROR_MSG = {
    platform_already_exists: 'elevage: platform files already exist!',
    unknown_list_cmd: 'elevage: used an unknown LIST command',
    no_platform_file: 'elevage: platform.yml file not found!',
    no_vcenter_file: 'elevage: infastructure/vcenter.yml file not found!',
    no_network_file: 'elevage: infastructure/network.yml file not found!',
    no_compute_file: 'elevage: infastructure/compute.yml file not found!',
    environment_already_exists: 'elevage: environment file already exists!',
    fail_health_check: 'elevage: health check revealed errors'
  }

  MISSING_KEY = 'key not found'
end
# rubocop:enable LineLength, StringLiterals
