require 'thread'

module Miri
  
  def self.find(name)
    Thread.list.each do |t|
      return t if t['name'] == name
    end
    return nil
  end

  def self.need(name)
    loop do
      return if find(name)
      Thread.pass
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

end

a = Thread.new do
  Thread.current['name'] = "a"
  
  Miri::need("b")
  loop do
    sig = "From A to B"
    Miri::send(sig, "b")
    
    sig = Miri::receive()
    sleep(1)
  end
end

b = Thread.new do
  Thread.current['name'] = "b"
  loop do
    sig = Miri::receive()

    sig = "From B to A"
    Miri::send(sig, "a")
  end
end

a.join
