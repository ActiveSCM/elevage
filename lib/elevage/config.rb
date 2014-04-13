# Standard defaults used to build new platform definition files
# -The status command run at the platform level will alert if the appropriate settings have not been updated to real values
#
module Elevage
  ARTIFACTS_PATH = 'artifacts_path'
  PLATFORM_YML = ' platform.yml'
  DEV_ENVIRONMENT = 'dev'
  ENVIRONMENTS_DIR = 'environments'



  #error messages
  ERROR_MSG = {
      :platform_already_exists => 'elevage: platform directory exists!',
      :no_platform_file => 'elevage: platform.yml file not found in current folder!',
      :last_entry => 'last entry'
  }

  ERROR_NO = {
      :platform_already_exists => 2,
      :no_platform_file => 3,
      :last_entry => 0
  }

end