function swap(s){
  return s.split('').map((i) => {
    if (i === i.toUpperCase()) {
      return i.toLowerCase()
    } else
      return i.toUpperCase()
  }).join('')

}
