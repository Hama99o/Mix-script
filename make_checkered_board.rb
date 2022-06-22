def make_checkered_board(n)
  result = []
  x = getArray(n, x, 'X')
  o = getArray(n, o, 'O')
  count = 1

  n.times do
    if count % 2 == 0
      result.push(o)
      count += 1
    elsif
      result.push(x)
      count += 1
    end
  end
  p n
  p result
  result
end


def getArray (n, x, str)
  count = str == 'X' ? 1 : 0
  x = []
  
  n.times do
    if count % 2 == 0
      x.push('O')
      count += 1
    elsif
      x.push('X')
      count += 1
    end
  end
  x
end
