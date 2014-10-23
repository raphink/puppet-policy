Puppetx::Policy::AutoSpec.newspec 'Package' do |p|
  should = (p[:ensure] == 'absent' or p[:ensure] == 'purged') ? 'should_not' : 'should'
  "  describe package('#{p[:name]}') do\n    it { #{should} be_installed }\n  end\n"
end
