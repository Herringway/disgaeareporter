module disgaeareporter.disgaea3.common;

import d3data;


string skillName(ushort id) {
	import std.conv : to;
	if (id in d3skillNames) {
		return d3skillNames[id];
	}
	return "Unknown skill "~id.to!string(16);
}

string className(ushort id) {
	import std.conv : to;
	if (id in d3classes) {
		return d3classes[id];
	}
	return "Unknown class "~id.to!string(16);
}

string itemName(ushort id) {
	import std.conv : to;
	if (id in d3items) {
		return d3items[id];
	}
	return "Unknown item "~id.to!string(16);
}
string mapName(ushort id) {
	import std.conv : to;
	if (id in d3mapNames) {
		return d3mapNames[id];
	}
	return "Unknown map "~id.to!string(16);
}
string innocentName(const ushort id) {
	import std.conv : to;
	if (id in d3innocents) {
		return d3innocents[id];
	}
	return "Unknown innocent "~id.to!string(16);
}