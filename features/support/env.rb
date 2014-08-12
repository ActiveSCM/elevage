require 'aruba/cucumber'
require 'aruba/in_process'
require 'elevage/runner'
require 'coveralls'

Coveralls.wear!

Aruba::InProcess.main_class = Elevage::Runner
Aruba.process = Aruba::InProcess
