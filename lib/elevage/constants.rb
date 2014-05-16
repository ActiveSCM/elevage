# rubocop:disable LineLength, StringLiterals
module Elevage
  # messages
  DESC_VERSION = 'Display installed elevage gem version (Can also use -v)'
  DESC_NEW = 'Prepare new platform files and folder structure at current location'
  DESC_GUARD = 'Guard yml files health check'
  DESC_GUARD_SIMPLE = 'Confirms existence of all platform state files'

  MSG_GUARD_SIMPLE_SUCCESS = 'All platform desired state files present'

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

  # error messages
  ERROR_MSG = {
    platform_already_exists: 'elevage: platform files already exist!',
    no_platform_file: 'elevage: platform.yml file not found!',
    no_vcenter_file: 'elevage: infastructure/vcenter.yml file not found!',
    no_network_file: 'elevage: infastructure/network.yml file not found!',
    no_compute_file: 'elevage: infastructure/compute.yml file not found!',
    compute_platform_name_mismatch: 'elevage: compute.yml platform name does not match platform.yml',
    missing_environment_file: 'elevage: environment defined in platform.yml but not found in environments folder'
  }
end
# rubocop:enable LineLength, StringLiterals
