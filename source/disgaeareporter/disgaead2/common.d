module disgaeareporter.disgaead2.common;

import disgaeareporter.common;
import dd2data;


string skillName(ushort id) {
	import std.conv : to;
	if (id in dd2skillNames) {
		return dd2skillNames[id];
	}
	return "Unknown skill "~id.to!string(16);
}

string className(ushort id) {
	import std.conv : to;
	if (id in dd2classes) {
		return dd2classes[id];
	}
	return "Unknown class "~id.to!string(16);
}

string itemName(ushort id) {
	import std.conv : to;
	if (id in dd2items) {
		return dd2items[id];
	}
	return "Unknown item "~id.to!string(16);
}
string mapName(ushort id) {
	import std.conv : to;
	if (id in dd2mapNames) {
		return dd2mapNames[id];
	}
	return "Unknown map "~id.to!string(16);
}
string innocentName(const ushort id) {
	import std.conv : to;
	if (id in dd2innocents) {
		return dd2innocents[id];
	}
	return "Unknown innocent "~id.to!string(16);
}
string evilityName(const ushort id) {
	import std.conv : to;
	if (id in dd2evilityNames) {
		return dd2evilityNames[id];
	}
	return "Unknown evility "~id.to!string(16);
}

align(1)
struct Evility {
	align(1):
	BigEndian!ushort id;

	alias id this;

	string toString() const {
		return evilityName(id);
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