Puppetx::Policy::AutoSpec.newspec 'Package' do |p|
  provider = ""
  providers = ['gem', 'pip']
  should = (p[:ensure] == 'absent' or p[:ensure] == 'purged') ? 'should_not' : 'should'
  if providers.include? p[:provider]
    provider = ".by('#{p[:provider]}')"
  end
  "  describe package('#{p[:name]}') do\n    it { #{should} be_installed#{provider} }\n  end\n"
end
