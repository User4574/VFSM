require './lib/vfsm'

if ARGV[0] == nil or ARGV[1] == nil then
	puts "Usage: ruby vfsm.rb <machine description file> <input>"
	exit
end

machine = VFSM::NDFA.new(ARGV[0])

machine.handleinput(ARGV[1])

puts
acc = false
machine.currentnodes.each do |node|
	acc = true if node.accepting?
end
if acc then
	puts "Valid input, ACCEPTED"
else
	puts "Invalid input, REJECTED"
end
