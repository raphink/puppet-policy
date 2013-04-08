module MCollective
  module Agent
    class Spec < RPC::Agent
      action 'check' do
        begin
          require 'serverspec'
          require 'facter'
        rescue Exception => e
          reply.fail! e.to_s
        end

        commands = nil
        case Facter.value(:osfamily)
          when 'Debian'
            commands = Serverspec::Commands::Debian.new
          when 'RedHat'
            commands = Serverspec::Commands::RedHat.new
          when 'Gentoo'
            commands = Serverspec::Commands::Gentoo.new
          when 'Solaris'
            commands = Serverspec::Commands::Solaris.new
        end

        backend = Serverspec::Backend::Exec.new(commands)

        if backend.send("check_#{request[:action]}", request[:values])
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
            helper_class = Serverspec::Helper::Debian
          when 'RedHat'
            helper_class = Serverspec::Helper::RedHat
          when 'Gentoo'
            helper_class = Serverspec::Helper::Gentoo
          when 'Solaris'
            helper_class = Serverspec::Helper::Solaris
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
