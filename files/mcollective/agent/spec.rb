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
        end

        backend = Serverspec::Backend::Exec.new(commands)

        if backend.send("check_#{request[:action]}", request[:values])
          reply[:passed] = true
        else
          reply[:passed] = false
        end
      end
    end
  end
end
