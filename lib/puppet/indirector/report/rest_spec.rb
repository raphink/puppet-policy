require 'puppet/indirector/report/rest' 
require 'rubygems'
require 'rspec'
require 'serverspec' 
require 'stringio'
require 'open3'
require Puppet.settings[:libdir] + '/spec/exechelper.rb' 
require 'facter' 
  
class Puppet::Transaction::Report::RestSpec < Puppet::Transaction::Report::Rest 
  desc "Run functional tests then get server report over HTTP via REST." 
      
  def processor
    @processor ||= indirection.terminus(:rest)
  end                                                 

  def save(request)
    case Facter.value(:osfamily)                           
      when 'Debian'
        helper_class = Serverspec::DebianHelper
      when 'RedHat'        
        helper_class = Serverspec::RedHatHelper  
      when 'Gentoo'
        helper_class = Serverspec::GentooHelper     
      when 'Solaris'
        helper_class = Serverspec::SolarisHelper
      else
        raise Puppet::Error, "Could not determine a helper to use for functional tests for OS family #{Facter.value(:osfamily)}"
    end

    RSpec.configure do |c|
      c.include(helper_class)
      c.include(PuppetSpec::ExecHelper)
    end
      
    # Test by classes, including $certname                              
    spec_dirs = []
    spec_dirs = ["#{Puppet.settings[:libdir]}/spec/server/class/test"]
    # TODO: get classes for current node
    #classes.each do |c|
    #  class_dir = c.gsub(/:/, '_')
    #  class_path = "#{Puppet.settings[:libdir]}/spec/server/class/#{class_dir}"
    #  spec_dirs << class_path if File.directory? class_path
    #end                                                        
    out = StringIO.new                                       
    unless RSpec::Core::Runner::run(spec_dirs, $stderr, out) == 0
      raise Puppet::Error, "Unit tests failed:\n#{out.string}"
    end

    processor.save(request)                    
  end                                                                                     
end

