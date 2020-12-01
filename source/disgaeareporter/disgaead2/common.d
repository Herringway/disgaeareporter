module disgaeareporter.disgaead2.common;

import disgaeareporter.common;
public import dd2data;

align(1)
struct Evility {
	align(1):
	ushort id;

	alias id this;

	string toString() const {
		return dd2evilities(id);
	}

	bool isValid() const {
		return id != 0;
	}
}

static immutable trainingTypes = [
	"Tough Guy Training",
	"Demon Psychology",
	"Kata Practice",
	"Puncture Training",
	"Cram Session",
	"Sealing Circles",
	"Target Practice",
	"Super Treadmill",
	"Weapon Maintenance",
	"Punching Bags",
	"Book Stacks",
	"Love Potion Practice",
	"Weapon Assembly",
	"Waterfall Training",
	"Battle Royale",
];
string trainingName(const ubyte id) {
	import std.conv : text;
	if (id == 0xFF) {
		return "None";
	} else if (id < trainingTypes.length) {
		return trainingTypes[id];
	} else {
		return "Unknown training type "~id.text;
	}
}