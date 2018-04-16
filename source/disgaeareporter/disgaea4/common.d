module disgaeareporter.disgaea4.common;

import d4data;


string skillName(ushort id) {
	import std.conv : to;
	if (id in d4skillNames) {
		return d4skillNames[id];
	}
	return "Unknown skill "~id.to!string(16);
}

string className(ushort id) {
	import std.conv : to;
	if (id in d4classes) {
		return d4classes[id];
	}
	return "Unknown class "~id.to!string(16);
}

string itemName(ushort id) {
	import std.conv : to;
	if (id in d4items) {
		return d4items[id];
	}
	return "Unknown item "~id.to!string(16);
}
string mapName(ushort id) {
	import std.conv : to;
	if (id in d4mapNames) {
		return d4mapNames[id];
	}
	return "Unknown map "~id.to!string(16);
}
string innocentName(const ushort id) {
	import std.conv : to;
	if (id in d4innocents) {
		return d4innocents[id];
	}
	return "Unknown innocent "~id.to!string(16);
}