module disgaeareporter.disgaea5.common;

static immutable d5SteamID = "803600";

import d5data;


string skillName(ushort id) {
	import std.conv : to;
	if (id in d5skillNames) {
		return d5skillNames[id];
	}
	return "Unknown skill "~id.to!string(16);
}

string className(ushort id) {
	import std.conv : to;
	if (id in d5classes) {
		return d5classes[id];
	}
	return "Unknown class "~id.to!string(16);
}

string itemName(ushort id) {
	import std.conv : to;
	if (id in d5items) {
		return d5items[id];
	}
	return "Unknown item "~id.to!string(16);
}
string mapName(ushort id) {
	import std.conv : to;
	if (id in d5mapNames) {
		return d5mapNames[id];
	}
	return "Unknown map "~id.to!string(16);
}
string innocentName(const ushort id) {
	import std.conv : to;
	if (id in d5innocents) {
		return d5innocents[id];
	}
	return "Unknown innocent "~id.to!string(16);
}