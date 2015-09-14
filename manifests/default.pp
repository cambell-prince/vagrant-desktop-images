class base {
  # Ship our sources.list with all the pockets (especially multiverse)
  # enabled so that we can install virtualbox dkms packages.
  file { 'apt sources.list':
    path    => '/etc/apt/sources.list',
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    source  => "/vagrant/files/apt/sources-${operatingsystemrelease}.list",
  }
  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    timeout => 600,
    require => File['apt sources.list'],
  }
  exec { 'apt-get dist-upgrade':
    require => Exec['apt-get update'],
    command => '/usr/bin/apt-get dist-upgrade --yes',
    timeout => 3600,
  }
}

class grub {
  file { 'grub configuration':
    path    => '/etc/default/grub',
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    source  => '/vagrant/files/grub/grub',
  }
  exec { 'update-grub':
    require => File['grub configuration'],
    command => '/usr/sbin/update-grub',
  }
}

class virtualbox_x11 {
  package {
      "virtualbox-guest-dkms":      ensure => installed;
      "virtualbox-guest-x11":       ensure => installed;
  }
}

class lxde_desktop {
  package { "lubuntu-desktop":
    ensure => present,
    install_options => ['--no-install-recommends'],
  }
  file { 'lightdm.conf':
    require => Package['lubuntu-desktop'],
    path    => '/etc/lightdm/lightdm.conf',
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => "[SeatDefaults]\ngreeter-session=lightdm-greeter\nuser-session=Lubuntu\nautologin-user=vagrant\n"
  }
  # TODO Add package for pam_kwallet.so or similar that is missing.
  service { 'lightdm':
    require => File['lightdm.conf'],
    ensure  => running,
  }
}

class lxde_screensaver_settings {
  file { 'light-locker configuration':
    path    => '/etc/xdg/autostart/light-locker.desktop',
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    source  => "/vagrant/files/light-locker/light-locker.desktop",
  }
}

class unity_screensaver_settings {
  package { "dconf-tools":
    ensure  => present
  }
  exec {
      'disable screensaver when idle':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/screensaver/idle-activation-enabled false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/screensaver/idle-activation-enabled) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
      'disable screensaver lock':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/screensaver/lock-enabled false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/screensaver/lock-enabled) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
      'disable screensaver lock after suspend':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/screensaver/ubuntu-lock-on-suspend false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/screensaver/ubuntu-lock-on-suspend) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'set idle delay to zero':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/session/idle-delay 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/session/idle-delay) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'set idle delay to zero (2)':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/session/idle-delay 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/session/idle-delay) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'disable monitor sleep on AC':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/settings-daemon/plugins/power/sleep-display-ac 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/settings-daemon/plugins/power/sleep-display-ac) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'disable monitor sleep on battery':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/settings-daemon/plugins/power/sleep-display-battery 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/settings-daemon/plugins/power/sleep-display-battery) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'disable remind-reload query':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /apps/update-manager/remind-reload false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /apps/update-manager/remind-reload) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
  }
}

include base
include grub
include virtualbox_x11
include lxde_desktop
include lxde_screensaver_settings
# TODO Add a minimize section. Remove linux headers juju, juju-core, unused linux image etc
# include unity_desktop
# include unity_screensaver_settings
