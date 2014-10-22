require 'puppet/indirector/report/rest' 
require 'rubygems'
require 'rspec'
require 'serverspec' 
require 'stringio'
require 'facter' 


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
    # Extend report
    request.instance.extend(PuppetSpecReport)
      
    # Test by classes, including $certname                              
    spec_dirs = []
    # Classes cannot be acquired from request.node, get them from Puppet[:classfile]
    if File.exists? Puppet[:classfile]
      classes = open(Puppet[:classfile]).map { |line| line.chomp }
      classes.each do |c|
        class_dir = c.gsub(/:/, '_')
        [:libdir, :vardir].each do |d|
          class_path = "#{Puppet.settings[d]}/spec/server/class/#{class_dir}"
          spec_dirs << class_path if File.directory? class_path
        end
      end

    # Specinfra gets its default configuration from RSpec
    RSpec.configure do |c|
      c.backend = :exec
    end
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
      request.instance.status = 'failed'
    end

    processor.save(request)                    
  end                                                                                     
end

