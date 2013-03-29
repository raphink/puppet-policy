require 'puppet/node'
require 'puppet/resource/catalog'
require 'puppet/indirector/code'
require 'rubygems'
require 'rspec'
require 'rspec-puppet/matchers'
require 'stringio'

class Puppet::Resource::Catalog::RestSpec < Puppet::Indirector::Code
  def compiler
    @compiler ||= indirection.terminus(:rest)
    #@compiler ||= indirection.terminus(:yaml)
  end

  def find(request)
    return nil unless catalog = compiler.find(request)

    RSpec::configure do |c|
       c.include(RSpec::Puppet::ManifestMatchers)
    end
    File.open('/tmp/catalog', 'w') do |out|
      YAML.dump(catalog, out)
    end
    # Test by classes, including $certname
    spec_dirs = []
    catalog.classes.each do |c|
      class_dir = c.gsub(/:/, '_')
      class_path = "#{Puppet.settings[:vardir]}/spec/class/#{class_dir}"
      spec_dirs << class_path if File.directory? class_path
    end
    # Use something else than stdout/stderr to get reports?
    out = StringIO.new
    unless RSpec::Core::Runner::run(spec_dirs, $stderr, out) == 0
      raise Puppet::Error, "Unit tests failed:\n#{out.string}"
    end
    catalog
  end
end
