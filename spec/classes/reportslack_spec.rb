require 'spec_helper'
require 'shared_contexts'

describe 'reportslack' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      webhook: nil,
      channel: nil,
      # section: "user",

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  it do
    is_expected.to contain_package('slack-notifier').with(
      ensure: 'latest',
      provider: 'puppet_gem',
      )
  end  
  it do
    is_expected.to contain_ini_setting('enable_reports').with(
      ensure: 'present',
      section: 'user',
      setting: 'report',
      value: true,
      path: '$settings::confdir/puppet.conf',
      )
  end  
  it do
    is_expected.to contain_ini_subsetting('slack_report_handler').with(
      ensure: 'present',
      path: '$settings::confdir/puppet.conf',
      section: 'user',
      setting: 'reports',
      subsetting: 'slack',
      subsetting_separator: ',',
      require: 'Ini_setting[enable_reports]',
      )
  end  
  it do
    is_expected.to contain_file('$settings::confdir/slack.yaml').with(
      ensure: 'present',
      owner: 'root',
      group: 'root',
      mode: '0644',
      content: [],
      require: 'Package[slack-notifier]',
      )
  end  
end
