module MCollective
  module Agent
    class Spec < RPC::Agent
      action 'check' do
        begin
          require 'facter'
          require 'rspec'
          require 'serverspec'
        rescue Exception => e
          reply.fail! e.to_s
        end

        # Specinfra gets its default configuration from RSpec
        RSpec.configure do |c|
          c.backend = :exec
        end

        values = request[:values].split(",").map { |v| v == 'nil' ? nil : v }
        if backend.send("check_#{request[:action]}", *values)
          reply[:passed] = true
        else
          reply[:passed] = false
        end
      end

      action 'run' do
        begin
          require 'facter'
          require 'rspec'
          require 'serverspec'
          require 'puppet'

        rescue Exception => e
          reply.fail! e.to_s
        end

        spec_dir = File.join(::Puppet.settings[:vardir], 'policy', 'server')

        # Specinfra gets its default configuration from RSpec
        RSpec.configure do |c|
          c.backend = :exec
        end

        out = StringIO.new                                       
        if RSpec::Core::Runner::run([spec_dir], $stderr, out) == 0
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
