Puppetx::Policy::AutoSpec.newspec 'User' do |u|
  content = "  describe user('#{u[:name]}') do\n"
  content += "    it { should exist }\n" if u[:ensure] == 'present'
  content += "    it { should_not exist }\n" if u[:ensure] == 'absent'
  content += "    it { should have_uid('#{u[:uid]}') }\n" if u[:uid]
  content += "    it { should belong_to_group('#{u[:gid]}') }\n" if u[:gid]
  (u[:groups] || []).any? do |g|
    content += "    it { should belong_to_group('#{g}') }\n"
  end
  content += "    it { should have_home_directory('#{u[:home]}') }\n" if u[:home]
  content += "    it { should have_login_shell('#{u[:shell]}') }\n" if u[:shell]
  content += "  end\n"
  content
end
