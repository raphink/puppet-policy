require 'spec_helper'
require 'puppetx/policy'
require 'puppetx/policy/auto_spec'
require 'puppetx/policy/auto_spec/file'

autospec = Puppetx::Policy::AutoSpec

describe 'the File auto_spec plugin' do
  it 'should be loaded' do
    autospec.auto_specs.size.should_not == 0
    autospec.auto_specs.select { |a| a[:type] == 'File' }.size.should == 1
  end

  context 'when using the plugin' do
    it 'should write a spec file' do
      File.stubs(:open) # Catch other calls
      File.expects(:open).with('/foo/bar/file_spec.rb', 'w').returns true
      autospec.gen_auto_spec_files([], '/foo/bar')
    end

    it 'should generate a serverspec file' do
      skip 'Need to implement this using a fixture catalog'
    end
  end
end
