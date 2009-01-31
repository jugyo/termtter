# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'termtter/task'

module Termtter
  describe Task do

    it 'should be instantiate' do
      time_now = Time.now
      Time.stub!(:now).and_return(time_now)

      task = Task.new() do
      end
      task.exec_at.should == time_now

      task = Task.new(:after => 10) do
      end
      task.exec_at.should == (time_now + 10)
    end
  end
end
