require 'miri'

a = Thread.new do
  Thread.current['name'] = "a"
  
  Miri::need("b")
  loop do
    sig = "From A to B"
    Miri::send(sig, "b")
    
    sig = Miri::receive()
    sleep(2)
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

# c = Miri::Application.new :name => "c" do
#   loop do
#     log("Hi, im C!")
#     sleep(3)
#   end
# end
# 
# puts Thread.list.to_s

a.join
