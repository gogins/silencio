local ffi = require( "ffi" )
local gl = require( "gl" )
local glu = require( "glu" )
local glfw = require( "glfw" )

package.path = package.path .. ';/home/mkg/scripts/?.lua;/media/3935-3164/sl4a/scripts/?.lua;/home/mkg/Downloads/iup/?.lua'

require "Silencio"
require "ChordSpace"

ChordSpaceView = {}

light = false
lp = true
fp = false

tx = 0
ty = 0
tz = 0

rx = 0
ry = 0
rz = 0

light = true
lp = true
fp = false

LightAmbient = ffi.new("float[4]")
LightAmbient[0] = .1
LightAmbient[1] = .1
LightAmbient[2] = .1
LightAmbient[3] = 1
LightDiffuse = ffi.new("float[4]")
LightDiffuse[0] = 1
LightDiffuse[1] = 1
LightDiffuse[2] = 1
LightDiffuse[3] = 1
LightPosition = ffi.new("float[3]")
LightPosition[0] = 1000
LightPosition[1] = 1000
LightPosition[2] = 1000
Ambient = ffi.new("float[4]")
Ambient[0] = 1
Ambient[1] = 1
Ambient[2] = 1
Ambient[3] = 0
Diffuse = ffi.new("float[4]")
Diffuse[0] = 1
Diffuse[1] = 1
Diffuse[2] = 1
Diffuse[3] = 0
Specular = ffi.new("float[4]")
Specular[0] = 1
Specular[1] = 1
Specular[2] = 1
Specular[3] = 1
Emission = ffi.new("float[4]")
Emission[0] = 0
Emission[1] = 0
Emission[2] = 0
Emission[3] = 1

function hsv_to_rgb(h, s, v)
    local hi = math.floor(h / 60.0) % 6
    local f =  (h / 60.0) - math.floor(h / 60.0)
    local p = v * (1.0 - s)
    local q = v * (1.0 - (f * s))
    local t = v * (1.0 - ((1.0 - f) * s))
    if      hi == 0 then
        return v, t, p
    else if hi == 1 then
        return q, v, p
    else if hi == 2 then
        return p, v, t
    else if hi == 3 then
        return p, q, v
    else if hi == 4 then
        return t, p, v
    else if hi == 5 then
        return v, p, q
    end end end end end end
end
 
function iterateColor(c)
    r = c[1] + 1
    if r < 100 then
        c[1] = r
    else
        c[1] = 1
        g = c[2] + 1
        if g < 100 then
            c[2] = g
        else
            c[2] = 1
            c[3] = c[3] + 1
        end
    end
end


ChordView = {}

function ChordView:new(o)
    local o = o or {title = 'Chord View', octaves = 3, equivalence = 'OP', chords = {}, minima = {}, maximuma = {}, ranges = {}, fullscreen = true, minima = {}, maxima = {}, ranges = {}}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ChordView:k_any(c)
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

function ChordView:material()
    gl.glShadeModel(gl.GL_SMOOTH)           
    gl.glClearColor(0, 0, 0, 0.5)       
    gl.glClearDepth(1.0)                 
    gl.glEnable(gl.GL_DEPTH_TEST)          
    gl.glDepthFunc(gl.GL_LEQUAL)           
    gl.glHint(gl.GL_PERSPECTIVE_CORRECTION_HINT, gl.GL_NICEST)
    gl.glEnable(gl.GL_COLOR_MATERIAL)
    gl.glLightfv(gl.GL_LIGHT1, gl.GL_AMBIENT, LightAmbient)
    gl.glLightfv(gl.GL_LIGHT1, gl.GL_DIFFUSE, LightDiffuse)
    gl.glLightfv(gl.GL_LIGHT1, gl.GL_POSITION, LightPosition)
    gl.glEnable(gl.GL_LIGHT1)
    gl.glMaterialfv(gl.GL_BACK, gl.GL_AMBIENT, Ambient)
    gl.glMaterialfv(gl.GL_BACK, gl.GL_DIFFUSE, Diffuse)
    gl.glMaterialfv(gl.GL_FRONT_AND_BACK, gl.GL_SPECULAR, Specular)
    gl.glMaterialfv(gl.GL_FRONT_AND_BACK, gl.GL_EMISSION, Emission)
    gl.glEnable(gl.GL_NORMALIZE)
    gl.glEnable(gl.GL_LIGHTING)
    light = true
end

function ChordView:draw(picking)
    picking = picking or false
    gl.glClear(gl.GL_COLOR_BUFFER_BIT)
    if picking then
        gl.glDisable(gl.GL_BLEND);
        gl.glDisable(gl.GL_DITHER);
        gl.glDisable(gl.GL_FOG);
        gl.glDisable(gl.GL_LIGHTING);
        gl.glDisable(gl.GL_TEXTURE_1D);
        gl.glDisable(gl.GL_TEXTURE_2D);
        gl.glDisable(gl.GL_TEXTURE_3D);
        gl.glShadeModel(gl.GL_FLAT);
        print('Depth:', redbits, greenbits, bluebits)
        self.c = {1, 1, 1}
    else
        self:material()
    end
    gl.glClear(gl.GL_COLOR_BUFFER_BIT)
    gl.glClear(gl.GL_DEPTH_BUFFER_BIT)
    gl.glLoadIdentity()
    gl.glTranslatef(tx,ty,tz)
    gl.glTranslatef(self.centerX, self.centerY, self.centerZ)
    gl.glRotatef(rx,1,0,0)
    gl.glRotatef(ry,0,1,0)
    gl.glRotatef(rz,0,0,1)
    gl.glTranslatef(-tx,-ty,-tz)
    gl.glTranslatef(-self.centerX, -self.centerY, -self.centerZ)
    gl.glTranslatef(tx,ty,tz)
    self:drawGrid()
    for i, chord in ipairs(self.chords) do
        self:drawChord(chord, picking)
    end
    if not picking then
        glfw.glfwSwapBuffers()
    end
end

function ChordView:drawGrid()
    gl.glBegin(gl.GL_LINES)
    local range = OCTAVE * self.octaves
    gl.glColor4f(1, 0, 0, 0.5)
    gl.glVertex3f(0, 0, 0)
    gl.glVertex3f(0, 0, range)
    gl.glVertex3f(0, 0, 0)
    gl.glVertex3f(0, range, 0)
    gl.glVertex3f(0, 0, 0)
    gl.glVertex3f(range, 0, 0)
    gl.glColor4f(0, 1, 0, 0.5)
    gl.glVertex3f(0, 0, 0)
    local orthogonalAxisPoints = math.sin(math.pi / 4) * range
    gl.glVertex3f(orthogonalAxisPoints, orthogonalAxisPoints, orthogonalAxisPoints)
    gl.glColor4f(0.3, 0.3, 0.3, 0.5)
    for i, c0 in ipairs(self.chords) do
        if self:isE(c0) then    
            c1 = c0:clone()
            c1[1] = c0[1] + 1
            if self:isE(c1) then
                gl.glVertex3f(c0[1], c0[2], c0[3])
                gl.glVertex3f(c1[1], c1[2], c1[3])
            end
            c2 = c0:clone()
            c2[2] = c0[2] + 1
            if self:isE(c2) then
                gl.glVertex3f(c0[1], c0[2], c0[3])
                gl.glVertex3f(c2[1], c2[2], c2[3])
            end
            c3 = c0:clone()
            c3[3] = c0[3] + 1
            if self:isE(c3) then
                gl.glVertex3f(c0[1], c0[2], c0[3])
                gl.glVertex3f(c3[1], c3[2], c3[3])
            end
        end
    end
    gl.glEnd()
end 

function ChordView:resize(width, height)
    gl.glViewport(0, 0, width, height)
    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    self.width_ = width
    self.height_ = height
    self.aspect = width / height
    print('aspect:', self.aspect)
    self.beginX = self.minima[1]
    self.beginY = self.minima[2]
    self.beginZ = self.minima[3]
    self.sizeX = self.ranges[1]
    self.sizeY = self.ranges[2]
    self.sizeZ = self.ranges[3]
    self.endX = self.maxima[1]
    self.endY = self.maxima[2]
    self.endZ = self.maxima[3]
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
    glu.gluPerspective(45, self.aspect, 1, 50000)
    print(string.format('Center: x: %9.4f, y: %9.4f, z: %9.4f', self.centerX, self.centerY, self.centerZ))
    print(string.format('Front: %9.4f, back: %9.4f', self.front, self.back))
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
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

function ChordView:drawChord(chord, picking)
    picking = picking or false
    gl.glPushMatrix()
    gl.glTranslatef(chord[1], chord[2], chord[3])
    gl.glBegin(gl.GL_QUADS)                                                       
    local quadric = glu.gluNewQuadric()
    if not picking then
        local z = chord:eop():closestVoicing():et()
        if z      == self.augmentedTriad then
            gl.glColor3f(1, 1, 1)
        else if z == self.majorTriad1 then
            gl.glColor3f(1, 0, 0)
        else if z == self.minorTriad1 then
            gl.glColor3f(0, 0, 1)
        else
            local hue = (z[1] + z[2] * 2.0 + z[3]) * 10
            local saturation = 1.0
            local value = 1.0
            local red, green, blue = hsv_to_rgb(hue, saturation, value)
            gl.glColor3f(red, green, blue)
        end end end
    else
        iterateColor(self.c)
        print(string.format('c[1]: %s c[2]: %s  c[3] %s  chord: %s', self.c[1], self.c[2], self.c[3], tostring(chord)))
        gl.glColor3i(self.c[1], self.c[2], self.c[3])
    end
    local radius = 0
    if self:isE(chord) then
        radius = 1/12
    else
        radius = 1/36
    end
    glu.gluSphere(quadric, radius, 16, 16)
    gl.glEnd()
    gl.glPopMatrix()
end

function ChordView:createChords()
    self.augmentedTriad = Chord:new{0, 4, 8}
    self.majorTriad1 = Chord:new{0, 4, 7}
    self.minorTriad1 = Chord:new{0, 3, 7}
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
    glfw.glfwInit()
    local window = glfw.glfwOpenWindow( 0, 0, glfw.GLFW_WINDOWED, "Chord Space", nil)
    glfw.glfwSwapInterval(1)
    glfw.glfwEnable(window, glfw.GLFW_STICKY_KEYS)
    glfw.glfwDisable(window, glfw.GLFW_AUTO_POLL_EVENTS)
    local newwidth = ffi.new("int[1]")
    local newheight = ffi.new("int[1]")
    local oldwidth = ffi.new("int[1]")
    local oldheight = ffi.new("int[1]")
    local newmousex = ffi.new("int[1]")
    local newmousey = ffi.new("int[1]")
    local oldmousex = ffi.new("int[1]")
    local oldmousey = ffi.new("int[1]")
    glfw.glfwGetWindowSize(window, newwidth, newheight)
    glfw.glfwGetWindowSize(window, oldwidth, oldheight)
    glfw.glfwGetMousePos(window, newmousex, newmousey)
    glfw.glfwGetMousePos(window, oldmousex, oldmousey)
    self:resize(newheight[0], newwidth[0])
    while true do
        self:draw()
        -- Check for resizing.
        oldwidth[0] = newwidth[0]
        oldheight[0] = newheight[0]
        glfw.glfwGetWindowSize(window, newwidth, newheight)
        if (newheight[0] ~= oldheight[0]) or (newwidth[0] ~= oldwidth[0]) then
            print('New size:', newwidth[0], newheight[0])
            self:resize(newheight[0], newwidth[0])
        end
        glfw.glfwPollEvents()
        -- Get key input.
        -- Get mouse input.
        local button = glfw.glfwGetMouseButton(window, glfw.GLFW_MOUSE_BUTTON_LEFT)
        if button == glfw.GLFW_PRESS then
            self:draw(true)
            -- void glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels);
            local color = ffi.new('int[4]')
            gl.glReadPixels(x, y, 1, 1, gl.GL_RGB, gl.GL_INT, colorp)
            print('Left button - color:', color[0], color[1], color[2])
        end
        oldmousex[0] = newmousex[0]
        oldmousey[0] = newmousey[0]
        glfw.glfwGetMousePos(window, newmousex, newmousey)
        if (newmousex[0] ~= oldmousex[0] or newmousey[0] ~= oldmousey[0]) then
            print('New mouse:', newmousex[0], newmousey[0])
        end
    end
end

chordView = ChordView:new()
chordView.octaves = 3
chordView.equivalence = 'OP'
chordView:createChords()
chordView:findSize()
chordView:display()

return ChordSpaceView


--[[
local function main()
   assert( glfw.glfwInit() )
   local window = glfw.glfwOpenWindow( -1, -1, glfw.GLFW_WINDOWED, "Spinning Triangle", nil)
   assert( window )
   glfw.glfwEnable(window, glfw.GLFW_STICKY_KEYS);
   glfw.glfwSwapInterval(1);
   while glfw.glfwIsWindow(window) and glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) ~= glfw.GLFW_PRESS 
   do
      local double t = glfw.glfwGetTime()

      local x = ffi.new( "int[1]" )
      glfw.glfwGetMousePos(window, x, nil)
      x = x[0]

      local width, height = ffi.new( "int[1]" ), ffi.new( "int[1]" )
      glfw.glfwGetWindowSize(window, width, height);
      width, height = width[0], height[0]
      if height < 1 then
	 height = 1
      end

      gl.glViewport(0, 0, width, height);
      gl.glClearColor(0, 0, 0, 0);
      gl.glClear(gl.GL_COLOR_BUFFER_BIT);

      gl.glMatrixMode(gl.GL_PROJECTION);
      gl.glLoadIdentity();
      glu.gluPerspective(65, width / height, 1, 100);
      
      gl.glMatrixMode( gl.GL_MODELVIEW );
      gl.glLoadIdentity();
      glu.gluLookAt(
	 0,  1, 0,   -- Eye-position
	 0, 20, 0,   -- View-point
	 0,  0, 1    -- Up Vector
      );
      
      gl.glTranslatef(0, 14, 0);
      gl.glRotatef(0.3 * x + t * 100, 0, 0, 1);
      
      gl.glBegin(gl.GL_TRIANGLES);
      gl.glColor3f(1, 0, 0);
      gl.glVertex3f(-5, 0, -4);
      gl.glColor3f(0, 1, 0);
      gl.glVertex3f(5, 0, -4);
      gl.glColor3f(0, 0, 1);
      gl.glVertex3f(0, 0, 6);
      gl.glEnd();
      
      glfw.glfwSwapBuffers();
      glfw.glfwPollEvents();
   end
   glfw.glfwTerminate();
end

main()
]]

