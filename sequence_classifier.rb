def sequence_classifier(arr)
  constant(arr) || not_increasing(arr) || increasing(arr) || not_decreasing(arr) || decreasing(arr) || unordered(arr)
end

def unordered(arr)
  arr != arr.sort ? 0 : false
end

def increasing(arr)
    arr.uniq.length == arr.length && arr == arr.sort ? 1 : false
end

def decreasing(arr)
    arr.uniq.length == arr.length && arr.sort == arr.reverse ? 3 : false
end

def not_increasing(arr)
  arr.uniq.length != arr.length && arr.sort == arr.reverse ? 4 : false
end

def constant(arr)
  arr.uniq.length == 1  ? 5 : false
end
