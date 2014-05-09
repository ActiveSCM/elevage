# Standard defaults used to build new platform definition files
#
# The health command run at the platform level will alert
# if the appropriate settings have not been updated to real values
module Elevage
  # String message constants
  CMD_NEW = 'Prepare new platform folder structure at current location'
  CMD_GENERATE = 'Generate specified platform COMPONENT definition files'
  CMD_ENV = 'Prepare new environment description file'
  CMD_HEALTH = 'Health check on all PLATFORM definition files'

  # Tool defaults
  ARTIFACTS_PATH = 'artifacts_path'
  PLATFORM_YML = 'platform.yml'
  INFRA_YML = 'infrastructure.yml'
  DEV_ENV = 'dev'
  ENV_DIR = 'environments'

  # Templates
  TEMPLATE_PLATFORM = 'templates/platform.yml.tt'
  TEMPLATE_INFRA = 'templates/infrastructure.yml.tt'
  TEMPLATE_ENV = 'templates/environment.yml.tt'

  # error messages
  ERROR_MSG = {
    platform_already_exists: 'elevage: platform directory exists!',
    no_platform_file: 'elevage: platform.yml file not found!',
    last_entry: 'last entry'
  }

  ERROR_NO = {
    platform_already_exists: 2,
    no_platform_file: 3,
    last_entry: 0
  }
end
