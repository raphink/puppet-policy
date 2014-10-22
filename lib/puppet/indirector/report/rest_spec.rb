require 'puppet/indirector/report/rest' 
require 'rubygems'
require 'rspec'
require 'serverspec' 
require 'stringio'
require 'facter' 


module PuppetSpecReport
  def status= (status)
    @status = status
  end
end
  
class Puppet::Transaction::Report::RestSpec < Puppet::Transaction::Report::Rest 
  desc "Run functional tests then get server report over HTTP via REST." 
      
  def processor
    @processor ||= indirection.terminus(:rest)
  end                                                 

  def auto_spec(type, &block)
    @auto_specs ||= {}
    @auto_specs[type] = block
  end

  def gen_auto_spec_files(resources, spec_dir)
    @auto_specs.each do |type, block|
      spec_content = "describe '#{type} resources' do\n"
      spec_content += resources.map do |r|
        next unless r.type == type
        block.call(r.to_hash)
      end.compact.join("\n")
      spec_content += "end\n"

      file_name = type.downcase.gsub(':', '_') + '_spec.rb'
      file = File.join(spec_dir, file_name)

      File.open(file, 'w') do |f|
        f.write(spec_content)
      end
    end

  end

  def save(request)

    # TODO: These will become plugins in the near future
    auto_spec 'Package' do |p|
      should = (p[:ensure] == 'absent' or p[:ensure] == 'purged') ? 'should_not' : 'should'
      "  describe package('#{p[:name]}') do\n    it { #{should} be_installed }\n  end\n"
    end

    auto_spec 'Service' do |s|
      content = "  describe service('#{s[:name]}') do\n"
      content += "    it { should be_enabled }\n" if s[:enable] == true
      content += "    it { should_not be_enabled }\n" if s[:enable] == false
      content += "    it { should be_running }\n" if s[:ensure] == 'running'
      content += "    it { should_not be_running }\n" if s[:ensure] == 'stopped'
      content += "  end\n"
      content
    end

    auto_spec 'File' do |f|
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

    auto_spec 'User' do |u|
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

    # Generate serverspec files
    # TODO: Check that we get the catalog from cache
    resources = Puppet::Resource::Catalog.indirection.find(request.instance.host).resources
    auto_spec_dir = File.join(Puppet[:vardir], 'spec')
    gen_auto_spec_files(resources, auto_spec_dir)

    # Extend report
    request.instance.extend(PuppetSpecReport)

    # Specinfra gets its default configuration from RSpec
    RSpec.configure do |c|
      c.backend = :exec
    end

    spec_dirs = [auto_spec_dir]
    # Classes cannot be acquired from request.node, get them from Puppet[:classfile]
    if File.exists? Puppet[:classfile]
      classes = open(Puppet[:classfile]).map { |line| line.chomp }
      classes.each do |c|
        class_dir = c.gsub(/:/, '_')
        [:libdir, :vardir].each do |d|
          class_path = "#{Puppet.settings[d]}/spec/server/class/#{class_dir}"
          spec_dirs << class_path if File.directory? class_path
        end
      end
    end

    out = StringIO.new                                       
    if RSpec::Core::Runner::run(spec_dirs, $stderr, out) == 0
      request.instance << Puppet::Util::Log.new(
        :message => out.string,
        :level   => :notice
      )
    else
      request.instance << Puppet::Util::Log.new(
        :message => out.string,
        :level   => :err
      )
      request.instance.status = 'failed'
    end

    processor.save(request)                    
  end                                                                                     
end

