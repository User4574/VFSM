class Node
	def initialize id, accepting = false
		@id = id
		@accepting = accepting
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
			#do nothing
			#ignore line for backwards compatability
		elsif linearray[0].downcase == "start:" then
			tempsnode = nodes.select do |node|
				node.id == linearray[1]
			end
			if tempsnode.length == 0 then
				currentnode = Node.new linearray[1]
				nodes.push currentnode
			else
				currentnode = tempsnode[0]
			end
		elsif linearray[0].downcase == "accept:" then
			linearray[1..-1].each do |node|
				anodes = nodes.select do |inode|
					node == inode.id
				end
				if anodes.length == 0 then
					mynode = Node.new node, true
					nodes.push mynode
				else
					anodes[0].accepting!
				end
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
			fnode = nil
			tnode = nil
			fnodes = nodes.select do |node|
				node.id == linearray[0]
			end
			if fnodes.length == 0 then
				fnode = Node.new linearray[0]
				nodes.push fnode
			else
				fnode = fnodes[0]
			end
			tnodes = nodes.select do |node|
				node.id == linearray[2]
			end
			if tnodes.length == 0 then
				tnode = Node.new linearray[2]
				nodes.push tnode
			else
				tnode = tnodes[0]
			end
			fnode.pushedge linearray[1], tnode
		end
	end
end

ARGV[1].chomp.split.each do |input|
	if currentnode.accepting? then
		print "((#{currentnode.id})) --#{input}--> "
	else
		print "(#{currentnode.id}) --#{input}--> "
	end
	nextnode = currentnode.goto input
	if nextnode == :reject then
		puts
		puts "Invalid input, REJECTED"
		exit
	else
		currentnode = nextnode
	end
end

if currentnode.accepting? then
	puts "((#{currentnode.id}))"
else
	puts "(#{currentnode.id})"
end

if currentnode.accepting? then
	puts "Valid input, ACCEPTED"
else
	puts "Invalid input, REJECTED"
end
