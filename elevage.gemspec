require File.join([File.dirname(__FILE__),'lib','elevage','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name      = 'elevage'
  s.VERSION   = Elevage::VERSION
  s.licenses  = ['MIT']
  s.author    = 'Nic Cheneweth'
  s.email     = 'ncheneweth@mac.com'
  s.homepage  = ''
  s.platform  = Gem::Platform::RUBY
  s.summary   = 'The elevage utility takes a set of infrastructure and environment defintion files and provisions servers within vCenter"'
  s.files     = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc  = true
  s.extra_rdoc_files = ['README.rdoc','elevage.rdoc']
  s.rdoc_options << '--title' << 'elevage' << '--main' << 'README.rdoc' << '-ri'
  s.bindir    = 'bin'
  s.executables << 'elevage'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.9.0')
end
