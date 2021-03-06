node 'sensu-server' {

  class { 'sensu':
    rabbitmq_password => 'secret',
    server            => true,
    rabbitmq_port     => '5672',
    rabbitmq_host     => '192.168.50.4',
    subscriptions     => 'sensu-test',
    require           => [
      Class['redis'],
      Class['rabbitmq::server'],
    ]
  }

  sensu::check { 'check_success':
    command     => 'echo "success"',
    handlers    => 'default',
    subscribers => 'sensu-test',
  }

  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' your@address',
  }

  class { 'rabbitmq::server':
    env_config => "RABBITMQ_NODE_PORT=5672\nRABBITMQ_NODE_IP_ADDRESS=192.168.50.4\n",
  }

  rabbitmq_vhost { '/sensu':
    ensure   => present,
    provider => 'rabbitmqctl',
  }

  rabbitmq_user { 'sensu':
    admin    => true,
    password => 'secret',
    provider => 'rabbitmqctl',
  }

  rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    provider             => 'rabbitmqctl',
  }

  class { 'redis':
    version => '2.6.5',
  }

}

node 'sensu-client' {
  class { 'sensu':
    rabbitmq_password => 'secret',
    rabbitmq_port     => '5672',
    rabbitmq_host     => '192.168.50.4',
    subscriptions     => 'sensu-test',
  }
}
