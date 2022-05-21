function NamedOne(first, last) {
// -- SHOULD be changed --
    var _firstName = first
    var _lastName = last
    var _fullName = _firstName + ' ' + _lastName

    Object.defineProperty(this,"firstName",{
      get: function() { return _firstName },
      set: function(value) {
        _firstName = value;
        _fullName = value + ' ' + _lastName
      }
    })

    Object.defineProperty(this,"lastName",{
      get: function() { return _lastName },
      set: function(value) {
        _lastName = value;
        console.log(value)

        _fullName = _firstName + ' ' + value
      }
    })

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
