# Class: policy
#
# Setup directories for the policy module
class policy ( 
  # $settings::vardir returns the MASTER's :vardir, not the agent's
  # We might have to deploy a fact to get the client's :vardir,
  # or write a type/provider
  $spec_dir = "${settings::vardir}/policy",
  $serverspec_dir = "${spec_dir}/server",
) {
  file { [$spec_dir, $serverspec_dir]:
    ensure => 'directory',
    purge  => 'true',
  }
}
