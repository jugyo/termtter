module Termtter
  class TaskManager

    INTERVAL = 1

    def initialize()
      @tasks = {}
      @work = true
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
      @mutex.synchronize do
        pull_due_tasks().each do |task|
          begin
            task.execute
          rescue => e
            Termtter::Client.handle_error(e)
          end
        end
      end
    end

    def invoke_later
      @mutex.synchronize do
        begin
          yield
        rescue => e
          Termtter::Client.handle_error(e)
        end
      end
    end

    def add_task(args = {}, &block)
      @mutex.synchronize do
        task = Task.new(args, &block)
        @tasks[task.name || task.object_id] = task
      end
    end

    def get_task(key)
      @mutex.synchronize do
        @tasks[key]
      end
    end

    def delete_task(key)
      @mutex.synchronize do
        @tasks.delete(key)
      end
    end

    private

    def pull_due_tasks()
      time_now = Time.now
      due_tasks = []
      @tasks.delete_if do |key, task|
        if task.exec_at <= time_now
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
