# Put your step definitions here
When /^I get general help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} --help`)
  step %(I run `#{app_name}`)
end

Then /^the banner should be present$/ do
  step %(the output should match /Commands:/)
end

Then /^the following commands should be documented:$/ do |options|
  options.raw.each do |option|
    step %(the command "#{option[0]}" should be documented)
  end
end

Then /^the command "([^"]*)" should be documented$/ do |options|
  options.split(',').map(&:strip).each do |option|
    step %(the output should match /\\s*#{Regexp.escape(option)}[\\s\\W]+\\w[\\s\\w][\\s\\w]+/)
  end
end

Then /^the output should display the version$/ do
  step %(the output should match /\\d+\\.\\d+\\.\\d+/)
end

# Then /^the following options should be documented:$/ do |options|
#   options.raw.each do |option|
#     step %(the option "#{option[0]}" should be documented #{option[1]})
#   end
# end

# Then /^the option "([^"]*)" should be documented(.*)$/ do |options,qualifiers|
#   options.split(',').map(&:strip).each do |option|
#     if qualifiers.strip == "which is negatable"
#       option = option.gsub(/^--/,"--[no-]")
#     end
#     step %(the output should match /\\s*#{Regexp.escape(option)}[\\s\\W]+\\w[\\s\\w][\\s\\w]+/)
#   end
# end
#
# Then /^the banner should document that this app's arguments are:$/ do |table|
#   expected_arguments = table.raw.map { |row|
#     option = row[0]
#     option = "[#{option}]" if row[1] == 'optional' || row[1] == 'which is optional'
#     option
#   }.join(' ')
#   step %(the output should contain "#{expected_arguments}")
# end
#

#
# Then /^there should be a one line summary of what the app does$/ do
#   output_lines = all_output.split(/\n/)
#   output_lines.should have_at_least(3).items
#   # [0] is our banner, which we've checked for
#   output_lines[1].should match(/^\s*$/)
#   output_lines[2].should match(/^\w+\s+\w+/)
# end