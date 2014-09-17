require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)
Coveralls::RakeTask.new
YARD::Rake::YardocTask.new

task default: [:spec, :features, 'coveralls:push']
