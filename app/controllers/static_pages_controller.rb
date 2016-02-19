class StaticPagesController < ApplicationController
  include ApplicationHelper
  def home
  end

  def help
  end

  def table
  	palette = {}
  	palette["match"] = "ffffff"
  	palette["double"] = "779999"
  	palette["single"] = "99bbbb"
  	if params && params[:tabletext]
  		@tabletext = params[:tabletext].strip
  	else
  		@tabletext = ""
  	end
  	tablerows = @tabletext.split("\n")
  	table = tablerows.map {|r| r.split(" ").map {|x| x.to_i}}
  	if table and table[0] and table[0][0] 	

			@tablehtml = '<br><br>Your table as entered is:<br><br>' + tablify(table)
			rowsfirst = false
			if !params[:maximum]
				@tablehtml = '<br><br>Please indicate whether this is a minimisation or maximisation problem:<br><br>' + tablify(table)
			else
				if params[:maximum] == "yes"
					@maximise = true
				else
					@maximise = false
				end

				outcome = tidy(table, @maximise)
				if outcome[0]
					table1 = outcome[1]
					@tablehtml += '<br><br>Ensuring all values are positive, and adjusting if necessary for maximisation:<br><br>' + tablify(table1)

					rows = table1.count
					cols = table1.map {|x| x.count}.max

					if rows != cols
						if !params[:zeropad]
							@tablehtml += %Q(<br><br>This table is not square, so we need to add extra rows/columns. Some people like to keep
							it simple and use zeros for the padding, others are more sophisticated and use high values so that row/column
							redution can get more traction<br><br>Please indicate which of these you'd like to use: <br><br>
							zeros <input type="radio" name = "zeropad" value="yes">
							 high values <input type="radio" name = "zeropad" value="no"><input type="submit" class="bobutton" value="Submit" alt="Submit">)
						else
							if params[:zeropad] == "yes"
								table1 = pad(table1)[0]
								s1 = " checked "
								s2 = " "
							else
								table1 = pad(table1)[1]
								s2 = " checked "
								s1 = " "
							end
							@tablehtml += '<br><br>Non-square array padded using<br>zeros <input type="radio" name = "zeropad" value="yes"' + s1 + '> high values <input type="radio" name = "zeropad" value="no"' + s2 + ')><input type="submit" class="bobutton" value="Submit" alt="Update"><br><br>' + tablify(table1)
							
						end
					end

					if !params[:rowsfirst]
						@tablehtml += %Q(<br><br>For the next stage we eliminate by rows and by columns.<br>Please indicate which of these you'd like to do first: <br><br>
						rows <input type="radio" name = "rowsfirst" value="yes">
						 columns <input type="radio" name = "rowsfirst" value="no"><input type="submit" class="bobutton" value="Submit" alt="Submit">)
					else
						if params[:rowsfirst] == "yes"
							table1 = pad(table1)[0]
							s1 = " checked "
							s2 = " "
						else
							table1 = pad(table1)[1]
							s2 = " checked "
							s1 = " "
						end
						@tablehtml += '<br><br>Reduction by <br>rows first <input type="radio" name = "rowsfirst" value="yes"' + s1 + '> columns first <input type="radio" name = "rowsfirst" value="no"' + s2 + ')><input type="submit" class="bobutton" value="Submit" alt="Update"><br><br>'
						table2 = reduce(table1, params[:rowsfirst] == "yes")
						@tablehtml += tablify(table2[0]) + '<br><br>'
						@tablehtml += tablify(table2[1]) + '<br><br>'

						table3 = table2[1]
						i = 0
						done = false

						until done do
							i += 1
							g = bipgraph(table3)
							n = table3.count
							set = (0..n).to_a
							match = matching(g,set,set)
							matched = match.keys.count
							lcolours = {0 => {}}
							if matched == n
								mcolours = {}
								match.each_key do |k|
									mcolours[[k,match[k]]] = palette["match"]
								end
								@tablehtml += 'There is now a matching of zeros: </br></br>' + tablify(table3, mcolours) + '<br><br>'
								@tablehtml += 'Applying this to your original matrix we get a solution (which may not be unique): </br></br>' + tablify(table, mcolours) + '<br><br>'
								done = true
							else
								@tablehtml += 'There is not yet a matching of zeros, because the zeros in the table</br>
								can be covered by ' + matched.to_s + ' lines. You can select these lines using the check boxes</br>
								on the copy of the table below.</br></br>'
								table4 = eval(table3.to_s)
								n.times do |j|
									row = table4[j]
									checkname = "chr" + i.to_s + "," + j.to_s
									if params[checkname.to_sym] and params[checkname.to_sym] == "yes"
										ch = " checked "
									else
										ch = " "
									end
									row << '<input type="checkbox" name = "' + checkname + '" value="yes"' + ch +'>'
								end
								newrow = []
								n.times do |j|
									checkname = "chc" + i.to_s + "," + j.to_s
									if params[checkname.to_sym] and params[checkname.to_sym] == "yes"
										ch = " checked "
									else
										ch = " "
									end
									newrow << '<input type="checkbox" name = "' + checkname + '" value="yes"' + ch +'>'
								end
								table4 << newrow
								success = true
								n.times do |p|
									checkname = "chr" + i.to_s + "," + p.to_s
									if params[checkname.to_sym] and params[checkname.to_sym] == "yes"
									else
										n.times do |q|
											checkname = "chc" + i.to_s + "," + q.to_s
											if params[checkname.to_sym] and params[checkname.to_sym] == "yes"
											else
												success = false if table3[p][q] == 0
											end
										end
									end
								end
								lcolours[i] = {}
								lrows = params.select {|k,v| k.to_s.match("chr" + i.to_s + ",")}.keys.map {|x| x.split(",")[1].to_i}
								lcols = params.select {|k,v| k.to_s.match("chc" + i.to_s + ",")}.keys.map {|x| x.split(",")[1].to_i}
								lrows.each do |p|
									n.times do |q|
										lcolours[i][[p,q]] = palette["single"]
									end
								end
								lcols.each do |q|
									n.times do |p|
										unless lcolours[i][[p,q]]
											lcolours[i][[p,q]] = palette["single"]
										else
											lcolours[i][[p,q]] = palette["double"]
										end
									end
								end
								lines = lrows.count + lcols.count

								@tablehtml += tablify(table4, lcolours[i]) + '<br><input type="submit" class="bobutton" value="Submit" alt="Submit"><br><br>'
								
								if success
									
									if lines >= n
										@tablehtml += "There need to be fewer than #{n} lines. Please try again"
										done = true
									else
										doubly = lcolours[i].select {|k,v| v == palette["double"]}
										singly = lcolours[i].select {|k,v| v == palette["single"]}
										min = nil
										n.times do |p|
											n.times do |q|
												unless doubly[[p,q]] or singly[[p,q]]
													min = table3[p][q] if !min or min > table3[p][q]
												end
											end
										end

										@tablehtml += "<br>We now augment the matrix using the minimum uncovered value of #{min} <br><br>"

										n.times do |p|
											n.times do |q|
												if doubly[[p,q]]
													table3[p][q] += min
												elsif !singly[[p,q]]
													table3[p][q] -= min
												end
											end
										end
									end






								else

									@tablehtml += "That combination of lines doesn't cover all the zeros. Please try again"
									done = true
								end






							end
						end

					end

					


				# 	if !params[rf]
				# 		@tablehtml += '<br><br>Ensuring all values are positive, and adjusting if necessary for maximisation:<br><br>'

				# 		if rowsfirst
				# 			t1 = 'rows'
				# 			t2 = 'columns'
				# 		else
				# 			t1 = 'columns'
				# 			t2 = 'rows'
				# 		end



				# 	+ '<br><br>Reducing by ' + t1 + ':<br><br>' + tablify(outcome[2]) + '<br><br>Reducing by ' + t2 + ':<br><br>' + tablify(outcome[3])
				else
					@tablehtml += '<br><br>Not all the rows are the same length. Please fix this and try again<br><br>'

				end

			end


		else
			@tablehtml = "<br><br>Paste an array of values into the box above."
		end
	

  end
end
