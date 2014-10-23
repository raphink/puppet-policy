Puppetx::Policy::AutoSpec.newspec 'Group' do |g|
  content = "  describe group('#{g[:name]}') do\n"
  if u[:ensure] == 'present'
    content += "    it { should exist }\n"
    content += "    it { should have_gid('#{g[:gid]}') }\n" if g[:gid]
  else
    content += "    it { should_not exist }\n"
  end
  content += "  end\n"
end

