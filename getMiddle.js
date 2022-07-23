function getMiddle(s) {
  const array = s.split('')
  const result = []
  if (array.length % 2 == 0) {
    result.push(array[(array.length/2 - 1)])
    result.push(array[array.length/2 ])
  } else {
    result.push(array[(Math.floor(array.length/2))])
  } 
  
  return result.join('')
}
