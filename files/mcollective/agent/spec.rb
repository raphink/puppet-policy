module MCollective
  module Agent
    class Spec < RPC::Agent
      action 'check' do
        begin
          require 'specinfra'
          require 'facter'
        rescue Exception => e
          reply.fail! e.to_s
        end

        backend = SpecInfra::Helper::Backend.backend_for(:exec)

        values = request[:values].split(",").map { |v| v == 'nil' ? nil : v }
        if backend.send("check_#{request[:action]}", *values)
          reply[:passed] = true
        else
          reply[:passed] = false
        end
      end

      action 'run' do
        begin
          require 'serverspec'
          require 'facter'
          require 'rspec'
          require 'puppet'
        rescue Exception => e
          reply.fail! e.to_s
        end

        helper_class = nil
        case Facter.value(:osfamily)
          when 'Debian'
            helper_class = SpecInfra::Helper::Debian
          when 'RedHat'
            helper_class = SpecInfra::Helper::RedHat
          when 'Gentoo'
            helper_class = SpecInfra::Helper::Gentoo
          when 'Solaris'
            helper_class = SpecInfra::Helper::Solaris
        end

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
        end

        RSpec.configure do |c|
          c.include(helper_class)
          c.include(Serverspec::Helper::Exec)
        end

        out = StringIO.new                                       
        if RSpec::Core::Runner::run(spec_dirs, $stderr, out) == 0
          reply[:passed] = true
          reply[:output] = out.string
        else
          reply[:passed] = false
          reply[:output] = out.string
        end
      end
    end
  end
end
