# rubocop:disable LineLength, StringLiterals
module Elevage
  # options description messages
  # DESC_followed by command and the description
  DESC_VERSION = 'Display installed elevage gem version (Can also use -v)'
  DESC_NEW = 'Prepare new platform files and folder structure at current location'
  DESC_LIST = 'List ITEMs from platform desired state yml files'
  DESC_LIST_NODES = 'used with environment name to list node names and ip addresses'
  DESC_HEALTH = 'Health check of the Platform desired state yml files'
  DESC_GENERATE = 'Generate new environment file based on platform template'

  # available List commands
  LIST_CMDS = %w(environments tiers pools components network vcenter compute)

  # Health check range settings
  TIMEZONE_LIMIT = 159
  CPU_LIMIT = 16
  RAM_LIMIT = 128
  POOL_LIMIT = 256

  # Health check messages
  MSG_HEALTHY = 'All base platform desired state files created and syntactically correct'
  MSG_ENV_HEALTHY = ' specific definition yml syntactically correct'
  MSG = {
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
    invalid_ip: "Invalid IP's defined for DNS lookup\n",
    empty_network: "Empty Network defintions\n",
    invalid_gateway: "Invalid gateway defined in network\n",
    invalid_cpu: "Invalid compute cpu settings\n",
    invalid_ram: "Invalid compute ram settings\n",
    invalid_env_vcenter: "Environment contains invalid vcenter definition\n",
    invalid_env_network: "Environment contains invalid network definition\n",
    invalid_env_count: "Environment contains invalid number of nodes in pool\n",
    invalid_env_compute: "Environment component pool contains invalid compute definition\n",
    invalid_env_ip: "Environment component pool contains invalid or missing ip address definition\n",
    invalid_env_tier: "Environment component pool contains invalid tier definition\n",
    invalid_env_image: "Environment component pool contains invalid image definition\n",
    invalid_env_port: "Environment component pool contains invalid port definition\n",
    invalid_env_runlist: "Environment component pool contains invalid runlist specification\n",
    invalid_env_componentrole: "Environment component pool contains invalid componentrole definition\n",
    env_component_mismatch: "Environment components do not match platform definition\n"
  }

  # Templates
  TEMPLATE_PLATFORM = 'templates/platform.yml.tt'
  TEMPLATE_VCENTER = 'templates/vcenter.yml.tt'
  TEMPLATE_NETWORK = 'templates/network.yml.tt'
  TEMPLATE_COMPUTE = 'templates/compute.yml.tt'
  TEMPLATE_ENV = 'templates/environment.yml.tt'

  # filename defaults
  YML_PLATFORM = 'platform.yml'
  YML_VCENTER = 'infrastructure/vcenter.yml'
  YML_NETWORK = 'infrastructure/network.yml'
  YML_COMPUTE = 'infrastructure/compute.yml'
  ENV_FOLDER = 'environments/'

  # error messages
  ERR = {
    platform_exists: 'elevage: platform files already exist!',
    not_list_cmd: 'elevage: used an unknown LIST command',
    no_platform_file: 'elevage: platform.yml file not found!',
    no_vcenter_file: 'elevage: infastructure/vcenter.yml file not found!',
    no_network_file: 'elevage: infastructure/network.yml file not found!',
    no_compute_file: 'elevage: infastructure/compute.yml file not found!',
    env_exists: 'elevage: environment file already exists!',
    env_not_defined: 'elevage: environment file not defined in platform',
    no_env_file: 'elevage: Environment file in platform.yml not found',
    fail_health_check: 'elevage: health check revealed errors'
  }
end
# rubocop:enable LineLength, StringLiterals
