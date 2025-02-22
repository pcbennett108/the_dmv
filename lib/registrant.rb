class Registrant
  attr_reader :name, :age, :license_data
  def initialize(name, age, permit=false)
    @name = name
    @age = age
    @permit = permit
    @license_data={:written=>false, :license=>false, :renewed=>false}
  end

  def permit?
    @permit
  end

  def old_enough?
    @age >= 16
  end

  def earn_permit
    @permit = true
  end

end