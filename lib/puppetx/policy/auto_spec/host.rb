Puppetx::Policy::AutoSpec.newspec 'Host' do |h|
  content = ''
  should = (h[:ensure] == 'present') ? 'should' : 'should_not'
  [h[:name], h[:host_aliases]].flatten.each do |host|
    content += "  describe host('#{h[:name]}') do\n"
    content += "    it { #{should} be_resolvable_by('hosts') }\n"
    content += "    its(:ipaddress) { #{should} eq '#{h[:ip]}' }\n"
    content += "  end\n"
  end
  content
end
