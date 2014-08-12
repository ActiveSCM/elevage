# coding: utf-8
# rubocop:disable all
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elevage/version'

Gem::Specification.new do |spec|
  spec.name          = 'elevage'
  spec.version       = Elevage::VERSION
  spec.authors       = ['Nic Cheneweth']
  spec.email         = ['Nic.Cheneweth@activenetwork.com']
  spec.summary       = 'Summary description'
  spec.description   = 'Longer description'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('aruba')
  spec.add_development_dependency('cucumber')
  spec.add_development_dependency('psych')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('guard')
  spec.add_development_dependency('guard-rubocop')
  spec.add_development_dependency('growl')
  spec.add_dependency('thor')
end
# rubocop:enable all