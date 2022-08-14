class Dinglemouse {

    constructor () {
        this.name = this.age = this.sex = 0
        this.hi = []
        this.allValues = {
          name: true,
          age: true,
          sex: true
        }
    }

    setAge (age) {
        this.hi.push(age)
        this.age = age
        return this
    }

    setSex (sex) {
        this.hi.push(sex)
        this.sex = sex
        return this
    }

    setName (name) {
        this.hi.push(name)
        this.name = name
        return this
    }

    hello () {
      console.log(this.hi)
        const phraseArray = this.hi.map ((j) => {
          if (j === this.age || Number.isInteger(j)) {
            if (this.allValues.age) {
              this.allValues.age = false
              return ` I am ${this.age}.`
            }

          } else if (j === this.sex || j === 'M' || j === 'F') {
            if (this.allValues.sex) {
              this.allValues.sex = false
              return  ` I am ${this.sex == 'M' ? "male" : "female"}.`
              }
          } else if (j === this.name || (typeof j === 'string' && j != 'M' || j != 'F')) {
            if (this.allValues.name) {
              this.allValues.name = false
              return ` My name is ${this.name}.`
            }
          }
       }).join('')
        this.hi = []
        return `Hello.${phraseArray}`
    }

}
