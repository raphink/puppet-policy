require 'spec_helper'
require 'puppetx/policy'
require 'puppetx/policy/auto_spec'
require 'puppetx/policy/auto_spec/user'

autospec = Puppetx::Policy::AutoSpec

describe 'the User auto_spec plugin' do
  it 'should be loaded' do
    autospec.auto_specs.size.should_not == 0
    autospec.auto_specs.select { |a| a[:type] == 'User' }.size.should == 1
  end

  context 'when using the plugin' do
    it 'should write a spec file' do
      File.stubs(:open) # Catch other calls
      File.expects(:open).with('/foo/bar/user_spec.rb', 'w').returns true
      autospec.gen_auto_spec_files([], '/foo/bar')
    end

    it 'should generate a serverspec file' do
      skip 'Need to implement this using a fixture catalog'
    end
  end
end
