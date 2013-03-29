# Spec module for Puppet

**Evaluate assertions during a Puppet run**

This module is provided by [Camptocamp](http://www.camptocamp.com/)


## Using spec terminii

This module provides new Puppet terminii which allow to evaluate rspec tests on the actual compiled catalog.

In order to install these terminii:

* Copy the files a `$RUBYLIB/puppet/indirector/catalog/`;
* Set your $confdir/routes.yaml to use the terminii, for example:

        agent:
          catalog:
            terminus: rest_spec
            cache: yaml
        master:
          catalog:
            terminus: compiler_spec

### `rest_spec` terminus

The `rest_spec` terminus extends the `rest` terminus for catalogs. After retrieving the catalog using the `rest` terminus, it applies rspec tests to it:

* The rspec tests must be located in `:vardir/spec/class`, in sub-directories by class;
* Only the directories named after classes declared in the catalog will be tested;
* `rspec-puppet` matchers are already loaded, so they are available in tests;
* The catalog is (currently, needs fixing) saved as `/tmp/catalog` and can be loaded in tests with:

        subject { YAML.load_file('/tmp/catalog') }

### `compiler_spec` terminus

The `compiler_spec` terminus extends the `compiler` terminus for catalogs. After retrieving the catalog using the `compiler` terminus, it applies rspec tests to it:

* The rspec tests must be located in `:manifestdir/../spec/class`, in sub-directories by class;
* Only the directories named after classes declared in the catalog will be tested;
* `rspec-puppet` matchers are already loaded, so they are available in tests;
* The catalog is (currently, needs fixing) saved as `/tmp/catalog` and can be loaded in tests with:

        subject { YAML.load_file('/tmp/catalog') }


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

