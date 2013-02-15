# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Termtter

  describe API do

    it 'tries authenticate 3 times' do
      pending("Not yet implemented")
      API.should_receive(:try_auth).
        exactly(3).times.
        and_return(false)
      API.should_receive(:exit!)
      API.setup
    end

    it 'can get twitter when success authentication' do
      pending("Not yet implemented")
      twitter = mock('twitter')
      API.should_receive(:try_auth).and_return(twitter)
      API.setup
      API.twitter.should == twitter
    end

    def it_should_examine_with(name, pass, options = {})
      config.user_name = name if name
      config.password  = pass if pass

      dummy_out = mock('stdout')
      dummy_out.stub(:ask) do |ask, _|
        $stdout.puts ask
        result = options.delete(
          case ask
          when /Username/ then :ui_name
          when /Password/ then :ui_pass
          end
        ) || ''
        result
      end
      API.stub(:create_highline => dummy_out)

      twitter = mock('twitter')
      twitter.stub(:verify_credentials) do
        if config.user_name.empty? || config.password.empty?
          raise Rubytter::APIError.new('error')
        end
      end
      RubytterProxy.stub(:new => twitter)

      API.try_auth.should == yield(twitter)

      config.__clear__(:user_name)
      config.__clear__(:password)
    end

    it 'can examine username and password (success)' do
      pending("Not yet implemented")
      it_should_examine_with('test', 'pass') {|twitter| twitter }
    end

    it 'can examine username and password (only name)' do
      pending("Not yet implemented")
      result = be_quiet(:stderr => false) {
        it_should_examine_with('test', nil) { nil }
      }
      result[:stdout].should ==
        "Please enter your Twitter login:\nUsername: test\nPassword: \n"
    end

    it 'can examine username and password (only pass)' do
      pending("Not yet implemented")
      result = be_quiet(:stderr => false) {
        it_should_examine_with(nil, 'pass') { nil }
      }
      result[:stdout].should ==
        "Please enter your Twitter login:\nUsername: \n"
    end

    it 'can examine username and password (both nil)' do
      pending("Not yet implemented")
      result = be_quiet(:stderr => false) {
        it_should_examine_with(nil, nil) { nil }
      }
      result[:stdout].should ==
        "Please enter your Twitter login:\nUsername: \nPassword: \n"
    end

    it 'can examine username and password (enter password)' do
      pending("Not yet implemented")
      be_quiet do
        args = ['test', nil, {:ui_pass => 'pass'}]
        it_should_examine_with(*args) {|twitter| twitter }
      end
    end

    it 'can examine username and password (enter username)' do
      pending("Not yet implemented")
      be_quiet do
        args = [nil, 'pass', {:ui_name => 'test'}]
        it_should_examine_with(*args) {|twitter| twitter }
      end
    end

    it 'can examine username and password (enter both)' do
      pending("Not yet implemented")
      be_quiet do
        args = [nil, nil,
          {:ui_name => 'test',
           :ui_pass => 'pass' }]
        it_should_examine_with(*args) {|twitter| twitter }
      end
    end
  end
end

