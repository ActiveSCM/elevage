# rubocop:disable LineLength, StringLiterals
module Elevage
  # messages
  DESC_VERSION = 'Display installed elevage gem version (Can also use -v)'
  DESC_NEW = 'Prepare new platform files and folder structure at current location'
  DESC_LIST = 'List ITEMs from platform desired state yml files'
  DESC_LIST_NODES = 'used with environment name to list node names and ip addresses'
  DESC_HEALTH = 'Complete desired state yml files Health check'
  DESC_GENERATE = 'Generate new environment files based on platform template'

  MSG_HEALTH_SUCCESS = 'All platform desired state files present and consistently configured'

  LIST_CMDS = %w(environments tiers pools components network vcenter compute)

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
    compute_platform_name_mismatch: 'elevage: compute.yml platform name does not match platform.yml',
    vcenter_platform_name_mismatch: 'elevage: vcenter.yml platform name does not match platform.yml',
    missing_environment_file: 'elevage: environment defined in platform.yml but not found in environments folder',
    environment_already_exists: 'elevage: environment file already exists!',
    no_environments_defined: 'elevage: there are no environments defined in platform.yml',
    too_many_environment_files: 'elevage: there are more environments files then ENV definitions',
    nil_compute_values: 'elevage: compute components with empty settings'
  }

  MISSING_KEY = 'key not found'
end
# rubocop:enable LineLength, StringLiterals
