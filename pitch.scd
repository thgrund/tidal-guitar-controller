~notes=List.new(5);
c = Bus.control(s, 1);
e = Bus.control(s, 1);
o = NetAddr.new("127.0.0.1", 6010);

(
SynthDef("pitchFollow1",{ |busFreq, busAmp|
    var in, amp, freq, hasFreq, out;
    in = SoundIn.ar([16]);
    amp = Amplitude.kr(in, 0.05, 0.05);
    //# freq, hasFreq = Tartini.kr(in, 0.93,1024,512,512);
    # freq = Tartini.kr(in);

    Out.kr(busFreq, freq);
    Out.kr(busAmp, amp)
}).add;

r = Routine({
	inf.do({
		var freq, note, amp, sortedList;
		freq = c.getSynchronous;
		amp = e.getSynchronous;
		note = freq.cpsmidi.round;

		if (amp > 0.001, {
			// the lowest note of my guitar is the low D
			// Ignore lower notes because this is just noise
			if (note > 37, {
				if (~notes.size < 5, {
					~notes.add(note);
				});

				if (~notes.size == 5, {
					~notes.removeAt(0);
					~notes.add(note);

					sortedList = List.copyInstance(~notes);

					~lastNote = sortedList.sort[2].midinote;
					o.sendMsg("/ctrl", "notes", sortedList.sort[2]-60);

					//[sortedList.sort[2]-60].postln;
				});
			});
		});

		0.05.wait;
	});
});

)

b = Synth(\pitchFollow1, [\busFreq, c, \busAmp, e]);
r.play;


(
var peersBox,
font = Font.default.copy.size_(32),
boldFont = font.boldVariant,
controller, task,
freq = c.getSynchronous,
text = StaticText().font_(font).string_("Detected Note:").stringColor_(Color.newHex("#9ba3b2"));

~win = Window("", Rect(170, 144, 908, 32), true, false).front;

~win.background = "#1e2127";

~win.layout = HLayout(
    text,
    peersBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(300),
);

[peersBox].do { |view| view.enabled_(false) };

peersBox.string = ~lastNote;

fork {
    loop {
        0.05.wait;
        defer {
			peersBox.string = ~lastNote;
        }
    }
};

)

~win.close
