function NamedOne(first, last) {
// -- SHOULD be changed --
    var _firstName = first
    var _lastName = last
    var _fullName = _firstName + ' ' + _lastName


    Object.defineProperty(this,"fullName",{
      get: function() { return _fullName },
      set: function(value) {
        const splitValue = value.split(' ')
        if (splitValue.length > 1) {
        _fullName = value;
        _firstName = splitValue[0]
        _lastName = splitValue[1]
        }
      }
    })
}
