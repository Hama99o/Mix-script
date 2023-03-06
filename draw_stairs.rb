def draw_stairs(n)
  result = []
  n.times do |x|
    counter = x + 1
    space = ''
    counter.times do |y|
      if y >= 0
        space += ' '
      end
    end

    n == (x + 1) ? result.push("I")  :  result.push("I\n#{space}")
  end

  result.join('')
end