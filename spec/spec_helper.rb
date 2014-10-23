require 'mocha'
require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

require 'simplecov'
unless RUBY_VERSION =~ /^1\.8/
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end
SimpleCov.start do
  add_group "Puppet Indirectors", "/lib/puppet/indirector/"
  add_group "Puppet Policy Plugins", "/lib/puppetx/policy/auto_spec/"

  add_filter "/spec/fixtures/"
  add_filter "/spec/unit/"
  add_filter "/spec/support/"
end

