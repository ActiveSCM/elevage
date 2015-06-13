# Elevage

[![Build Status](https://travis-ci.org/activenetwork-automation/elevage.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/activenetwork-automation/elevage.png?travis)][gemnasium]
[![Coverage Status](https://coveralls.io/repos/activenetwork-automation/elevage/badge.png?branch=master)][coveralls]
[![Inline docs](http://inch-ci.org/github/activenetwork-automation/elevage.png?branch=master)][inch]

[travis]: http://travis-ci.org/activenetwork-automation/elevage
[gemnasium]: https://gemnasium.com/activenetwork-automation/elevage
[coveralls]: https://coveralls.io/r/activenetwork-automation/elevage
[inch]: http://inch-ci.org/github/activenetwork-automation/elevage

`elevage` is a command-line tool that allows you to define an application
platform in a set of plain-text (YAML) configuration files and use those
definitions to provision the virtual machines on which the application will
live. The virtual machine will also be converged with the Chef runlists as
defined your configuration files.

Currently, `elevage` relies upon Chef's `knife` command and the `knife-vsphere`
plugin, and has been tested with various releases of Chef 11 and 12 as well
as the ChefDK.

#### External Dependencies

You must have the `knife` command installed on your path, and the
`knife-vsphere` plugin installed. Your options are to:

- Install [Chef Client](https://www.chef.io/download-chef-client/) and then
install `knife-vsphere` via Chef's embedded ruby's `gem`
- Install [ChefDK](https://downloads.chef.io/chef-dk/) and then
`chef gem install knife-vsphere`
- Install Chef via rubygems with `gem install chef knife-vsphere`

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

Provision nodes from platform and environment definition

```bash
$ elevage build <params>

Options:
  -a, [--all], [--no-all]                      # Build everything for the named environment
  -t, [--tier=TIER]                            # Build everything for the specified tier in the named environment
  -c, [--component=COMPONENT]                  # Build all nodes for the specified component
  -n, [--node=N]                               # Build the single specified node
  -C, [--concurrency=N]                        # Maximum number of simultaneous provisioning tasks
                                               # Default: 8
  -l, [--logfiles=LOGFILES]                    # Path where log files should be written
                                               # Default: logs
  -v, [--verbose], [--no-verbose]
      [--dry-run], [--no-dry-run]              # Do not actually do anything
                                               # Just display the commands that would be run.
      [--vsuser=VSUSER]                        # Username for vSphere
                                               # Default: svc_provisioner
      [--vspass=VSPASS]                        # Password for vSphere
                                               # Default: changeme
  -x, [--ssh-user=SSH-USER]                    # Unix username for ssh for chef-client bootstrap
                                               # (must have sudo NOPASSWD access for root)
                                               # Default: knife
  -i, [--ssh-key=SSH-KEY]                      # Path to SSH private key for ssh username for key-based authentication
                                               # Default: knife_rsa
  -t, [--template-file=TEMPLATE-FILE]          # File to be used as the chef-client bootstrap template script
                                               # Default: chef-full.erb
  -b, [--bootstrap-version=BOOTSTRAP-VERSION]  # Version of chef-client to bootstrap on node
                                               # Default: 11.4.0
```

## Contributing

1. Fork it ( https://github.com/activenetwork-automation/elevage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### License and Authors
- [Nic Cheneweth](https://github.com/Cheneweth)
- [Gregory Ruiz-Ade](https://github.com/gkra)

```
Copyright 2014 Active Network, LLC

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
