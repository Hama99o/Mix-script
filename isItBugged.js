function isItBugged(code){
  const date = code.split(' ')[0].split('-')
  const year = date[2] && date[2].split('').length === 4 ? date[2] : "hi"
  const day = date[1] && date[1].split('').length == 2 &&  parseInt(date[1]) <= 12 &&  parseInt(date[1]) > 0 ? date[1] : parseInt(date[1]) == 0 ? '01' : '0000'
  const month = date[0] && date[0].split('').length == 2 && parseInt(date[0]) <= 30 ?  '10' : '0000'
  const hour = code.split(' ')[1].split(':')[0].split('').length == 2 ? '12' : 'error'
  const minute = code.split(' ')[1].split(':')[1] && code.split(' ')[1].split(':')[1].split('').length == 2 ? '01': 'error'
  const realDate = `${ day }-${month}-${year} ${hour}:${minute}`
  return !isNaN(new Date(realDate))
}
