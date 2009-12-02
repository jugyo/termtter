# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'termtter/task'
require 'termtter/task_manager'

module Termtter
  describe TaskManager do
    before do
      @task_manager = TaskManager.new
    end

    it 'should able to add tasks' do
      @task_manager.add_task() {}
      @task_manager.add_task(:after => 10) {}
      @task_manager.instance_eval('@tasks').size.should == 2
    end

    it 'should return due_tasks' do
      time_now = Time.now
      Time.stub!(:now).and_return(time_now)

      @task_manager.add_task() {}
      @task_manager.add_task(:after => 10) {}

      due_tasks = @task_manager.instance_eval('pull_due_tasks')
      due_tasks.size.should == 1
    end

    it 'should run tasks' do
      time_now = Time.now
      Time.stub!(:now).and_return(time_now)

      task1_called = false
      task2_called = false
      @task_manager.add_task() {task1_called = true}
      @task_manager.add_task(:after => 10) {task2_called = true}

      task1_called.should == false
      task2_called.should == false
      @task_manager.instance_eval('@tasks').size.should == 2

      @task_manager.step
      task1_called.should == true
      task2_called.should == false
      @task_manager.instance_eval('@tasks').size.should == 1

      Time.stub!(:now).and_return(time_now + 10)
      @task_manager.step
      task2_called.should == true
      @task_manager.instance_eval('@tasks').size.should == 0
    end

    it 'should run repeat tasks' do
      time_now = Time.now
      Time.stub!(:now).and_return(time_now)

      called_count = 0
      @task_manager.add_task(:interval => 10) {called_count += 1}
      @task_manager.step

      called_count.should == 1
      @task_manager.instance_eval('@tasks').size.should == 1

      Time.stub!(:now).and_return(time_now + 10)
      @task_manager.step
      called_count.should == 2
      @task_manager.instance_eval('@tasks').size.should == 1
    end

    it 'should run (not pause)' do
      be_quiet do
        counter = 0
        TaskManager::INTERVAL = 0
        @task_manager.stub(:step) { counter += 1 }
        @task_manager.instance_variable_set(:@work, true)
        @task_manager.run
        100.times do
          break if counter != 0
          sleep 0.1
        end
        @task_manager.instance_variable_set(:@work, false)
        counter.should > 0
      end
    end

    it 'should run (pause)' do
      be_quiet do
        counter = 0
        TaskManager::INTERVAL = 0.1
        @task_manager.stub(:step) { counter += 1 }
        @task_manager.instance_variable_set(:@work, true)
        @task_manager.instance_variable_set(:@pause, true)
        @task_manager.run
        sleep 0.1
        counter.should == 0
        @task_manager.instance_variable_set(:@pause, false)
        100.times do
          break if counter != 0
          sleep 0.1
        end
        @task_manager.instance_variable_set(:@work, false)
        counter.should > 0
      end
    end

    it 'should add task with :name' do
      @task_manager.add_task(:name => 'foo')
      @task_manager.get_task('foo').name.should == 'foo'
      @task_manager.delete_task('foo')
      @task_manager.get_task('foo').should == nil
    end

    it 'should be killed' do
      @task_manager.instance_eval('@work').should == true
      @task_manager.kill
      @task_manager.instance_eval('@work').should == false
    end

    it 'should be paused or resumed' do
      @task_manager.instance_eval('@pause').should == false
      @task_manager.pause
      @task_manager.instance_eval('@pause').should == true
      @task_manager.resume
      @task_manager.instance_eval('@pause').should == false
    end

    it 'invoke_later calls invoke_and_wait' do
      called = false
      block = lambda { called = true}
      @task_manager.should_receive(:invoke_and_wait).with(&block)
      @task_manager.invoke_later(&block).join
      called.should be_true
    end
  end
end
