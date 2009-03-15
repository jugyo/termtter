# -*- coding: utf-8 -*-
# vim: set fenc=utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter do
  it 'english? method' do
    Termtter::Client.should_receive(:add_filter)
    plugin 'english'
    Termtter::English.english?('This is a pen.').should be_true
    Termtter::English.english?('これはペンです.').should be_false
    Termtter::English.english?('これはpenです.').should be_false
  end

  it 'apply filter english only update_friends_timeline'
  # NOTE: when below code is evaluated,
  #     plugin 'english', :only => :update_friends_timeline
  #   in update_friends_timeline there are English posts only but in replies there are both Japanese posts and English posts.
  #   It's too difficult for me to write that spec, so this spec is pending now. Please write this spec, hey, you, a cool hacker!
end
