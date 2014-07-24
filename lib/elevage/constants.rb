# rubocop:disable LineLength, StringLiterals
module Elevage
  # messages
  DESC_VERSION = 'Display installed elevage gem version (Can also use -v)'
  DESC_NEW = 'Prepare new platform files and folder structure at current location'
  DESC_GUARD = 'Guard yml files health check'
  DESC_GUARD_SIMPLE = 'Confirms existence of all platform state files'
  DESC_GUARD_FULL = 'Confirm health of all platform files'
  DESC_GENERATE = 'Generate new environment files based on platform template'

  MSG_GUARD_SIMPLE_SUCCESS = 'All platform desired state files present'
  MSG_GUARD_PLATFORM_SUCCESS = 'All platform desired state files present and consistently configured'

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
  ENVIRONMENTS_FOLDER = 'environments/'

  # error messages
  ERROR_MSG = {
    platform_already_exists: 'elevage: platform files already exist!',
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
end
# rubocop:enable LineLength, StringLiterals
