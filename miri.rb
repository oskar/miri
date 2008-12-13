require 'thread'

module Miri
  
  def self.find(name)
    Thread.list.each do |t|
      return t if t['name'] == name
    end
    return nil
  end

  def self.need(names)
    names = names.to_a unless names.is_a?(Array)
    names.each do |name|
      loop do
        break if find(name)
        Thread.pass
      end
    end
  end

  def self.send(sig, receiver)
    t = find(receiver)
    if t then
      t['mbox'] ||= Queue.new
      t['mbox'] << sig
      log("[#{Thread.current['name']}] Sent signal", sig)
    else
      log("[#{Thread.current['name']}] Could not send signal", sig)
    end
  end

  def self.receive
    # Create mbox if missing
    Thread.current['mbox'] ||= Queue.new

    # Pop first item in queue, blocking call
    sig = Thread.current['mbox'].pop

    log("[#{Thread.current['name']}] Received signal", sig)
    return sig
  end
  
  @@log_mutex = Mutex.new
  
  def self.log(msg, sig = nil)
    msg += " [#{sig.to_s}]" if sig
    @@log_mutex.synchronize do
      puts msg
    end
  end
  
  class Application
    def initialize(options = {}, &block)
      @t = Thread.new do
        Thread.current['name'] = options[:name]
        Miri::need(options[:need]) if options[:need]
        yield block
      end
    end
    
    def join
      @t.join
    end
  end

end
