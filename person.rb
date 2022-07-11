class Person
  def initialize(firstName, lastName, age)
    @firstName = firstName
    @lastName = lastName
    @age = age

  end

  def full_name
    "#{@firstName} #{@lastName}"
  end

  def age
    @age
  end
end

Object.defineProperty(this,"lastName",{
  get: function() { return _lastName },
  set: function(value) {
    _lastName = value;
    console.log(value)

    _fullName = _firstName + ' ' + value
  }
})