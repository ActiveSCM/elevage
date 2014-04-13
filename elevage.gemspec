spec = Gem::Specification.new do |s|
  s.name          = 'elevage'
  s.version       = '0.1.0'
  s.license       = 'MIT'
  s.author        = 'Nic Cheneweth'
  s.email         = 'ncheneweth@mac.com'
  s.summary       = 'The elevage utility takes a set of infrastructure and environment definition files and provisions servers within vCenter'
  s.description   = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  s.homepage      = 'https://github.com/Cheneweth/elevage'

  s.files         = Dir['{bin,lib,spec}/**/*'] + %w(README.md)
  s.test_files    = Dir['spec/**/*']
  s.executables   = ['elevage']

  s.required_ruby_version = '>=1.9'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'aruba'
end
