require 'puppet/node'
require 'puppet/resource/catalog'
require 'puppet/indirector/catalog/rest'
require 'rubygems'
require 'rspec'
require 'rspec-puppet/errors'
require 'rspec-puppet/matchers'
require 'stringio'
require Puppet.settings[:libdir] + '/policy/catalog'

class Puppet::Resource::Catalog::RestSpec < Puppet::Resource::Catalog::Rest
  def compiler
    @compiler ||= indirection.terminus(:rest)
  end

  def find(request)
    return nil unless catalog = compiler.find(request)

    RSpec::configure do |c|
       c.include(RSpec::Puppet::ManifestMatchers)
    end
    # Send catalog down the rabbit hole
    PuppetSpec::Catalog.setup(catalog)
    # Test by classes, including $certname
    spec_dirs = []
    catalog.classes.each do |c|
      class_dir = c.gsub(/:/, '_')
      class_path = "#{Puppet.settings[:libdir]}/policy/catalog/class/#{class_dir}"
      spec_dirs << class_path if File.directory? class_path
    end
    out = StringIO.new
    unless RSpec::Core::Runner::run(["-r#{Puppet.settings[:libdir]}/policy/catalog", spec_dirs], $stderr, out) == 0
      raise Puppet::Error, "Unit tests failed:\n#{out.string}"
    end
    catalog
  end
end
