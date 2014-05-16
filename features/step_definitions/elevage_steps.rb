# Put your step definitions here
# rubocop:disable LineLength, StringLiterals
Given(/^the following files exist:$/) do |options|
  options.raw.each do |option|
    step %(an empty file named "#{option[0]}")
  end
end

When(/^I get general help for "([^"]*)"$/) do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} --help`)
  step %(I run `#{app_name}`)
end

Then(/^the banner should be present$/) do
  step %(the output should match /Commands:/)
end

Then(/^the following commands should be documented:$/) do |options|
  options.raw.each do |option|
    step %(the command "#{option[0]}" should be documented)
  end
end

Then(/^the command "([^"]*)" should be documented$/) do |options|
  options.split(',').map(&:strip).each do |option|
    step %(the output should match /\\s*#{Regexp.escape(option)}[\\s\\W]+\\w[\\s\\w][\\s\\w]+/)
  end
end

Then(/^the output should display the version$/) do
  step %(the output should match /\\d+\\.\\d+\\.\\d+/)
end

Then(/^the output should contain the Platform Already Exists error$/) do
  step %(the output should match /elevage: platform files already exist!/)
end

Then(/^the output should display simple health success in the results from the guard health check$/) do
  step %(the output should match /present/)
end

Then(/^the output should contain the platform Not Found error$/) do
  step %(the output should match /platform.yml file not found!/)
end

Then(/^the output should contain the vcenter Not Found error$/) do
  step %(the output should match /vcenter.yml file not found!/)
end

Then(/^the output should contain the network Not Found error$/) do
  step %(the output should match /network.yml file not found!/)
end

Then(/^the output should contain the compute Not Found error$/) do
  step %(the output should match /compute.yml file not found!/)
end

# rubocop:enable LineLength, StringLiterals
