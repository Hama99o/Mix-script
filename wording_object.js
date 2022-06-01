var errors = ['errors', { user_ids: ["some doesn't exist"] }]

function getString (error) {
  if (typeof error == 'object' && !Array.isArray(error)) {
    var stringError = ''
    Object.keys(error).forEach((key) => {
       stringError =  stringError + `${key} ${error[key]} `
     });
     return stringError.toString()
  } else if (typeof error == 'object' && Array.isArray(error)) {
    getString(error)
  } else {
    return error
  }
}

errors = errors.map((error) => {
  return getString(error)
})
console.log(errors)
