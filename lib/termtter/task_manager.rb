module Termtter
  class TaskManager

    Interval = 1

    def initialize()
      @tasks = []
    end

    # TODO: to thread safe
    def add_task(args = {}, &block)
      @tasks << Task.new(args, &block)
    end

    # TODO: to thread safe
    def pull_due_tasks()
      time_now = Time.now
      due_tasks = []
      @tasks.delete_if do |task|
        if task.exec_at <= time_now
          due_tasks << task
          true
        else
          false
        end
      end
      return due_tasks
    end

    def run
      Thread.new do
        loop do
          pull_due_tasks().each do |task|
            begin
              task.execute
            rescue => e
              handle_error(e)
            end
          end
          sleep Interval
        end
      end
    end

  end
end
