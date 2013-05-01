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
		@edges.push [on, to]
	end

	def goto on
		to = @edges.select do |edge|
			edge[0] == on
		end

		if to.length == 0 then
			return :reject
		else
			ret = []
			to.each do |x|
				ret.push x[1]
			end
			return ret
		end
	end
end

if ARGV[0] == nil or ARGV[1] == nil then
	puts "Usage: ruby vfsm.rb <machine description file> <input>"
	exit
end

inedges = false
nodes = []
currentnodes = []

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
				startnode = Node.new linearray[1]
				nodes.push startnode
				currentnodes.push startnode
			else
				currentnodes.push tempsnode[0]
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
			if linearray[1].downcase == "epsilon:" or linearray[1].downcase == "lambda:" then
				fnode.pushedge :lambda, tnode
			else
				fnode.pushedge linearray[1], tnode
			end
		end
	end
end

def printnodes nodes
	print "{"
	nodes.each do |node|
		if node.accepting? then
			print "((#{node.id})),"
		else
			print "(#{node.id}),"
		end
	end
	print "}"
end

ARGV[1].chomp.split.each do |input|
	printnodes currentnodes

	nextnodes = []
	currentnodes.each do |node|
		nextnode = node.goto input
		unless nextnode == :reject
			nextnode.each do |x|
				nextnodes.push x
			end
		end
	end

	oldnext = nextnodes.dup
	begin
		epsnodes = []
		nextnodes.each do |node|
			tmp = node.goto :lambda
			tmp.each do |x|
				epsnodes.push tmp
			end
		end
		epsnodes.each do |node|
			nextnodes.push node
		end
	end while oldnext != nextnodes
	
	if nextnodes == [] then
		puts
		puts "Invalid input, REJECTED"
		exit
	else
		currentnodes = nextnodes
	end
end

printnodes currentnodes

acc = false
currentnodes.each do |node|
	acc = true if node.accepting?
end
if acc then
	puts "Valid input, ACCEPTED"
else
	puts "Invalid input, REJECTED"
end
