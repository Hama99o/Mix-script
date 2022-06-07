def multiply(n)
  i = n < 9 && n > -9 ? 1 : n.to_s.split('').select{ |j| j != '-'}.length
  n * 5 ** i
end
