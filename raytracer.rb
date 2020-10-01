require_relative "classes/vec3"
require_relative "classes/ray"
require_relative "classes/sphere"
require_relative "classes/plane"
require_relative "classes/colors"
require_relative "classes/scene"
require_relative "classes/material"
require_relative "classes/camera"
require_relative "classes/progressbar"


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
  diffuse: Vec3.new(230, 40, 40),
  specular: WHITE.mult(0.4),
  roughness: 0.4,
  reflectivity: 1,
  emission: Vec3.new
)
blue = Material.new(
  diffuse: BLUE,
  specular: WHITE.mult(0.4),
  roughness: 0.4,
  reflectivity: 0,
  emission: Vec3.new
)
purple = Material.new(
  diffuse: Vec3.new(190,0,255),
  specular: WHITE,
  roughness: 0.8,
  reflectivity: 1,
  emission: Vec3.new
)
white = Material.new(
  diffuse: WHITE,
  specular: WHITE,
  roughness: 0.2,
  reflectivity: 1,
  emission: Vec3.new
)
gp = Material.new(
  diffuse: Vec3.new(60,60,60),
  specular: WHITE.mult(0.7),
  roughness: 0.7,
  reflectivity: 0,
  emission: Vec3.new
)

rimlight = Material.new(
  emission: Vec3.new(255,127,0).mult(0.3)
)
coldlight = Material.new(
  emission: Vec3.new(50,50,70)
)
warmlight = Material.new(
  emission: Vec3.new(120,110,100)
)
###############################
# Objects
###############################
s1 = Sphere.new(
  pos: Vec3.new(0, 0, 1.2),
  rad: 0.1,
  mat: red

)
gp = Sphere.new(
  pos: Vec3.new(0, -100.05, 1.2),
  rad: 100,
  mat: gp

)
s5 = Sphere.new(
  pos: Vec3.new(0.23, 0, 1.13),
  rad: 0.07,
  mat: purple

)
s7 = Sphere.new(
  pos: Vec3.new(-0.25, 0.07, 1.5),
  rad: 0.1,
  mat: white

)
s2 = Sphere.new(
  pos: Vec3.new(-0.1, 0.13, 1.2),
  rad: 0.02,
  mat: blue

)
s3e = Sphere.new(
  pos: Vec3.new(-1, 1, 0.5),
  rad: 0.01,
  mat: warmlight
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
###############################
# Cam & Scene
###############################
cam = Camera.new(
  width: 1280,
  height: 720,
  pos: Vec3.new(0,0.05,0.2)
)
sc1 = Scene.new(
  objects: [s1, s5, s7, gp],
  lights: [s3e, s4e, s6e],
  filename: "scene1"
)

system("title RubyRaytracer")
sc1.render(cam)
sc1.openRes
