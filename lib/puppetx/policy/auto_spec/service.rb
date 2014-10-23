Puppetx::Policy::AutoSpec.newspec 'Service' do |s|
  content = "  describe service('#{s[:name]}') do\n"
  content += "    it { should be_enabled }\n" if s[:enable] == true
  content += "    it { should_not be_enabled }\n" if s[:enable] == false
  content += "    it { should be_running }\n" if s[:ensure] == 'running'
  content += "    it { should_not be_running }\n" if s[:ensure] == 'stopped'
  content += "  end\n"
  content
end
