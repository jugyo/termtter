# -*- coding: utf-8 -*-

module Termtter
  class TaskManager

    INTERVAL = 1

    def initialize()
      @tasks = {}
      @work  = true
      @mutex = Mutex.new
      @pause = false
    end

    def pause
      @pause = true
    end

    def resume
      @pause = false
    end

    def kill
      @work = false
    end

    def run
      Thread.new do
        while @work
          step unless @pause
          sleep INTERVAL
        end
      end
    end

    def step
      pull_due_tasks.each do |task|
        invoke_and_wait do
          task.execute
        end
      end
    end

    def invoke_later
      Thread.new do
        invoke_and_wait { yield }
      end
    end

    def invoke_and_wait(&block)
      synchronize do
        yield
      end
    end

    def add_task(args = {}, &block)
      synchronize do
        task = Task.new(args, &block)
        @tasks[task.name || task.object_id] = task
      end
    end

    def get_task(key)
      synchronize do
        @tasks[key]
      end
    end

    def delete_task(key)
      synchronize do
        @tasks.delete(key)
      end
    end

    private

    def synchronize
      unless Thread.current == @thread_in_sync
        @mutex.synchronize do
          @thread_in_sync = Thread.current
          yield
        end
      else
        yield
      end
    end

    def pull_due_tasks()
      synchronize do
        time_now  = Time.now
        due_tasks = []
        @tasks.delete_if do |key, task|
          if task.work && task.exec_at <= time_now
            due_tasks << task
            if task.interval
              task.exec_at = time_now + task.interval
              false
            else
              true
            end
          else
            false
          end
        end
        return due_tasks
      end
    end

  end
end
