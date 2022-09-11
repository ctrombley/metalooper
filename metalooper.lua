rate = 1.0
rec = 1.0
pre = 0.0
default_tempo = 120.0
time_sig_count = 4
time_sig_quantum = 4
metro_amp = .5
metro_note = 60

music = require 'musicutil'
engine.name = 'PolyPerc'

function init()
  params:set("clock_tempo",default_tempo)

  -- send audio input to softcut input
	audio.level_adc_cut(1)
  
  softcut.buffer_clear()
  softcut.enable(1,1)
  softcut.buffer(1,1)
  softcut.level(1,1.0)
  softcut.rate(1,1.0)
  softcut.loop(1,1)
  softcut.loop_start(1,1)
  softcut.loop_end(1,3)
  softcut.position(1,1)
  softcut.play(1,1)

  -- set input rec level: input channel, voice, level
  softcut.level_input_cut(1,1,1.0)
  softcut.level_input_cut(2,1,1.0)
  -- set voice 1 record level 
  softcut.rec_level(1,rec)
  -- set voice 1 pre level
  softcut.pre_level(1,pre)
  -- set record state of voice 1 to 1
  softcut.rec(1,1)

  clock.run(loop)
end

function loop()
  while true do
    beat = util.wrap(clock.get_beats(), 1, time_sig_count) // 1
    downbeat_hz_mult = beat == 1 and 2 or 1
    downbeat_amp_mult = beat == 1 and 2 or 1

    engine.amp(metro_amp * downbeat_amp_mult)
    engine.hz(music.note_num_to_freq(metro_note) * downbeat_hz_mult)
    engine.release(.3)

    clock.sync(1)
  end
end

function key(n,z)
  print("key " .. n .. " == " .. z)
  updateScreen()
end

function enc(n,d)
  if n == 2 then
    metro_amp = util.clamp(metro_amp + d*.01,0,1)
  end
  if n == 3 then
    metro_note = util.clamp(metro_note + d,0,100)
  end
  updateScreen()
end

function updateScreen()
  screen.clear()
  screen.level(15)
  screen.move(0,20)
  screen.text("clock source: "..params:string("clock_source"))
  screen.move(0,30)
  --screen.text("note: "..params:get("metro_note"))
  screen.text("note: "..metro_note)
  screen.move(0,40)
  screen.text("level: "..metro_amp*100)
  screen.update()
end
