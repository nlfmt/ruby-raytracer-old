def clamp255(clr)
  x = clr.x
  y = clr.y
  z = clr.z

  if(clr.x < 0)
    x = 0
  elsif(clr.x > 255)
    x = 255
  end

  if(clr.y < 0)
    y = 0
  elsif(clr.y > 255)
    y = 255
  end

  if(clr.z < 0)
    z = 0
  elsif(clr.z > 255)
    z = 255
  end
  Vec3.new(x,y,z)

end


def clamp01(num)

  if(num < 0)
    num = 0
  elsif(num > 1)
    num = 1
  end
  return num
end

def mix(c1, c2, f)
  if c1.class == Integer || c1.class == Float
    return (c1 * f + c2 * (1 - f))
  end
  (c1.mult(f) + c2.mult(1 - f))
end

def add(c1, c2)
  clamp255(c1 + c2)
end

def multiply(c1, c2)
  (c1.mult(1.0 / 255) * c2.mult(1.0 / 255)).mult(255)
end

def uvs(pos)
  u = 0.5 - (Math.atan2(pos.x, pos.z) / (2 * Math::PI))
  v = 0.5 + (Math.asin(pos.y) / Math::PI)
  return [u, v]
end
