exec { 'apt-get_update':
    command => 'apt-get update',
    path => '/usr/bin'
}

package { [
    'curl',
    'vim',
    'g++',
    'make',
    'git'
    ]:
    ensure => installed,
    require => Exec['apt-get_update']
}

class { 'nodejs':
    manage_repo => true,
    require => Exec['apt-get_update']
}

package { [
    'pm2',
    'express',
    'bower'
    ]:
    ensure => present,
    provider => 'npm',
    require => [
        Class['nodejs'],
        Package['make'],
        Package['git']
    ]
}

exec { 'install_npm_packages':
    command => 'npm install',
    path => '/usr/bin',
    cwd => '/var/src/app',
    require => Class['nodejs']
}

file{ 'init_bower_directory':
    name => "/var/src/app/public/bower_components",
    purge => true,
    recurse => true,
    force => true,
    backup => false
}

exec { 'install_bower_packages':
    command => 'bower install --verbose --config.interactive=false',
    path => '/usr/bin',
    cwd => '/var/src/app',
    require => [
        File['init_bower_directory'],
        Package['bower']
    ]
}

exec { 'auto_start_app':
    command => 'pm2 start /var/src/app/app.js -i max',
    path => '/usr/bin',
    require => [
        Exec['install_npm_packages'],
        Exec['install_bower_packages'],
        Package['pm2']
    ]
}