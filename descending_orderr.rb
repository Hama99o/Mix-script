def descending_order(n)
  result = []
  inteArray = n.to_s.split('').map{ |n| n.to_i }
  
  inteArray.each do
    maxValue = inteArray.max
    
    if inteArray.count(maxValue) >= 2
      inteArray.count(maxValue).times do
        result.push(maxValue)
      end
    else 
      result.push(maxValue)
    end 
      inteArray -= [maxValue]
  end
  
  result.join('').to_i
end