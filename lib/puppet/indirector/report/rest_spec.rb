require 'puppet/indirector/report/rest' 
require 'puppet/util/autoload'
require 'puppetx/policy'
require 'puppetx/policy/auto_spec'
require 'rubygems'
require 'rspec'
require 'serverspec' 
require 'stringio'
require 'facter' 
require 'fileutils'


module PuppetSpecReport
  def status= (status)
    @status = status
  end
end
  
class Puppet::Transaction::Report::RestSpec < Puppet::Transaction::Report::Rest 
  desc "Run functional tests then get server report over HTTP via REST." 
      
  def processor
    @processor ||= indirection.terminus(:rest)
  end                                                 

  def save(request)
    # Load plugins dynamically
    autoloader = Puppet::Util::Autoload.new(self, "puppetx/policy/auto_spec", :wrap => false)
    autoloader.loadall
    Puppet.debug('Loaded auto_spec plugins')

    # Generate serverspec files
    # TODO: Check that we get the catalog from cache
    resources = Puppet::Resource::Catalog.indirection.find(request.instance.host).resources
    spec_dir = File.join(Puppet[:vardir], 'policy', 'server')
    FileUtils.mkdir_p(spec_dir)
    Puppetx::Policy::AutoSpec.gen_auto_spec_files(resources, spec_dir)
    Puppet.debug('Generated auto_spec files')

    # Extend report
    request.instance.extend(PuppetSpecReport)

    # Specinfra gets its default configuration from RSpec
    RSpec.configure do |c|
      c.backend = :exec
    end

    out = StringIO.new
    Puppet.debug('Launching serverspec tests')
    if RSpec::Core::Runner::run([spec_dir], $stderr, out) == 0
      request.instance << Puppet::Util::Log.new(
        :message => out.string,
        :level   => :notice
      )
    else
      request.instance << Puppet::Util::Log.new(
        :message => out.string,
        :level   => :err
      )
      request.instance.status = 'failed'
    end

    processor.save(request)                    
  end                                                                                     
end

