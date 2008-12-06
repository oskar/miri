require 'thread'

def find(name)
  Thread.list.each do |t|
    return t if t['name'] == name
  end
  return nil
end

def need(name)
  loop do
    return if find(name)
    Thread.pass
  end
end

def send(sig, receiver)
  t = find(receiver)
  if t then
    t['mbox'] ||= Queue.new
    t['mbox'] << sig
    Log.log("[#{Thread.current['name']}] Sent signal", sig) if Log.enabled?
  else
    Log.log("[#{Thread.current['name']}] Could not send signal", sig) if Log.enabled?
  end
end

def receive
  # Create mbox if missing
  Thread.current['mbox'] ||= Queue.new
  
  # Pop first item in queue, blocking call
  sig = Thread.current['mbox'].pop

  Log.log("[#{Thread.current['name']}] Received signal", sig) if Log.enabled?
  return sig
end

class Log
  @@mutex = Mutex.new
  @@active = false
  
  def self.enable
    @@active = true
  end
  
  def self.disable
    @@active = false
  end
  
  def self.enabled?
    @@active
  end
  
  def self.log(msg, sig = nil)
    msg += " [#{sig.to_s}]" if sig
    @@mutex.synchronize do
      puts msg
    end
  end
end

a = Thread.new do
  Thread.current['name'] = "a"
  Log.enable
  
  need("b")
  loop do
    sig = "From A to B"
    send(sig, "b")
    
    sig = receive()
    sleep(1)
  end
end

b = Thread.new do
  Thread.current['name'] = "b"
  loop do
    sig = receive()

    sig = "From B to A"
    send(sig, "a")
  end
end

a.join
