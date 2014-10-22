# Spec module for Puppet

**Evaluate assertions during a Puppet run**

This module is provided by [Camptocamp](http://www.camptocamp.com/)


## Requirements

This module requires the following Ruby libraries:

* `rspec`;
* [`rspec-puppet`](https://github.com/rodjek/rspec-puppet) for catalog tests;
* [`serverspec`](https://github.com/mizzy/serverspec) (&gt;= 2.0.0) for functional tests.


## Using catalog spec termini

This module provides new Puppet termini which allow to evaluate rspec tests on the actual compiled catalog.

In order to install these termini:

* Run Puppet with `pluginsync` on to copy the indirectors;
* Set your `$confdir/routes.yaml` to use the termini, for example:

        agent:
          catalog:
            terminus: rest_spec
            cache: yaml
        master:
          catalog:
            terminus: compiler_spec

### `rest_spec` terminus

The `rest_spec` terminus extends the `rest` terminus for catalogs. After retrieving the catalog using the `rest` terminus, it applies rspec tests to it:

* The rspec tests must be located in `:libdir/spec/catalog/class` (allowing you to deploy them via `pluginsync` by putting them in the module's `lib/spec/catalog/class` directory), in sub-directories by class;
* Only the directories named after classes declared in the catalog will be tested;
* `rspec-puppet` matchers are already loaded, so they are available in tests;
* The catalog is exported as a shared instance of the PuppetSpec::Catalog class and can be loaded as subject with:

        subject { PuppetSpec::Catalog.instance.catalog }

Sample output:

    # puppet agent -t
    info: Retrieving plugin
    err: Could not retrieve catalog from remote server: Unit tests failed:
    F..
    
    Failures:
    
      1) package 
         Failure/Error: it { should contain_package('augeas') }
           expected that the catalogue would contain Package[augeas]
         # /var/lib/puppet/lib/spec/class/augeas/package_spec.rb:3
         # /var/lib/puppet/lib/puppet/indirector/catalog/rest_spec.rb:31:in `find'
    
    Finished in 0.00092 seconds
    3 examples, 1 failure
    
    Failed examples:
    
    rspec /var/lib/puppet/lib/spec/class/augeas/package_spec.rb:3 # package 
    
    info: Not using expired catalog for foo.example.com from cache; expired at Tue Apr 02 17:40:21 +0200 2013
    notice: Using cached catalog


### `compiler_spec` terminus

The `compiler_spec` terminus extends the `compiler` terminus for catalogs. After retrieving the catalog using the `compiler` terminus, it applies rspec tests to it:

* The rspec tests must be located in `:manifestdir/../spec/catalog/class`, in sub-directories by class;
* Only the directories named after classes declared in the catalog will be tested;
* `rspec-puppet` matchers are already loaded, so they are available in tests;
* The catalog is exported as a shared instance of the PuppetSpec::Catalog class and can be loaded as subject with:

        subject { PuppetSpec::Catalog.instance.catalog }

Sample output:

    # puppet agent -t --environment rpinson

    info: Retrieving plugin
    err: Could not retrieve catalog from remote server: Error 400 on SERVER: Unit tests failed:
    .FF.F
    
    Failures:
    
      1) puppet 
         Failure/Error: it { should contain_package('ppet') }
           expected that the catalogue would contain Package[ppet]
         # /home/rpinson/puppetmaster/spec/catalog/class/puppet__client__base/puppet_package_spec.rb:4
    
      2) puppet 
         Failure/Error: it { should include_class('puppet') }
           expected that the catalogue would include Class[puppet]
         # /home/rpinson/puppetmaster/spec/catalog/class/puppet__client__base/puppet_package_spec.rb:5
    
      3) failure 
         Failure/Error: it { 2.should == 5 }
           expected: 5
                got: 2 (using ==)
         # /home/rpinson/puppetmaster/spec/catalog/class/foo.example.com/fail_spec.rb:2
    
    Finished in 0.00312 seconds
    5 examples, 3 failures
    
    Failed examples:
    
    rspec /home/rpinson/puppetmaster/spec/catalog/class/puppet__client__base/puppet_package_spec.rb:4 # puppet 
    rspec /home/rpinson/puppetmaster/spec/catalog/class/puppet__client__base/puppet_package_spec.rb:5 # puppet 
    rspec /home/rpinson/puppetmaster/spec/catalog/class/foo.example.com/fail_spec.rb:2 # failure 
    notice: Using cached catalog


## Using the functional spec terminus

After the catalog has been tested and applied, you might want to run functional tests against the machine. This module provides a `rest_spec` terminus for the report indirector which executes rspec tests using the `serverspec` matchers.

In order to use it:

* The rspec tests must be located in `:libdir/spec/server/class` (allowing you to deploy them via `pluginsync`) or `:vardir/spec/server/class` (tests can be deployed using the `spec::serverspec` define), in sub-directories by class;
* `serverspec` matchers are already loaded, so they are available in tests.

To activate the terminus, you need set it in `$confdir/routes.yaml`:

    agent:
      report:
        terminus: rest_spec

Sample output:

    # puppet agent  -t
    info: Retrieving plugin
    info: Caching catalog for foo.example.com
    info: Applying configuration version 'raphink/a2c8e0f [+]'
    ... Applying changes ...
    notice: Finished catalog run in 59.19 seconds
    err: Could not send report: Unit tests failed:
    FF
    
    Failures:
    
      1) augeas 
         Failure/Error: it { should be_installed }
           expected "augeas" to be installed
         # /var/lib/puppet/lib/spec/server/class/foo.example.com/package_spec.rb:2
         # /var/lib/puppet/lib/puppet/indirector/report/rest_spec.rb:45:in `save'
    
      2) /usr/share/augeas/lenses/dist 
         Failure/Error: it { should be_file }
           expected "/usr/share/augeas/lenses/dist" to be file
         # /var/lib/puppet/lib/spec/server/class/foo.example.com/package_spec.rb:6
         # /var/lib/puppet/lib/puppet/indirector/report/rest_spec.rb:45:in `save'
    
    Finished in 0.06033 seconds
    2 examples, 2 failures
    
    Failed examples:
    
    rspec /var/lib/puppet/lib/spec/server/class/foo.example.com/package_spec.rb:2 # augeas 
    rspec /var/lib/puppet/lib/spec/server/class/foo.example.com/package_spec.rb:6 # /usr/share/augeas/lenses/dist 


This indirector will automatically generate serverspec tests from the catalog for known resource types, making the catalog self-asserting. Currently, it supports the following resource types:

* Package
* Service
* File
* User


## Using the MCollective agent

This module provides an MCollective agent in `files/mcollective/agent`. This agent currently has two actions:

### Documentation

    $ mco plugin doc spec
    RSpec tests
    ===========
    
    RSpec tests
    
          Author: Raphaël Pinson
         Version: 0.1
         License: GPLv3
         Timeout: 60
       Home Page: 
    
    ACTIONS:
    ========
       check, run
    
       check action:
       -------------
           Run a check with the serverspec library
    
           INPUT:
               action:
                  Description: 
                       Prompt: Action to check
                         Type: string
                   Validation: ^\S+$
                       Length: 50
    
               values:
                  Description: 
                       Prompt: Values to check
                         Type: string
                   Validation: ^\S+$
                       Length: 100
    
    
           OUTPUT:
               passed:
                  Description: Whether the checked passed
                   Display As: Passed
    
       run action:
       -----------
           Run Puppet-spec tests
    
           INPUT:
    
           OUTPUT:
               output:
                  Description: Output of tests
                   Display As: Output
    
               passed:
                  Description: Whether the tests passed
                   Display As: Passed

### Examples

Using the `check` action:

    $ mco rpc spec check action=running values=ssh
    Discovering hosts using the mc method for 2 second(s) .... 1
    
     * [ ============================================================> ] 1 / 1
    
    
    wrk4                                     
       Passed: true

    
    Finished processing 1 / 1 hosts in 373.44 ms


Using the `run` action:

    $ mco rpc spec run 
    Discovering hosts using the mc method for 2 second(s) .... 1
    
     * [ ============================================================> ] 1 / 1
    
    wrk4                                     
       Output: F
               
               Failures:
               
                 1) abc 
                    Failure/Error: it { should be_running }
                      expected "abc" to be running
                    # /var/lib/puppet/spec/server/class/wrk4.example.com/my_test_spec.rb:3
                    # /usr/share/mcollective/plugins/mcollective/agent/spec.rb:75:in `run_action'
               
               Finished in 0.00926 seconds
               1 example, 1 failure
               
               Failed examples:
               
               rspec /var/lib/puppet/spec/server/class/wrk4.example.com/my_test_spec.rb:3 # abc 
       Passed: false


    Finished processing 1 / 1 hosts in 316.46 ms


## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-spec/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-spec/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).

## License

Copyright (c) 2013 <mailto:puppet@camptocamp.com> All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

