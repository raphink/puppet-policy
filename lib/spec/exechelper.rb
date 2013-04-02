module PuppetSpec
  module ExecHelper
    def ssh_exec(cmd, opts={})
      stdin, stdout, stderr = Open3.popen3(cmd)
      { :stdout => stdout.gets, :stderr => stderr.gets, :exit_code => $?.to_i, :exit_signal => nil }
    end
  end
end
