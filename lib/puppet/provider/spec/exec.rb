Puppet::Type.type(:spec).provide(:exec) do
  require 'rspec'
  desc 'Exec provider for the spec type'

  def run
    output = Puppet::Util::Execution.execute(resource[:test])
    if resource[:type] == 'output'
      if resource[:should]
        output.should == resource[:should]
      end
    elsif resource[:type] == 'output_match'
      if resource[:should]
        output.should =~ resource[:should]
      end
    #elsif resource[:type] == :exit
    else
      raise Puppet::Error, "Unknown spec type #{resource[:type]}"
    end
  end
end
