def varnames(n_vars,n_const) 
    if n_vars < 4 and n_const < 6
        return ["P"] + ["x","y","z"][0..n_vars-1] + ["r","s","t","u","v"][0..n_const - 1]
    elsif  n_vars == 4 and n_const < 6
        return ["P"] + ["w","x","y","z"] + ["r","s","t","u","v"][0..n_const - 1]
    else
        return ["P"] + ["p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"][-n_vars..-1] + ["a","b","c","d","e","f","g","h","i","j","k","l","m"][0..n_const - 1]
    end
end
    



con_coeff = [[2,3,-1,20],[1,3,4,30],[2,-2,3,20],[2,-2,3,20],[2,-2,3,20]]
obj_coeff = [4,1,3,5,1]
tableau = con_coeff.map {|x| x.map {|y| y.to_i}} + obj_coeff.map{|x| -(x.to_i)}
n_vars = obj_coeff.count
n_const = con_coeff.count
puts varnames(n_vars,n_const)

html = tablify(tableau)

## choose pivot col

col = nil
min = 0

n_vars.times do |i| 
    c = tableau[-1][i] 
    if c < min
        min = c
        col = i
    end
end

unless c
    html += "</br></br>This table is optimised because there are no negative coefficients on the Profit line"
else
    html += "</br></br>This table is not optimised because there are negative coefficients on the Profit line"
    html += "</br></br>We need to choose one of the negative coefficients as the column for our pivot"
    html += "</br></br>Please use the checkboxes to select the column you'd like to use."


