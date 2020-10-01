class Scene

  attr_accessor :filename, :cam, :objects, :lights

  def initialize(lights: [], objects: [], filename: "untitled", cam:)
    @objects = []
    @lights = []
    objects.each do |obj|
      if obj.mat.emission.length != 0 then @lights.push(obj) else @objects.push(obj) end
    end
    @filename = filename
    @cam = cam
  end

end
