Puppetx::Policy::AutoSpec.newspec 'Package' do |p|
  providers = ['gem', 'pip']
  should = (p[:ensure] == 'absent' or p[:ensure] == 'purged') ? 'should_not' : 'should'
  provider = providers.include? p[:provider] ? ".by('#{p[:provider]}')" : ''
  "  describe package('#{p[:name]}') do\n    it { #{should} be_installed#{provider} }\n  end\n"
end
