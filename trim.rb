def trim(string, size)
  return string.length > size ? string.slice(0, string.length >= 6 && size > 3 ? (size - 3) : size ) + '...' : string
end