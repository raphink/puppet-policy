# Class: spec
#
# Setup directories for the spec module
class spec ( 
  # $settings::vardir returns the MASTER's :vardir, not the agent's
  # We might have to deploy a fact to get the client's :vardir,
  # or write a type/provider
  $serverspec_dir = "${settings::vardir}/spec/server",
) {
  file { $serverspec_dir:
    ensure => 'directory',
    purge  => 'true',
  }
}
