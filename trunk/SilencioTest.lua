require "Silencio"

Silencio.help()

score = Score:new()
c = 0.9739333
y = 0.5
n = 1000
dt = 0.075
d = 0.375
for i = 1, n do 
    y0 = y * c * 4.0 * (1.0 - y)
    y = y0
    score:append(i * dt, d, 144, 0, math.floor(36.5 + y * 60.0), 80, 0, 0, 0, 0, 1)
end
print("Generated score:")
for i, event in ipairs(score) do
    print(i, event:csoundIStatement())
    print(' ', event:midiScoreEventString())
end
score:saveCsound()
score:saveMidi({{'patch_change', 0, 0, 1}})
score:playMidi()
print("Finished.")

