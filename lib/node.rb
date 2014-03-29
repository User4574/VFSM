module VFSM
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
end
