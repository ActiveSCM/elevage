# coding: utf-8
# rubocop:disable all
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elevage/version'

Gem::Specification.new do |spec|
  spec.name          = 'elevage'
  spec.version       = Elevage::VERSION
  spec.authors       = ['Nic Cheneweth','Gregory Ruiz-ade']
  spec.email         = ['Nic.Cheneweth@activenetwork.com','gregory.ruiz-ade@activenetwork.com']
  spec.summary       = 'vSphere provisioning'
  spec.description   = 'Command line tool to automate the provision and bootstrap of chef managed nodes, tiers, pools, and whole environments in vSphere'
  spec.homepage      = ''
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency('bundler', '~> 1.6')
  spec.add_development_dependency('rake', '~> 10.4.2')
  spec.add_development_dependency('yard')
  spec.add_development_dependency('aruba', '~> 0.6.2')
  spec.add_development_dependency('cucumber', '~>2.0.0')
  spec.add_development_dependency('psych', '= 2.0.5')
  spec.add_development_dependency('rspec', '~> 3.3.0')
  spec.add_development_dependency('guard', '~> 2.12.6')
  spec.add_development_dependency('guard-rubocop', '~> 1.2.0')
  spec.add_development_dependency('growl', '~> 1.0.3')
  spec.add_development_dependency('coveralls', '~> 0.8.1')
  spec.add_development_dependency('chef', '~> 12.3.0')
  spec.add_development_dependency('knife-vsphere', '~> 1.0.1')
  spec.add_dependency('thor', '~> 0.19.1')
  spec.add_dependency('open4', '~> 1.3.4')
  spec.add_dependency('english', '~> 0.6.3')
end
# rubocop:enable all
