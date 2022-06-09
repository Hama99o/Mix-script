def vowel_indices(word)
  result = []
  vowels = ['a', 'e', 'i', 'o', 'u', 'y', 'A', 'E', 'I', 'O', 'U', 'Y' ]
  
  word.split('').each_with_index do |num, idx|
    if vowels.include?(num)
      result.push(idx+1) 
    end 
  end 
  
  result
end