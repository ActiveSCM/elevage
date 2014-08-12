# Elevage


[![Build Status](https://travis-ci.org/Cheneweth/elevage.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/Cheneweth/elevage.png?travis)][gemnasium]
[![Coverage Status](https://coveralls.io/repos/Cheneweth/elevage/badge.png?branch=master)][coveralls]
[![Inline docs](http://inch-ci.org/github/Cheneweth/elevage.png?branch=master)][inch]

[travis]: http://travis-ci.org/Cheneweth/elevage
[gemnasium]: https://gemnasium.com/Cheneweth/elevage
[coveralls]: https://coveralls.io/r/Cheneweth/elevage
[inch]: http://inch-ci.org/github/Cheneweth/elevage

## Installation


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
    list <env name>   :display substituted environment hash used to provision nodes



## Contributing

1. Fork it ( https://github.com/[my-github-username]/elevage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
