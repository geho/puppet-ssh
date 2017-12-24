define ssh::server::options ($options, Integer $order = 50) {
  concat::fragment { "options ${name}":
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/options.erb"),
    order   => 100+$order,
  }
}
