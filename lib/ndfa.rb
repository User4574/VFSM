module VFSM
	class NDFA
		attr_reader :currentnodes

		def initialize(machineDefinition)
			inedges = false
			nodes = []
			@currentnodes = []

			lineno = 0
			File.foreach(machineDefinition) do |line|
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
							@currentnodes.push startnode
						else
							@currentnodes.push tempsnode[0]
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
			NDFA.recurse @currentnodes
			NDFA.printnodes @currentnodes
		end

		def handleinput(inputString)
			inputString.chomp.split.each do |input|
				nextnodes = []
				@currentnodes.each do |node|
					nextnode = node.goto input
					unless nextnode == :reject
						nextnode.each do |x|
							nextnodes.push x
						end
					end
				end

				NDFA.recurse nextnodes

				print " --#{input}--> "

				NDFA.printnodes nextnodes

				if nextnodes == [] then
					puts
					puts "Invalid input, REJECTED"
					exit
				else
					@currentnodes = nextnodes
				end
			end
		end

		class << self
			def printnodes nodes
				print "{ "
				(0..(nodes.length - 1)).each do |x|
					if nodes[x].accepting? then
						print "((#{nodes[x].id}))"
					else
						print "(#{nodes[x].id})"
					end
					print ", " unless x == (nodes.length - 1)
				end
				print " }"
			end

			def recurse nodeslist
				begin
					oldlist = nodeslist.dup
					oldlist.each do |node|
						tmp = node.goto :lambda
						unless tmp == :reject then
							tmp.each do |x|
								nodeslist.push x
							end
						end
					end
					nodeslist.uniq!
				end while oldlist != nodeslist
			end
		end
	end
end
