String.prototype.toJadenCase = function () {
  return this.split(' ').map((str) => {
    strAr = str.split('')
    toUpperCaseLetter = strAr[0].toUpperCase()
    strAr.shift()
    strAr.unshift(toUpperCaseLetter)
    return strAr.join('')
  }).join(' ')
};
