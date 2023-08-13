require 'bigdecimal'
require 'bigdecimal/util'

class Calc
  def self.add(a, b)
    (a.to_d + b.to_d).to_f
  end
  def self.sub(a, b)
    (a.to_d - b.to_d).to_f
  end
  def self.mult(a, b)
    return 0.0 if a == 0 || b == 0
    (a.to_d * b.to_d).to_f
  end
  def self.div(a, b)
    return 0.0 if b == 0
    (a.to_d / b.to_d).to_f
  end
end