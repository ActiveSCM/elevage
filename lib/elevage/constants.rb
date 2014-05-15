# rubocop:disable LineLength, StringLiterals
module Elevage
  # messages
  DESC_VERSION = 'Display installed elevage gem version (Can also use -v)'
  DESC_NEW = 'Prepare new platform files and folder structure at current location'
  DESC_GUARD = 'Guard yml files health check'

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
    no_platform_file: 'elevage: platform.yml file not found!'
  }
end
# rubocop:enable LineLength, StringLiterals
