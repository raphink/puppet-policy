Puppetx::Policy::AutoSpec.newspec 'File' do |f|
  content = "  describe file('#{f[:path]}') do\n"
  case f[:ensure]
  when 'file', 'present'
    content += "    it { should be_file }\n"
  when 'directory'
    content += "    it { should be_directory }\n"
  when 'symlink'
    content += "    it { should be_linked_to '#{f[:target]}' }\n"
  end
  if f[:content]
    # Beware of escaping content!
    #content += "    its(:content) { should == '#{f[:content]}' }\n"
  end
  content += "  end\n"
  content
end
