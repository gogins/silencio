--[[
When this package is run as a standalone program, 
it displays models of various chord spaces (see ChordSpace),
playing the results using Csound. The script demonstrates:

--  The orbifolds induced by various equivalence classes 
    (press e followed by equivalence class, e.g. eOP or eOPTI).

--  The triadic neo-Riemannian transformations
    of leading-tone exchange (press l), 
    parallel (press p), relative (press r),
    and dominant (press d) progression. 
    See Alissa S. Crans, Thomas M. Fiore, and Raymon Satyendra, 
    _Musical Actions of Dihedral Groups_, 2008 
    (arXiv:0711.1873v2).

--  Root progression by transposition (press 1 through 6).

--  One-step voiceleadings (up arrow/shift up arrow 
    to move voice 1 up/down 1 semitone, right/shift right arrow 
    to move voice 2 up/down 1 semitone, down/shift down arrow 
    to move voice 3 up/down 1 semitone).
    
--  In the RP orbifold, press v for smoothest voice-leadings 
    (select a chord, select another chord, the closest voice-leading 
    to the OP of the selected chord will be displayed).
]]
package.path = package.path .. ';/media/3935-3164/sl4a/scripts/?.lua;/home/mkg/Downloads/iup/?.lua'
package.cpath = package.cpath .. ';/home/mkg/Downloads/iup/?.so;/home/mkg/Downloads/iup/lib?51.so;/home/mkg/Downloads/iup/libiup?.so;/home/mkg/Downloads/iup/libiup?51.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/lib?51.so;/usr/local/lib/lua/5.1/loadall.so'

print('package.path:', package.path)
print('package.cpath:', package.cpath)

require "Silencio"
require "ChordSpace"

print('package.path:', package.path)
print('package.cpath:', package.cpath)

require "iuplua"
require "iupluagl"
require "luagl"
require "luaglu"
require "LoadTGA"

ChordSpaceView = {}

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
    self.beginX = self.chordView.minima[1]
    self.beginY = self.chordView.minima[2]
    self.beginZ = self.chordView.minima[3]
    self.sizeX = self.chordView.ranges[1]
    self.sizeY = self.chordView.ranges[2]
    self.sizeZ = self.chordView.ranges[3]
    self.endX = self.chordView.maxima[1]
    self.endY = self.chordView.maxima[2]
    self.endZ = self.chordView.maxima[3]
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

function canvas:drawChord(chord)
    gl.PushMatrix()
    gl.Translate(chord[1], chord[2], chord[3])
    gl.Begin('QUADS')
    quadric = glu.NewQuadric()
    eopt = chord:eopt()
    if eopt      == self.chordView.augmentedTriad then
        gl.Color(1, 1, 1)
    else if eopt == self.chordView.majorTriad1 -- or eopt == self.chordView.majorTriad2 or eopt == self.chordView.majorTriad3 then
        gl.Color(1, 0, 0)
    else if eopt == self.chordView.minorTriad1 or eopt == self.chordView.minorTriad2 or eopt == self.chordView.minorTriad3 then
        gl.Color(0, 0, 1)
    else
        gl.Color(chord:sum() / 36, 1, chord:sum() / 36)
    end end end
    local radius = 0
    if self.chordView:isE(chord) then
        radius = 1/12
    else
        radius = 1/36
    end
    quadric:Sphere(radius, 16, 16)
    gl.End()
    gl.PopMatrix()
end

function canvas:drawGrid()
    gl.Begin('LINES')
    local range = OCTAVE * self.chordView.octaves
    gl.Color(1, 0, 0, 0.5)
    gl.Vertex(0, 0, 0)
    gl.Vertex(0, 0, range)
    gl.Vertex(0, 0, 0)
    gl.Vertex(0, range, 0)
    gl.Vertex(0, 0, 0)
    gl.Vertex(range, 0, 0)
    gl.Color(0, 1, 0, 0.5)
    gl.Vertex(0, 0, 0)
    local orthogonalAxisPoints = math.sin(math.pi / 4) * range
    gl.Vertex(orthogonalAxisPoints, orthogonalAxisPoints, orthogonalAxisPoints)
    gl.Color(0.3, 0.3, 0.3, 0.5)
    for i, c0 in ipairs(self.chordView.chords) do
        if self.chordView:isE(c0) then    
            c1 = c0:clone()
            c1[1] = c0[1] + 1
            if self.chordView:isE(c1) then
                gl.Vertex(c0[1], c0[2], c0[3])
                gl.Vertex(c1[1], c1[2], c1[3])
            end
            c2 = c0:clone()
            c2[2] = c0[2] + 1
            if self.chordView:isE(c2) then
                gl.Vertex(c0[1], c0[2], c0[3])
                gl.Vertex(c2[1], c2[2], c2[3])
            end
            c3 = c0:clone()
            c3[3] = c0[3] + 1
            if self.chordView:isE(c3) then
                gl.Vertex(c0[1], c0[2], c0[3])
                gl.Vertex(c3[1], c3[2], c3[3])
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
    for i, chord in ipairs(self.chordView.chords) do
        self:drawChord(chord)
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
    gl.Enable('LIGHTING')
    print('Lighting enabled.')
    light = true
end

ChordView = {}

function ChordView:new(o)
    local o = o or {title = 'Chord View', octaves = 3, equivalence = 'OP', chords = {}, minima = {}, maximuma = {}, ranges = {}, fullscreen = true}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ChordView:createChords()
    self.augmentedTriad = Chord:new{0, 4, 8}
    self.majorTriad1 = Chord:new{0, 4, 7}
    self.majorTriad2 = Chord:new{0, 3, 8}
    self.majorTriad3 = Chord:new{0, 5, 9}
    self.minorTriad1 = Chord:new{0, 3, 7}
    self.minorTriad2 = Chord:new{0, 5, 8}
    self.minorTriad3 = Chord:new{0, 4, 9}
    for v1 = -self.octaves * 12, self.octaves * 12 do
        for v2 = -self.octaves * 12, self.octaves * 12 do
            for v3 = -self.octaves * 12, self.octaves * 12 do
                chord = Chord:new{v1, v2, v3}
                if self:isE(chord) then
                    table.insert(self.chords, chord)
                end
             end
        end
    end
    table.sort(self.chords)
    for i, chord in ipairs(self.chords) do
        print(chord:label())   
    end
    print(string.format('Created %s chords for equivalence class %s.', #self.chords, self.equivalence))
end

function ChordView:isE(chord)
    if self.equivalence == 'R' then
        return chord:iseR(self.octaves * OCTAVE)
    end
    if self.equivalence == 'O' then
        return chord:iseO()
    end
    if self.equivalence == 'P' then
        return chord:iseP()
    end
    if self.equivalence == 'T' then
        return chord:iseT()
    end
    if self.equivalence == 'I' then
        return chord:iseI()
    end
    if self.equivalence == 'RP' then
        return chord:iseRP(self.octaves * OCTAVE)
    end
    if self.equivalence == 'OP' then
        return chord:iseOP()
    end
    if self.equivalence == 'OT' then
        return chord:iseOT()
    end
    if self.equivalence == 'OI' then
        return chord:iseOI()
    end
    if self.equivalence == 'OPT' then
        return chord:iseOPT()
    end
    if self.equivalence == 'OPI' then
        return chord:iseOPI()
    end
    if self.equivalence == 'OPTI' then
        return chord:iseOPTI()
    end
end

function ChordView:findSize()
    self.minima = self.chords[1]:clone()
    self.maxima = self.chords[1]:clone()
    self.ranges = self.chords[1]:clone()
    for i, chord in ipairs(self.chords) do
        for voice = 1, 3 do
            if self.minima[voice] > chord[voice] then
                self.minima[voice] = chord[voice]
            end
            if self.maxima[voice] < chord[voice] then
                self.maxima[voice] = chord[voice]
            end
        end
    end
    for voice = 1, 3 do
        self.ranges[voice] = self.maxima[voice] - self.minima[voice]
    end
end

function ChordView:display()
    dialog = iup.dialog{canvas; self.title}
    canvas.chordView = self
    dialog:show()
    canvas.rastersize = nil
    timer.run = "YES"
    if (not iup.MainLoopLevel or iup.MainLoopLevel()==0) then
      iup.MainLoop()
    end
end

chordView = ChordView:new()
chordView.octaves = 3
chordView.equivalence = 'OP'
chordView:createChords()
chordView:findSize()
chordView:display()

return ChordSpaceView
