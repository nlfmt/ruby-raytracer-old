class Sphere

  attr_accessor :p, :r, :mat

  def initialize(pos: Vec3.new, rad: 1, mat: Material.new())
    @p = pos
    @r = rad
    @mat = mat
  end

  def getNormal(pos)

    n = (pos - @p).normalize
    pos = (@p - pos).normalize

    if @mat.normal != nil
      return @mat.normal_at(uvs(pos), n)
    else
      return n
    end

  end

  def color_at(pos)

    pos = (@p - pos).normalize

    return @mat.color_at(uvs(pos))
  end
  #
  # def specular_at(pos)
  #
  #   pos = (@p - pos).normalize
  #   return @mat.specular_at(uvs(pos))
  # end

  def intersect(ray)
    o = ray.o - @p

    b = 2 * dot(o, ray.d)
    c = dot(o,o) - (@r * @r)
    discr = b * b - 4 * c

    if discr >= 0
      dist = (-b - Math.sqrt(discr)) / 2
      return dist if dist > 0
    end
    return nil
  end

end
