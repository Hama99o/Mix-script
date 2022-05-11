def battle(x, y)
  x_count = count(x)
  y_count = count(y)

  if x_count === y_count
    "Tie!"
  elsif x_count > y_count
    x
  else
    y
  end
end

def count(item)
  item_count = 0
  item.split('').each do |i|
    item_count = item_count + abc_hash[i]
  end

  item_count
end

def abc_hash
  abc = ('A'..'Z').to_a
  length = 0

  abc.map do |a|
    length = length + 1
    [a, length]
  end.to_h
end
