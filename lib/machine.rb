module VFSM
	class Machine
		attr_reader :currentnodes

		def initialize(machineDefinition)
			@currentnodes = []
		end

		def handleinput(inputString)
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
