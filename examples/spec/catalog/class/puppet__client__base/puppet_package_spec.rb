describe 'puppet' do
  subject { PuppetSpec::Catalog.instance.catalog }
  it { should contain_package('puppet') }
  it { should contain_package('ppet') }
  it { should include_class('puppet') }
  it { should include_class('puppet::client::base') }
end
