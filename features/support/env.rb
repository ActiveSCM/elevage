require 'aruba/cucumber'
require 'aruba/in_process'
require 'elevage/runner'

Aruba::InProcess.main_class = Elevage::Runner
Aruba.process = Aruba::InProcess
