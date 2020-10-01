class Plane

  def initialize(p,n)
    @p = p
    @n = n
  end

  def getNormal(posI)
    @n
  end

  def intersect(ray)
    return false if(dot(ray.d,@n) == 0)
    return true
  end

  def getT(ray)
    (1/dot(ray.d,@n) * (dot(@p,@n) - dot(ray.o,@n)))
  end

end
