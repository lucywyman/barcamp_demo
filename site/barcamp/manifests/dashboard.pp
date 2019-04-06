class barcamp::dashboard (
  String $grafana_password = $barcamp::params::grafana_password,
  String $grafana_user = $barcamp::params::grafana_user,
  String $grafana_url = $barcamp::params::grafana_url,
  String $influx_password = $barcamp::params::influxdb_password,
  String $influx_database = $barcamp::params::influxdb_database,
  String $influx_username = $barcamp::params::influxdb_user,

) inherits ::barcamp::params {
  # TODO: Do we need to create this user?
  user { 'bolt':
    ensure   => present,
    password => 'bolt',

  }

  class { 'grafana':
    cfg => {
      app_mode => 'production',
      server   => {
        http_port     => 8080,
      },
      security => {
        admin_user => $grafana_user,
        admin_password => $grafana_password,
      },
      database => {
        type          => 'sqlite3',
        host          => '127.0.0.1:3306',
        name          => 'grafananana',
      },
    },
  }

  class {'influxdb': }
  influx_database{$influx_database:
    superuser => $influx_username,
    superpass => $influx_password
  }

  grafana_datasource { 'influxdb':
    require           => Influx_database['bolt'],
    grafana_url       => $grafana_url,
    grafana_user      => $grafana_user,
    grafana_password  => $grafana_password,
    type              => 'influxdb',
    url               => 'http://localhost:8086',
    user              => $influx_username,
    password          => $influx_password,
    database          => $influx_database,
    access_mode       => 'proxy',
    is_default        => true,
  }

  grafana_dashboard { 'telegraf':
    grafana_url       => $grafana_url,
    grafana_user      => $grafana_user,
    grafana_password  => $grafana_password,
    content           => template('barcamp/dashboards/telegraf.json')
  }
}
