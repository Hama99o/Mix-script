function findUniq(arr) {
  const uniqArr = arr.filter((v, i, a) => a.indexOf(v) === i)
  const result = uniqArr.find((i) => {
    if (arr.filter(j => j === i ).length === 1) {
      return i
    }
  })
  return result === undefined ? 0 : result
}
