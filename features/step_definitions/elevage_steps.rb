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
  step %(the output should match /elevage commands:/)
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

Then(/^the result should contain "([^"]*)"$/) do |options|
  options.split(',').map(&:strip).each do |option|
    step %(the output should match /#{option}/)
  end
end
# rubocop:enable LineLength, StringLiterals
