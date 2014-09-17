# Elevage

[![Build Status](https://travis-ci.org/Cheneweth/elevage.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/Cheneweth/elevage.png?travis)][gemnasium]
[![Coverage Status](https://coveralls.io/repos/Cheneweth/elevage/badge.png?branch=master)][coveralls]
[![Inline docs](http://inch-ci.org/github/Cheneweth/elevage.png?branch=master)][inch]

[travis]: http://travis-ci.org/Cheneweth/elevage
[gemnasium]: https://gemnasium.com/Cheneweth/elevage
[coveralls]: https://coveralls.io/r/Cheneweth/elevage
[inch]: http://inch-ci.org/github/Cheneweth/elevage

#### Installation

elevage is distributed as a ruby gem

```bash
$ gem install elevage
```
## Usage

Create new, default platform definition files at current location. Comments within the template files describe necessary customizations.

```bash
$ elevage new <Platform Name>
```

Display parsed items from the desired state files.

```bash
$ elevage list <item>

list vcenter        :list all named vcenter definitions
list network        :list all named network definitions
list compute        :list all named compute configurations
list tiers          :list all defined tier names
list pools          :list all default component pool defintions
list components     :list all platform components
list environments   :list all defined environments
list <env name> -n  :display individual node names, IP addresses, and Chef roles
```

Check health of platform definition files.

```bash
$ elevage health
```
Generate a new environment file.  Comments within the template files describe necessary customizations.

```bash
$ elevage generate <environment name>
```
## Contributing

1. Fork it ( https://github.com/[my-github-username]/elevage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### License and Authors
- Authors:: Nic Cheneweth (<nic.cheneweth@activenetwork.com>), Name <email@activenetwork.com>

```
Copyright 2009-2014 Active Network, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```