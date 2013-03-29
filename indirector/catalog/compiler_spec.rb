require 'puppet/node'
require 'puppet/resource/catalog'
require 'puppet/indirector/catalog/compiler'
require 'rubygems'
require 'rspec'
require 'rspec-puppet/matchers'
require 'stringio'

class Puppet::Resource::Catalog::CompilerSpec < Puppet::Resource::Catalog::Compiler
  def compiler
    @compiler ||= indirection.terminus(:compiler)
  end

  def find(request)
    return nil unless catalog = compiler.find(request)
    node = node_from_request(request)
    manifestdir = Puppet.settings.value(:manifestdir, node.environment)
    # We put specs in the parent directory of :manifestdir
    spec_dir = File.join(manifestdir, '..', 'spec')

    RSpec::configure do |c|
       c.include(RSpec::Puppet::ManifestMatchers)
    end
    # TODO: try to pass the catalog to the examples
    File.open("/tmp/catalog", 'w') do |out|
      YAML.dump(catalog, out)
    end
    # Test by classes, including $certname
    spec_dirs = []
    catalog.classes.each do |c|
      class_dir = c.gsub(/:/, '_')
      class_path = File.join(spec_dir, "class/#{class_dir}")
      spec_dirs << class_path if File.directory? class_path
    end
    out = StringIO.new
    unless RSpec::Core::Runner::run(spec_dirs, $stderr, out) == 0
      raise Puppet::Error, "Unit tests failed:\n#{out.string}"
    end
    catalog
  end

end
