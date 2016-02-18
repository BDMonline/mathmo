module ApplicationHelper

	def tablify(table, colours = nil)
		tablehtml = '<table class="gridtable">'
		rows = table.count
		rows.times do |i|
			row = table[i]
			tablehtml += "<tr>"
			cols = row.count
			cols.times do |j|
				item = row[j].to_s
				if colours and colours[[i,j]]
					col = ' style = "background-color:#' + colours[[i,j]] + '"'
				else
					col = ""
				end
				tablehtml += '<td' + col + '>'+ item + '</td>'
			end
			tablehtml += "</tr>"
		end
		return tablehtml + '</table>'
	end

	def reducer(arr)
	    newarr = []
	    arr.each do |row|
	        min = row.min
	        newarr << row.map {|x| x - min}
	    end
	    return newarr
	end

	def reducec(arr)
	    n = arr.count
	    newarr = Array.new(n) {Array.new}
	    (0..n-1).each do |i|
	        col = arr.map {|row| row[i]}
	        puts col
	        min = col.min
	        col = col.map {|x| x - min}
	        puts "#{col}"
	        (0..n-1).each do |j|
	            newarr[j] << col[j]
	        end
	    end
	    return newarr
	end

	def tidy(table, maximise)

		cols = nil
		rows = table.count
		arr = []
		done = false
		fail = false
		max = nil
		min = nil
		i = 0
		until done or fail or i >= rows do
		    row = table[i]
		    if row
		        if cols and row.count != 0
		            fail = true if row.count != cols
		        else
		            cols = row.count
		        end
		        mx = row.max
		        max = mx if !max or (mx and max < mx) 
		        mn = row.min
		        min = mn if !min or (mn and min > mn)
		        if row.count == 0
		            done = true
		        else
		            arr << row
		            puts arr.to_s
		        end
		    else
		        done = true
		    end
		    i += 1
		end

		if fail
		    return [false, "Row lengths are unequal"]
		else
		    tidied_arr = arr
		    if min < 0
		        tidied_arr = tidied_arr.map {|row| row.map {|x| x - min}}
		        max = max - min
		    end
		    if maximise
		        tidied_arr = tidied_arr.map {|row| row.map {|x| max - x}}
		    end
		end

		return [true, tidied_arr]
	end

	
	def reduce(table, rowsfirst)
	    if rowsfirst
	        red1 = reducer(table)
	    else
	        red1 = reducec(table)
	    end

	    if rowsfirst
	        red2 = reducec(red1)
	    else
	        red2 = reducer(red1)
	    end
		return [red1, red2]
	end


	def pad(array)
		padv = array.flatten.max
		ans1 = eval(array.to_s)
		ans2 = eval(array.to_s)
		rows = array.count
		cols = array.map {|x| x.count}.max
		n = [rows,cols].max
		rows.times do |i|
			l = array[i].count
			(n - l).times do
				ans1[i] << 0
				ans2[i] << padv
			end
		end
		(n - rows).times do
			ans1 << Array.new(n, 0)
			ans2 << Array.new(n, padv)
		end
		return [ans1,ans2]
	end

	def matching(g, leftset, rightset)

		m_left = []

		m_right = []

		nl = leftset.size
		nr = rightset.size
		unmatched_l = leftset.clone
		unmatched_r = rightset.clone


		## greedily choose an initial matching
		i=0
		g1 = g.clone
		match = {}
		while i < nl
			j=0
			while j < nr
				if g1[[i,j]]
					match[i] = j
					g1.delete_if {|key,value| key[0]==i || key[1]==j}
					unmatched_l.delete(i)
					unmatched_r.delete(j)
					j = nr
				else
					j += 1
				end
			end
			i += 1
		end
		#
		puts "initial matching #{match.to_s} unmatched_l=#{unmatched_l} unmatched_r=#{unmatched_r}"

		g1 = g.clone

		while unmatched_l.count > 0 && unmatched_r.count > 0
			path = false
			lset=[[unmatched_l[0]]]
			rset=[]
			visited_r = []
			endpoint = nil
			i = 0
			while !path && unmatched_l.count > 0
				# find an alternating path from 1st elt of unmatched_l if poss

				puts "trying a path from #{unmatched_l[0]}"
				rset << ((g.select {|key, value| lset[i].include?(key[0]) && !visited_r.include?(key[1])}).keys).map {|n| n[1]}
				puts "rset = #{rset.to_s}"
				if rset[-1].size == 0
					path = "no"
				elsif (rset[-1] & unmatched_r).size > 0
					path = "yes"
					endpoint = (rset[-1] & unmatched_r)[0]
					puts "hooray - can end at #{endpoint}"
				else
					i += 1
					puts "finding the x's matched to #{rset[-1].to_s} #{rset[-1].map {|n| n[1]}}"
					lset << [(match.select {|key, value| rset[-1].include?(value)})].map {|item| item.keys}.flatten
					visited_r += rset[-1]
					puts "visited #{visited_r} lset = #{lset.to_s}"
				end
				if path == "no"
					# if there isn't a path, delete this l - element and try again	
					unmatched_l.delete_at(0)
					path = false
					lset=[[unmatched_l[0]]]
					rset=[]
					visited_r = []
					endpoint = nil
					i = 0
				end
			end

			y = endpoint

			if y
				route = []
				i.downto(0) do |j|
					x = (lset[j].select {|x| g[[x,y]]})[0]
					route << [x,y]
					y = match[x]
				end
				route.each_index do |index|
					match[route[index][0]] = route[index][1]
				end

				unmatched_l.delete_at(0)
				unmatched_r.delete(y)
			end
		end
		return match
	end

	def bipgraph(table)
		n = table.count
		g = {}
		n.times do |i|
			n.times do |j|
				g[[i,j]] = true if table[i][j] == 0
			end
		end
		return g
	end


end