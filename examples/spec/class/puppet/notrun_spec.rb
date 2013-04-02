describe 'notrun' do
  subject { PuppetSpec::Catalog.instance.catalog }
  it { should contain_package('ppet') }
end
