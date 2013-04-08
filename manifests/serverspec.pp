# Definition: spec::serverspec
#
# Deploy an rspec file to :vardir/spec/server/class/
#
# Parameters:
#   ['ensure']    - Whether the test should be present or absent
#   ['filename']  - The file name for the test, optional
#   ['classname'] - The class name the test should be associated with,
#                   defaults to $fqdn
#   ['content']   - The content of the test file (rspec code)
#   ['source']    - Source of the test file (unless content is specified)
#
# Actions:
# - Deploys an serverspec test file to :vardir/spec/server/class
#
# Sample Usage:
#
#   spec::serverspec { 'check ssh service':
#     ensure    => present,
#     classname => 'ssh',
#     content   => 'describe "ssh" do
#     it { should be_installed }
#     it { should be_running }
#     it { should be_enabled }
#   end',
#   }
#
define spec::serverspec (
  $ensure = 'present',
  $filename = '',
  $classname = $fqdn,
  $content = undef,
  $source = undef,
) {
  if ($content and $source) {
    fail 'You must provide either $content or $source, not both'
  }
  if (!$content and !$source) {
    fail 'You must provide $content or $source'
  }
  $_filename = $filename ? {
    ''      => regsubst($name, "\W", "_", "G"),
    default => $filename,
  }

  file { "${settings::vardir}/spec/server/class/${classname}/${_filename}_spec.rb":
    ensure  => $ensure,
    content => $content,
    source  => $source,
  }
}
