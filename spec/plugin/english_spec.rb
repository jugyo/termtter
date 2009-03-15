# -*- coding: utf-8 -*-
# vim: set fenc=utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter do
  it 'english?' do
    Termtter::Client.should_receive(:add_filter)
    plugin 'english'
    Termtter::English.english?('This is a pen.').should be_true
    Termtter::English.english?('これはペンです.').should be_false
    Termtter::English.english?('これはpenです.').should be_false
  end
end
