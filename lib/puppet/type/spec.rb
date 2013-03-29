Puppet::Type.newtype(:spec) do
  desc 'Assertion type'

  newparam(:test, :namevar => true) do
  end

  newproperty(:should) do
    def insync?(is)
      false
    end

    def sync
      @resource.provider.run
    end
  end

  newproperty(:should_not) do
    def insync?(is)
      false
    end

    def sync
      @resource.provider.run
    end
  end

  newparam(:type) do
  end

  def sync
    provider.run(@resource.provider.run)
  end
end
