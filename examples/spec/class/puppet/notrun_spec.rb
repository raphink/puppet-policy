describe 'notrun' do
  subject { YAML.load_file('/tmp/catalog') }
  it { should contain_package('ppet') }
end
