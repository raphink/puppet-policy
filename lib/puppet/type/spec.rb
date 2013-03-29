Puppet::Type.newtype(:spec) do
  desc 'Assertion type'

  newparam(:test, :namevar => true) do
  end

  newparam(:should) do
  end

  newparam(:should_not) do
  end
end
