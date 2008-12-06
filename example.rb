require 'miri'

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
