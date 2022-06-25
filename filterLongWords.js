function filterLongWords(sentence, n) {
  const s_array = sentence.split(' ')

  return s_array.reduce((result, i ) => {
    if (i.split('').length > n) {
      result.push(i)
    }
    return result
  }, [])
}
