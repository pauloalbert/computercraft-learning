ImagePrototype = {data={}}

function ImagePrototype.__init__ (data)
  local self = {data=data}
  setmetatable (self, {__index=ImagePrototype})
  return self
end

function ImagePrototype:printData ()
  print (self.data)   
end

local image1 = ImagePrototype.__init__ ("1,1,Black;")
image1:printData()
