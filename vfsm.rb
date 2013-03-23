class Node
	def initialize id
		@id = id
		@accepting = false
		@edges = []
	end

	def id
		return @id
	end

	def accepting! accepting=true
		@accepting = accepting
	end

	def accepting?
		return @accepting
	end

	def pushedge on, to
		tempto = @edges.select do |edge|
			edge[0] == on
		end
		if tempto.length > 0 then
			puts "Non-determinism error at node #{@id}"
			puts "Multiple definitions for on #{on}"
			exit
		else
			@edges.push [on, to]
		end
	end

	def goto on
		to = @edges.select do |edge|
			edge[0] == on
		end

		if to.length == 0 then
			return :reject
		else
			return to[0][1]
		end
	end
end

if ARGV[0] == nil or ARGV[1] == nil then
	puts "Usage: ruby vfsm.rb <machine description file> <input>"
	exit
end

inedges = false
nodes = []
currentnode = nil

lineno = 0
File.foreach(ARGV[0]) do |line|
	lineno += 1
	linearray = line.chomp.split
	unless inedges then
		if linearray == [] then
			#do nothing
		elsif linearray[0].downcase == "comment:" then
			#do nothing
		elsif linearray[0].downcase == "nodes:" then
			linearray[1..-1].each do |node|
				extnode = nodes.select do |inode|
					inode.id == node
				end
				if extnode.length > 0 then
					puts "Duplicate node id in declaration at line #{lineno}"
					puts line
					exit
				else
					nodes.push(Node.new node)
				end
			end
		elsif linearray[0].downcase == "start:" then
			tempsnode = nodes.select do |node|
				node.id == linearray[1]
			end
			currentnode = tempsnode[0]
		elsif linearray[0].downcase == "accept:" then
			anodes = nodes.select do |inode|
				linearray[1..-1].include? inode.id
			end
			anodes.each do |inode|
				inode.accepting!
			end
		elsif linearray[0].downcase == "edges:" then
			inedges = true
		else
			puts "Syntax error at line #{lineno}"
			puts line
			exit
		end
	else
		if linearray[0].downcase == "end:" then
			inedges = false
		else
			fnodes = nodes.select do |node|
				node.id == linearray[0]
			end
			tnodes = nodes.select do |node|
				node.id == linearray[2]
			end
			fnodes[0].pushedge linearray[1], tnodes[0]
		end
	end
end

ARGV[1].chomp.split.each do |input|
	print "(#{currentnode.id}) --#{input}--> "
	nextnode = currentnode.goto input
	if nextnode == :reject then
		puts
		puts "Invalid input, REJECTED"
		exit
	else
		currentnode = nextnode
	end
end

puts "(#{currentnode.id})"

if currentnode.accepting? then
	puts "Valid input, ACCEPTED"
else
	puts "Invalid input, REJECTED"
end
