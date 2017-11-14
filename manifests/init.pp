# Authors
# -------
#
# Nicolas Corrarello <nicolas@corrarello.com>
#
# Copyright
# ---------
#
# Copyright 2016 Nicolas Corrarello, unless otherwise noted.
#
class reportslack (
  String $webhook,
  String $channel,
  String $icon_url = 'https://learn.puppet.com/static/images/logos/Puppet-Logo-Mark-Amber.png',
  String $icon_emoji = ':excellent:',
  String $section = 'user'
) {
  validate_re($webhook, 'https:\/\/hooks.slack.com\/(services\/)?T.+\/B.+\/.+', 'The webhook URL is invalid')
  validate_re($channel, '#.+', 'The channel should start with a hash sign')

  package { 'slack-notifier':
    ensure   => latest,
    provider => 'puppet_gem'
  }

  ini_setting { 'enable_reports':
    ensure  => present,
    section =>  $section,
    setting => 'report',
    value   => true,
    path    => "${settings::confdir}/puppet.conf",
  }

  ini_subsetting { 'slack_report_handler':
    ensure               => present,
    path                 => "${settings::confdir}/puppet.conf",
    section              =>  $section,
    setting              => 'reports',
    subsetting           => 'slack',
    subsetting_separator => ',',
    require              => Ini_setting['enable_reports'],
  }

  file { "${settings::confdir}/slack.yaml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('reportslack/slack.yaml.erb'),
    require => Package['slack-notifier'],
  }
}
