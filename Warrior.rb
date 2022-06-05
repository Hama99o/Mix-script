class Warrior
  attr_accessor :name
  attr_accessor :health

  def initialize(name)
    @name=name
    @health=100
  end

  def strike(enemy,swings)
    enemy.health = enemy.health - (swings * 10) < 0 ? 0 : enemy.health - (swings * 10)
  end
end
