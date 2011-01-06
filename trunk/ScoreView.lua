--[[
What we want here is the following:
(1) Display a 3-dimensional piano roll view of a score:
    Time -- X axis
    Pitch -- Y axis
    Instrument -- Z axis AND hue
    Loudness -- value (brightness)
(2) Notes are flat 'boards' with thickness (25 cents), width (1 instrument number), and length (duration in seconds).
(3) Notes are displayed within a grid of semi-transparent lines denoting time, pitch, and instrument spaced by MIDI key number,
    second, and instrument number. The origin should be denoted by a ball, and 10 second and octave ticks should be denoted by smaller balls.
(4) It should be possible to pick notes using the mouse; doing so will toggle a display of the actual values of the note and/or play the note.
(5) The user should be able to navigate in the score by translating and rotating on all 3 dimensions.
]]
print('package.path:', package.path)
print('package.cpath:', package.cpath)

require "iuplua"
require "iupluagl"
require "luagl"
require "luaglu"
require "LoadTGA"

ScoreView = {}

iup.key_open()

light = false
lp = true
fp = false

tx = 0
ty = 0
tz = 0

rx = 0
ry = 0
rz = 0

iup.key_open()

light = true
lp = true
fp = false

LightAmbient = {.1, .1, .1, 1}   
LightDiffuse = {1, 1, 1, 1}       
LightPosition = {1000, 1000, 1000}     

canvas = iup.glcanvas{buffer="DOUBLE", rastersize = "1200x600"}

timer = iup.timer{time=10}

function timer:action_cb()
    iup.Update(canvas)
end

function canvas:resize_cb(width, height)
    iup.GLMakeCurrent(self)
    gl.Viewport(0, 0, width, height)
    gl.MatrixMode('PROJECTION')
    gl.LoadIdentity()
    self.width_ = width
    self.height_ = height
    self.aspect = width / height
    print('aspect:', self.aspect)
    local scales = self.score:findScales()
    self.beginX = scales[1][TIME]
    self.beginY = scales[1][KEY]
    self.beginZ = scales[1][CHANNEL]
    self.sizeX = scales[2][TIME]
    self.sizeY = scales[2][KEY]
    self.sizeZ = scales[2][CHANNEL]
    self.endX = self.beginX + self.sizeX
    self.endY = self.beginY + self.sizeY
    self.endZ = self.beginZ + self.sizeZ
    self.centerX = self.beginX + self.sizeX / 2
    self.centerY = self.beginY + self.sizeY / 2
    self.centerZ = self.beginZ + self.sizeZ / 2
    local boundingSize = self.sizeX
    if boundingSize < self.sizeY then
        boundingSize = self.sizeY
    end
    if boundingSize < self.sizeZ then
        boundingSize = self.sizeZ
    end
    self.left = self.centerX - boundingSize
    self.right = self.centerX + boundingSize
    self.top = self.centerY - boundingSize
    self.bottom = self.centerY + boundingSize
    if tonumber(self.aspect) < 1.0 then
        self.bottom =  self.bottom / self.aspect
        self.top = self.bottom / self.aspect
    else
        self.left = self.left * self.aspect
        self.right = self.right * self.aspect
    end
    self.front = self.centerZ + boundingSize * 2
    self.back = self.centerZ - boundingSize * 2
    glu.Perspective(45, self.aspect, 1, 50000)
    print(string.format('Center: x: %9.4f, y: %9.4f, z: %9.4f', self.centerX, self.centerY, self.centerZ))
    print(string.format('Front: %9.4f, back: %9.4f', self.front, self.back))
    gl.MatrixMode('MODELVIEW')
    gl.LoadIdentity()
    tx = -self.centerX
    ty = -self.centerY
    tz = -boundingSize * 3
    self.gridXs = {}
    self.gridYs = {}
    self.gridZs = {}
    local i = 1
    for x = self.beginX, self.endX, 10 do
        self.gridXs[i] = x
        i = i + 1
    end
    self.gridXs[i] = self.endX
    i = 1
    local modY = self.beginY % 12
    if modY ~= 0 then
        self.beginY = self.beginY - modY
    end
    for y = self.beginY, self.endY, 12 do
        self.gridYs[i] = y
        i = i + 1
    end
    self.gridYs[i] = self.endY
    i = 1
    for z = self.beginZ, self.endZ, 1 do
        self.gridZs[i] = z
        i = i + 1
    end
    self.gridZs[i] = self.endZ
 end

function canvas:drawNote(note)
    gl.PushMatrix()
    gl.Translate(note[TIME], note[KEY], note[CHANNEL])
    gl.Begin('QUADS')
    gl.Color(note[CHANNEL] / 16.0, note[CHANNEL] / 16.0, 1.0, note[VELOCITY] / 127)
    local d = note[DURATION]
    local w = 1
    local t = 0.25
    -- Front Face
    gl.Normal( 0,  0,  1)
    gl.Vertex( 0,  0,  w, 1)
    gl.Vertex( d,  0,  w, 1)
    gl.Vertex( d,  t,  w, 1)
    gl.Vertex( 0,  t,  w, 1)
    -- Back Face
    gl.Normal( 0,  0, -1)
    gl.Vertex( 0,  0,  0, 1)
    gl.Vertex( d,  0,  0, 1)
    gl.Vertex( d,  t,  0, 1)
    gl.Vertex( 0,  t,  0, 1)
    -- Top Face
    gl.Normal( 0,  1,  0)
    gl.Vertex( 0,  t,  0, 1)
    gl.Vertex( d,  t,  0, 1)
    gl.Vertex( d,  t,  w, 1)
    gl.Vertex( 0,  t,  w, 1)
    -- Bottom Face
    gl.Normal( 0, -1,  0)
    gl.Vertex( 0,  0,  0, 1)
    gl.Vertex( d,  0,  0, 1)
    gl.Vertex( d,  0,  w, 1)
    gl.Vertex( 0,  0,  w, 1)
    -- Right Face
    gl.Normal( 1,  0,  0)
    gl.Vertex( d,  0,  0, 1)
    gl.Vertex( d,  t,  0, 1)
    gl.Vertex( d,  t,  w, 1)
    gl.Vertex( d,  0,  w, 1)
    -- Left Face
    gl.Normal(-1,  0,  0)
    gl.Vertex( 0,  0,  0, 1)
    gl.Vertex( 0,  t,  0, 1)
    gl.Vertex( 0,  t,  w, 1)
    gl.Vertex( 0,  0,  w, 1)

    gl.End()
    gl.PopMatrix()
end

function canvas:drawGrid()
    gl.Begin('LINES')
    for xi, x in ipairs(self.gridXs) do
        for yi, y in ipairs(self.gridYs) do
            for zi, z in ipairs(self.gridZs) do
                if y - self.beginY == 36 then
                    gl.Color(1, 0, 0, 0.5)
                else
                    gl.Color(0, 1, 0, 0.5)
                end
                gl.Vertex(self.beginX, y, z)
                gl.Vertex(self.endX, y, z)
                gl.Vertex(x, self.beginY, z)
                gl.Vertex(x, self.endY, z)
                gl.Vertex(x, y, self.beginZ)
                gl.Vertex(x, y, self.endZ)
            end
        end
    end
    gl.End()
end

function canvas:action(x, y)
    iup.GLMakeCurrent(self)
    gl.Clear('COLOR_BUFFER_BIT')
    gl.Clear('DEPTH_BUFFER_BIT')
    gl.LoadIdentity()
    gl.Translate(tx,ty,tz)
    gl.Translate(self.centerX, self.centerY, self.centerZ)
    gl.Rotate(rx,1,0,0)
    gl.Rotate(ry,0,1,0)
    gl.Rotate(rz,0,0,1)
    gl.Translate(-tx,-ty,-tz)
    gl.Translate(-self.centerX, -self.centerY, -self.centerZ)
    gl.Translate(tx,ty,tz)
    self:drawGrid()
    for i, note in ipairs(self.score) do
        self:drawNote(note)
    end
    iup.GLSwapBuffers(self)
end

function canvas:k_any(c)
  if c == iup.K_q or c == iup.K_ESC then
    return iup.CLOSE
  end
  if c == iup.K_F1 then
    if fullscreen then
      fullscreen = false
      dialog.fullscreen = "No"
    else
      fullscreen = true
      dialog.fullscreen = "Yes"
    end
    iup.SetFocus(canvas)
  end
  if c == iup.K_l then   -- 'L' Key Being Pressed ?
    if (light) then
      gl.Disable('LIGHTING')
      print('Lighting disabled.')
      light = false
    else
      gl.Enable('LIGHTING')
      print('Lighting enabled.')
      light = true
    end
  end
    if c == iup.K_RIGHT     then tx = tx + 1 end
    if c == iup.K_LEFT      then tx = tx - 1 end
    if c == iup.K_UP        then ty = ty + 1 end
    if c == iup.K_DOWN      then ty = ty - 1 end
    if c == iup.K_PGUP      then tz = tz + 1 end
    if c == iup.K_PGDN      then tz = tz - 1 end
    if c == iup.K_cRIGHT    then rx = rx + 1 end
    if c == iup.K_cLEFT     then rx = rx - 1 end
    if c == iup.K_cUP       then ry = ry + 1 end
    if c == iup.K_cDOWN     then ry = ry - 1 end
    if c == iup.K_cPGUP     then rz = rz + 1 end
    if c == iup.K_cPGDN     then rz = rz - 1 end
    if c == iup.K_r         then
        tx = 0
        ty = 0
        tz = 0
        rx = 0
        ry = 0
        rz = 0
        self:resize_cb(self.width_, self.height_)
    end
    print(string.format('tx: %9.4f  ty: %9.4f  tz: %9.4f  rx: %9.4f  ry: %9.4f  rz: %9.4f', tx, ty, tz, rx, ry, rz))
end

function canvas:map_cb()
    iup.GLMakeCurrent(self)
    gl.ShadeModel('SMOOTH')            -- Enable Smooth Shading
    gl.ClearColor(0, 0, 0, 0.5)        -- Black Background
    gl.ClearDepth(1.0)                 -- Depth Buffer Setup
    gl.Enable('DEPTH_TEST')            -- Enables Depth Testing
    gl.DepthFunc('LEQUAL')             -- The Type Of Depth Testing To Do
    gl.Hint('PERSPECTIVE_CORRECTION_HINT','NICEST')
    gl.Enable('COLOR_MATERIAL')
    gl.Light('LIGHT1', 'AMBIENT', LightAmbient)
    gl.Light('LIGHT1', 'DIFFUSE', LightDiffuse)
    gl.Light('LIGHT1', 'POSITION', LightPosition)
    gl.Enable('LIGHT1')
    gl.Material('BACK', 'AMBIENT', 1, 1, 1, 0)
    gl.Material('BACK', 'DIFFUSE', 1, 1, 1, 0)
    gl.Material('FRONT_AND_BACK', 'SPECULAR', 1, 1, 1, 1)
    gl.Material('FRONT_AND_BACK', 'EMISSION', 0, 0, 0, 1)
    gl.Enable('NORMALIZE')
end

function ScoreView.display(score_)
    dialog = iup.dialog{canvas; title=score.title}
    canvas.score = score_
    dialog:show()
    canvas.rastersize = nil
    timer.run = "YES"
    if (not iup.MainLoopLevel or iup.MainLoopLevel()==0) then
      iup.MainLoop()
    end
end

return ScoreView
