require "slipstream"
require "lone_wolf/version"

module LoneWolf
  class Worker
    def initialize(**options)
      loop! if options[:loop]
      @job = options[:job] if options[:job]
      @input_stream = Slipstream.create
      @output_stream = Slipstream.create
      if options[:start]
        started = start! 
        warn "Unable to start worker!" unless started
      end
    end

    def job?
      return true if @job
      false
    end

    def job=(prc)
      warn "Specifying the job now won't work unless you restart the worker!" if @pid
      @job = prc
    end

    def job(&block)
      return @job unless block_given?
      warn "Specifying the job now won't work unless you restart the worker!" if @pid
      @job = block
    end

    def loop!
      warn "Specifying the loop now won't work unless you restart the worker!" if @pid
      @loop = true
    end

    def loop?
      return true if @loop
      false
    end

    def start!
      return false if @pid
      return false unless @job
      @pid = fork do
        trap "SIGINT" do
          exit 0
        end
        if loop?
          while true do
            iput = input.read
            next if iput.nil?
            iput = iput.strip
            next if iput.empty?
            result = @job.call(iput)
            output.write result
          end
        else
          output.write @job.call(input.read)
        end
      end
      return true 
    end

    def restart!
      kill!
      start!
    end

    def input
      @input_stream
    end

    def output
      @output_stream
    end

    def kill!
      return false if @pid.nil?
      @pid = nil if Process.kill('KILL', @pid) == 1
      return true if @pid.nil?
      false
    end

    def killed?
      return true if @pid.nil?
      false
    end

    def pid
      @pid
    end

    def pid?
      return true if @pid
      false
    end
  end
end
