require 'puppet/node'
require 'puppet/resource/catalog'
require 'puppet/indirector/code'
require 'rubygems'
require 'rspec'
require 'rspec-puppet/matchers'
require 'stringio'

class Puppet::Resource::Catalog::CompilerSpec < Puppet::Indirector::Code
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

  private
  # Definitions copied from compiler terminus as these are private methods

  # Turn our host name into a node object.
  def find_node(name)
    begin
      return nil unless node = Puppet::Node.indirection.find(name)
    rescue => detail
      puts detail.backtrace if Puppet[:trace]
      raise Puppet::Error, "Failed when searching for node #{name}: #{detail}"
    end
    node
  end

  # Extract the node from the request, or use the request
  # to find the node.
  def node_from_request(request)
    if node = request.options[:use_node]
      return node
    end

    # We rely on our authorization system to determine whether the connected
    # node is allowed to compile the catalog's node referenced by key.
    # By default the REST authorization system makes sure only the connected node
    # can compile his catalog.
    # This allows for instance monitoring systems or puppet-load to check several
    # node's catalog with only one certificate and a modification to auth.conf 
    # If no key is provided we can only compile the currently connected node.
    name = request.key || request.node
    if node = find_node(name)
      return node
    end

    raise ArgumentError, "Could not find node '#{name}'; cannot compile"
  end
end
