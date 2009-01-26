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
  end
end
