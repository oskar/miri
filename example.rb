require 'miri'

a = Miri::Application.new :name => "a", :need => "b" do
  loop do
    Miri::send("From A to B", "b")
    sig = Miri::receive()
    sleep(2)
  end
end

b = Miri::Application.new :name => "b" do
  loop do
    sig = Miri::receive()
    Miri::send("From B to A", "a")
  end
end

c = Miri::Application.new :name => "c", :need => ["a", "b"] do
  loop do
    Miri::log("Im C!")
    sleep(1)
  end
end

a.join
