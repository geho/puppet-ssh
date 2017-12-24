class ssh::client(
  String $ensure                = 'present',
  Boolean $storeconfigs_enabled = true,
  Array $options                = {},
  Boolean $use_augeas           = false,
  Array $options_absent         = [],
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_options = lookup("${module_name}::client::options", {merge => hash, default_value => {}})

  $fin_options = $hiera_options ? {
    undef   => $options,
    ''      => $options,
    default => $hiera_options,
  }

  if $use_augeas {
    $merged_options = sshclient_options_to_augeas_ssh_config($fin_options, $options_absent, { 'target' => $::ssh::params::ssh_config })
  } else {
    $merged_options = merge($ssh::params::ssh_default_options, $fin_options)
  }

  include ::ssh::client::install
  include ::ssh::client::config

  anchor { 'ssh::client::start': }
  anchor { 'ssh::client::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ::ssh::knownhosts

    Anchor['ssh::client::start']
    -> Class['ssh::client::install']
    -> Class['ssh::client::config']
    -> Class['ssh::knownhosts']
    -> Anchor['ssh::client::end']
  } else {
    Anchor['ssh::client::start']
    -> Class['ssh::client::install']
    -> Class['ssh::client::config']
    -> Anchor['ssh::client::end']
  }
}
