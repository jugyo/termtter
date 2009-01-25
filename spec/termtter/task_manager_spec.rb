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

      due_tasks = @task_manager.pull_due_tasks
      due_tasks.size.should == 1
    end

    it 'should run tasks' do
      
    end
  end
end
