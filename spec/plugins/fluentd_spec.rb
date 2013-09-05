# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Termtter
  describe Client, 'when the plugin is loaded' do

    it 'should add commands' do
      config.plugins.fluentd.port = 49999
      config.plugins.fluentd.tag = "twitter.statuses"
      Termtter::Client.should_receive(:register_command).exactly(0)
      Termtter::Client.plug 'fluentd'
    end

  end
end
