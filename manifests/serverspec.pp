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

  file { "${settings::vardir}/spec/server/class/${classname}/${_filename}":
    ensure  => $ensure,
    content => $content,
    source  => $source,
  }
}
