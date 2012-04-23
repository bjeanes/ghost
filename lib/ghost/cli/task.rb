module Ghost
  class Cli
    class Task
      attr_accessor :out

      class << self
        attr_accessor :name

        def desc(str = nil)
          if str
            @desc = str
          else
            @desc
          end
        end
      end

      def initialize(out)
        self.out = out
      end

      def perform(*); end
      def description; end
      def help; end

      private

      def puts(*args)
        out.puts(*args)
      end

      def print(*args)
        out.print(*args)
      end

      def abort(*args)
        out.puts(*args)
        exit 1
      end
    end

    def tasks
      @tasks ||= Hash[self.class.tasks.map { |name, task| [name, task.new(out)] }]
    end

    class << self
      def task(*names, &block)
        task = Class.new(Task, &block)
        names.map!(&:to_s)
        task.name = names.first
        names.each { |name| tasks[name] = task }
      end

      def tasks
        @tasks ||= {}
      end
    end
  end
end

Dir[File.dirname(__FILE__) + "/task/*.rb"].each { |f| require(f) }
