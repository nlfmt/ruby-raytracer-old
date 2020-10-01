require_relative "vec3"
require_relative "ray"
require_relative "sphere"
require_relative "colors"
require_relative "scene"
require_relative "material"
require_relative "camera"
require_relative "texture"

class RenderEngine

  attr_accessor :MAX_DEPTH, :MIN_DISPLACE

  def initialize(env: Vec3.new(20,20,20), reflection_depth: 3, min_displace: 0.0001)
    @MAX_DEPTH = reflection_depth
    @MIN_DISPLACE = min_displace
    if env.class == String
      @ENV = Texture.new(env)
    else
      @ENV = env
    end
    @lastprogress = "000"
  end

  def render(scene)
    cam = scene.cam
    width = cam.width
    height = cam.height
    aspect_ratio = width / height.to_f
    x0 = -1.0
    x1 = 1.0
    xstep = (x1 - x0) / (width - 1)
    y0 = -1.0 / aspect_ratio
    y1 = 1.0 / aspect_ratio
    ystep = (y1 - y0) / (height - 1)

    img = File.open("#{scene.filename}.ppm", "w")
    img.write("P3\n" + "#{width} #{height} 255\n")

    info = "Rendering: #{scene.filename}\nObjects: #{scene.objects.length}\nLights: #{scene.lights.length}\n"

    for j in 1..height do
      y = y0 + j * ystep

      progress = "#{(j / height.to_f * 100.0).round(0)}".strip
      if progress.size == 1 then progress = "00" + progress end
      if progress.size == 2 then progress = "0" + progress end

      if @lastprogress != progress
        system("echo #{progress}")
      end
      @lastprogress = progress


      for i in 1..width do
        x = x0 + i * xstep

        ray = Ray.new(cam.pos, Vec3.new(x, -y, 2) - cam.pos)
        px_col = self.raytrace(ray, scene)
        img.write("#{px_col.x.floor} #{px_col.y.floor} #{px_col.z.floor}\n")
      end
    end
    img.close

  end

  def raytrace(ray, scene, depth = 0)
    color = Vec3.new
    # Find nearest object
    fn = self.find_nearest(ray, scene)
    dist_hit, obj_hit = fn[0], fn[1]
    if obj_hit == nil
      return sample_env(ray)
    end

    hit_pos = ray.calcP(dist_hit)
    hit_normal = obj_hit.getNormal(hit_pos)

    color = add(color, self.color_at(obj_hit, hit_pos, hit_normal, scene))

    to_orig = ray.o - hit_pos
    obj_hit.mat.reflectivity
    fresnel = mix(1, (1 - max(dot(to_orig.normalize, hit_normal.normalize), 0)) ** 4, obj_hit.mat.reflectivity)

    if depth < @MAX_DEPTH && obj_hit.mat.reflectivity != 0
      new_rpos = hit_pos + hit_normal.mult(@MIN_DISPLACE)
      new_rdir = reflect(hit_normal, ray.d)
      new_ray = Ray.new(new_rpos, new_rdir)


      color = add((multiply(self.raytrace(new_ray, scene, depth + 1), obj_hit.mat.specular_at(uvs((obj_hit.p - hit_pos).normalize)))).mult(fresnel), color)
    end


    return color
  end

  def find_nearest(ray, scene)
    dist_min = nil
    obj_hit = nil
    scene.objects.each do |obj|
      dist = obj.intersect(ray)
      if dist != nil && (obj_hit == nil || dist < dist_min)
        dist_min = dist
        obj_hit = obj
      end
    end
    return [dist_min, obj_hit]
  end

  def color_at(obj_hit, hit_pos, normal, scene)
    mat = obj_hit.mat
    obj_color = obj_hit.color_at(hit_pos)
    to_cam = scene.cam.pos - hit_pos
    specular_k = 350
    color = Vec3.new
    specular = Vec3.new
    emission = Vec3.new

    scene.lights.each do |light|
      to_light = Ray.new(hit_pos, light.p - hit_pos)

      # Diffuse
      emission = add(emission, light.mat.emission.mult(max(dot(normal, to_light.d), 0)))
      #color = add(color,(obj_color.mult(max(dot(normal, to_light.d), 0))))

      # Specular (Blinn-Phong)
      half_vector = (to_light.d + to_cam).normalize
      specular = add(specular,(multiply(light.mat.emission, mat.specular_at(uvs((obj_hit.p - hit_pos).normalize)))).mult(max(dot(normal, half_vector), 0) ** specular_k))
    end
    color = add(multiply(emission, obj_color), specular)
    return color

  end

  def sample_env(ray)
    if @ENV.class == Texture
      pos = ray.d.mult(-1)
      return @ENV.color_at(uvs(pos))
    else
      return @ENV
    end
  end

end
=begin

WHITE = Vec3.new(255,255,255)
GREY = WHITE.mult(0.5)
BLACK = Vec3.new(0,0,0)
RED = Vec3.new(255,0,0)
GREEN = Vec3.new(0,255,0)
BLUE = Vec3.new(0,0,255)


###############################
# Materials
###############################
red = Material.new(
  diffuse: RED,
  specular: WHITE.mult(0.4),
  roughness: 0.4,
  reflectivity: 0.5
)
blue = Material.new(
  diffuse: BLUE,
  specular: WHITE.mult(0.4),
  roughness: 0.4,
  reflectivity: 0.2,
)
purple = Material.new(
  diffuse: Vec3.new(190,0,255).mult(0.7),
  specular: WHITE,
  roughness: 0.8,
  reflectivity: 0.5,
)
metal = Material.new(
  diffuse: "../tex/am_diffuse.png",
  specular: WHITE,
  roughness: 0.8,
  reflectivity: 1,
  normal: "../tex/am_normal.png",
  normal_strength: 0.3
)
marble = Material.new(
  diffuse: "../tex/mb_diffuse2.png",
  specular: WHITE,
  roughness: 0.8,
  reflectivity: 0,
  normal: "../tex/mb_normal.png",
  normal_strength: 1
)
white = Material.new(
  diffuse: WHITE.mult(0.5),
  specular: WHITE,
  roughness: 0.2,
  reflectivity: 1,
)
green = Material.new(
  diffuse: GREEN.mult(0.7),
  specular: WHITE,
  roughness: 0.2,
  reflectivity: 0.3,
)
gp = Material.new(
  diffuse: Vec3.new(100,100,100),
  specular: WHITE.mult(1),
  roughness: 0.7,
  reflectivity: 0.8,
)
cliffrock = Material.new(
  diffuse: "../tex/rc_diffuse.tif",
  specular: WHITE.mult(0.3),
  roughness: 0.7,
  reflectivity: 0,
  normal: "../tex/rc_normal.tif",
  normal_strength: 0.7
)
celticgold = Material.new(
  diffuse: "../tex/cg_diffuse.png",
  specular: Vec3.new(255,200,0),
  roughness: 0.7,
  reflectivity: 0.3,
  normal: "../tex/cg_normal.png"
)
grass = Material.new(
  diffuse: "../tex/sg_diffuse.png",
  specular: WHITE,
  roughness: 0.7,
  reflectivity: 0,
  normal: "../tex/sg_normal.png"
)
redrock = Material.new(
  diffuse: "../tex/ww_diffuse.png",
  specular: WHITE,
  roughness: 0.7,
  reflectivity: 0,
  normal: "../tex/ww_normal.png"
)
stylizedcliff = Material.new(
  diffuse: "../tex/sc_diffuse.png",
  specular: WHITE,
  roughness: 0.7,
  reflectivity: 0,
  normal: "../tex/sc_normal.png"
)

rimlight = Material.new(
  emission: Vec3.new(110,110,255).mult(0.3)
)
coldlight = Material.new(
  emission: Vec3.new(255,255,255).mult(0.3)
)
warmlight = Material.new(
  #emission: Vec3.new(120,110,100)
  emission: WHITE.mult(0.7)
)
###############################
# Objects
###############################
s1 = Sphere.new(
  pos: Vec3.new(0, 0, 1.2),
  rad: 0.1,
  mat: celticgold

)
gp = Sphere.new(
  pos: Vec3.new(0, -100.1, 1.2),
  rad: 100,
  mat: gp

)
s5 = Sphere.new(
  pos: Vec3.new(0.23, 0, 1.13),
  rad: 0.07,
  mat: grass

)
s7 = Sphere.new(
  pos: Vec3.new(-0.25, 0.07, 1.5),
  rad: 0.1,
  mat: redrock

)
s2 = Sphere.new(
  pos: Vec3.new(-0.1, 0.13, 1.2),
  rad: 0.02,
  mat: blue

)
s3e = Sphere.new(
  pos: Vec3.new(-1, 1, 0.5),
  rad: 0.1,
  mat: warmlight
)
s9e = Sphere.new(
  pos: Vec3.new(0, -0.5, 0.9),
  rad: 0.1,
  mat: coldlight
)
s4e = Sphere.new(
  pos: Vec3.new(0.2, 1, 0.5),
  rad: 0.1,
  mat: coldlight

)
s6e = Sphere.new(
  pos: Vec3.new(0, 1, 1.2),
  rad: 0.1,
  mat: rimlight

)
s8e = Sphere.new(
  pos: Vec3.new(0, 3, 1),
  rad: 0.1,
  mat: warmlight

)

###############################
# Cam & Scene
###############################
cam = Camera.new(
  width: 1280,
  height: 720,
  pos: Vec3.new(0,0.05,0.5)
)
sc1 = Scene.new(
  objects: [s1, s2, s5, s7, gp],
  lights: [s6e, s4e, s3e], # , s6e, s4e
  filename: "scene1",
  cam: cam
)

engine = RenderEngine.new(env: "../tex/kloppenheim_06_2k.png")
puts "Loading finished"
sleep(1)
start = Time.now
engine.render(sc1)
puts "\nRendertime: #{(Time.now - start).round}s"
system("start scene1.ppm")

=end
