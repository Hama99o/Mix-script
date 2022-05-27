function lastDigit(n, d) {
  if (d <= 0) return []

  const nArray = n.toString().split('').map(i => parseInt(i)).reverse()
  var result = []

  for(let i = 0; i < d; i++) {
    result.push(nArray[i])
  }

  if (d > nArray.length) return nArray.reverse()
  return result.reverse()
}
