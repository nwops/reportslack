require 'puppet'
require 'yaml'
require 'slack-notifier'

Puppet::Reports.register_report(:slack) do
	if (Puppet.settings[:config]) then
		configfile = File.join([File.dirname(Puppet.settings[:config]), "slack.yaml"])
	else
		configfile = "/etc/puppetlabs/puppet/slack.yaml"
	end
  Puppet.debug "Reading #{configfile}"
	config = YAML.load_file(configfile)
	SLACK_WEBHOOK_URL = config['webhook_url']
	SLACK_ICON_URL    = config['icon_url']     || ''
  Puppet.debug "Webhook is #{SLACK_WEBHOOK_URL}"
	SLACK_ICON_EMOJI  = config['icon_emoji']    || ''
	SLACK_CHANNEL = config['channel']
	DISABLED_FILE = File.join([File.dirname(Puppet.settings[:config]), 'slack_disabled'])

	def process
		disabled = File.exists?(DISABLED_FILE)
		options = {
       webhook_url: SLACK_WEBHOOK_URL,
       channel:     SLACK_CHANNEL
    }
		options[:icon_url]   = SLACK_ICON_URL   unless SLACK_ICON_URL.empty?
		options[:icon_emoji] = SLACK_ICON_EMOJI unless SLACK_ICON_EMOJI.empty?
		if (!disabled && self.status != 'unchanged')
			Puppet.debug "Sending notification for #{self.host} to Slack channel #{SLACK_CHANNEL}"
			msg = "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime} on #{self.configuration_version} in #{self.environment}."
			notifier = Slack::Notifier.new SLACK_WEBHOOK_URL, channel: SLACK_CHANNEL, username: 'Puppet'
			notifier.ping msg, options
		end
	end
end
