require 'puppet/indirector/report/rest' 
require 'rubygems'
require 'rspec'
require 'serverspec' 
require 'serverspec/backend/puppet'
require 'stringio'
require 'facter' 
  
class Puppet::Transaction::Report::RestSpec < Puppet::Transaction::Report::Rest 
  desc "Run functional tests then get server report over HTTP via REST." 
      
  def processor
    @processor ||= indirection.terminus(:rest)
  end                                                 

  def save(request)
    case Facter.value(:osfamily)                           
      when 'Debian'
        helper_class = Serverspec::Helper::Debian
      when 'RedHat'        
        helper_class = Serverspec::Helper::RedHat  
      when 'Gentoo'
        helper_class = Serverspec::Helper::Gentoo     
      when 'Solaris'
        helper_class = Serverspec::Helper::Solaris
      else
        raise Puppet::Error, "Could not determine a helper to use for functional tests for OS family #{Facter.value(:osfamily)}"
    end

    RSpec.configure do |c|
      c.include(helper_class)
      c.include(Serverspec::Helper::Puppet)
    end
      
    # Test by classes, including $certname                              
    spec_dirs = []
    spec_dirs = ["#{Puppet.settings[:libdir]}/spec/server/class/test"]
    # TODO: get classes for current node
    # use request.node?
    #classes.each do |c|
    #  class_dir = c.gsub(/:/, '_')
    #  class_path = "#{Puppet.settings[:libdir]}/spec/server/class/#{class_dir}"
    #  spec_dirs << class_path if File.directory? class_path
    #end                                                        
    out = StringIO.new                                       
    if RSpec::Core::Runner::run(spec_dirs, $stderr, out) == 0
      request.instance << Puppet::Util::Log.new(
        :message => out.string,
        :level   => :notice
      )
    else
      request.instance << Puppet::Util::Log.new(
        :message => out.string,
        :level   => :err
      )
    end
    # Reprocess final status
    request.instance.finalize_report

    processor.save(request)                    
  end                                                                                     
end

