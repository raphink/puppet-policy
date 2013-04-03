module PuppetSpec
  module ExecHelper
    def ssh_exec(cmd, opts={})
      stdout, stderr, status = Open3.capture3(cmd)
      { :stdout => stdout, :stderr => stderr,
        :exit_code => status, :exit_signal => nil }
    end
  end
end
