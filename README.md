# Elevage

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'elevage'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elevage

## Usage

Create new, default platform definition files at current location

    $ elevage new <Platform Name>

Display parsed items from the desired state files

    $ elevage list <item>

    list vcenter      :list all named vcenter definitions and their keys/values
    list networks     :list all named network definitions  and their keys/values
    list compute      :list all named compute configurations
    list tiers        :list all defined tier names
    list pools        :list all default component pool defintions
    list components   :list all platform components
    list environments :list all defined environments in the platform state file
    list <env name>   :display substitutes environment hash used to provision nodes



## Contributing

1. Fork it ( https://github.com/[my-github-username]/elevage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
