def keyword_cipher(string, keyword)
  hash = abc(keyword)
  result = []

  string.split('').each do |str|
    if str != ' '
      result.push(hash[str.downcase])
    else
      result.push(str)
    end
  end
  result.join
end

def abc(keyword)
  hash = {}
  abc = ('a'..'z').to_a
  abc.each do |s|
    keyword.split('').each do |t|
      if !hash[s] && !hash.values.include?(t)
        hash[s] = t
      end
    end
    abc.each do |y|
      if !hash[s] && !hash.values.include?(y)
        hash[s] = y
      end
    end
  end
  hash
end