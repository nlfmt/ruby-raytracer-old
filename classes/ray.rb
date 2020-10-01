class Ray

  attr_accessor :o, :d

  def initialize(o,d)
    @o = o
    @d = d.normalize
  end

  def calcP(t)
    @o + @d.mult(t)
  end

end
