# Class: rabbitmq::service
#
#   This class manages the rabbitmq server service itself.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class rabbitmq::service(
  $service_ensure = $rabbitmq::service_ensure,
  $service_manage = $rabbitmq::service_manage,
  $service_name   = $rabbitmq::service_name,
  $rabbitmq_user   = $rabbitmq::rabbitmq_user,
) inherits rabbitmq {

  validate_re($service_ensure, '^(running|stopped)$')
  validate_bool($service_manage)

  if ($service_manage) {
    if $service_ensure == 'running' {
      $ensure_real = 'running'
      $enable_real = true
    } else {
      $ensure_real = 'stopped'
      $enable_real = false
    }

    $service_file_name = 'rabbitmq-server'
    $service_file      = "/etc/init.d/${service_file_name}"
    $platform          = downcase($::osfamily)

    file { $service_file:
      ensure  => file,
      content => template("rabbitmq/service.${platform}.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => 0755,
    }

    service { $service_file_name:
      ensure     => $ensure_real,
      enable     => $enable_real,
      hasstatus  => true,
      hasrestart => true,
      name       => $service_name,
      require    => File[$service_file],
    }
  }

}
