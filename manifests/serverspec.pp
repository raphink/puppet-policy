# Definition: policy::serverspec
#
# Deploy an rspec file to :vardir/policy/server
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
# - Deploys an serverspec test file to :vardir/policy/server
#
# Sample Usage:
#
#   policy::serverspec { 'check ssh service':
#     ensure    => present,
#     classname => 'ssh',
#     content   => 'describe "ssh" do
#     it { should be_installed }
#     it { should be_running }
#     it { should be_enabled }
#   end',
#   }
#
define policy::serverspec (
  $ensure = 'present',
  $filename = '',
  $classname = $fqdn,
  $content = undef,
  $source = undef,
) {
  include ::policy

  if ($content and $source) {
    fail 'You must provide either $content or $source, not both'
  }
  if (!$content and !$source) {
    fail 'You must provide $content or $source'
  }
  $_filename = $filename ? {
    ''      => regsubst($name, "\W", '_', 'G'),
    default => $filename,
  }

  file { "${::policy::serverspec_dir}/${_filename}_spec.rb":
    ensure  => $ensure,
    content => $content,
    source  => $source,
  }
}
