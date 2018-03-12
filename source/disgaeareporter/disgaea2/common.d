module disgaeareporter.disgaea2.common;

import disgaeareporter.disgaea2;

import std.file;

import d2data;

static immutable d2SteamID = "495280";

align(1)
struct BaseItemStats {
	align(1):
	ushort hp;
	ushort sp;
	ushort attack;
	ushort defense;
	ushort intelligence;
	ushort speed;
	ushort hit;
	ushort resistance;
}
static assert(BaseItemStats.sizeof == 16);

string skillName(ushort id) {
	import std.conv : to;
	if (id in d2skillNames) {
		return d2skillNames[id];
	}
	return "Unknown skill "~id.to!string(16);
}

string className(ushort id) {
	import std.conv : to;
	if (id in d2classes) {
		return d2classes[id];
	}
	return "Unknown class "~id.to!string(16);
}

string itemName(ushort id) {
	import std.conv : to;
	if (id in d2items) {
		return d2items[id];
	}
	return "Unknown item "~id.to!string(16);
}
string mapName(ushort id) {
	import std.conv : to;
	if (id in d2mapNames) {
		return d2mapNames[id];
	}
	return "Unknown map "~id.to!string(16);
}
string innocentName(const ushort id) {
	import std.conv : to;
	if (id in d2innocents) {
		return d2innocents[id];
	}
	return "Unknown innocent "~id.to!string(16);
}