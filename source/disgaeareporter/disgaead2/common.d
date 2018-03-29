module disgaeareporter.disgaead2.common;


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