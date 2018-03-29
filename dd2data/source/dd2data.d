module dd2data;

import std.string : split;

immutable string[ushort] dd2classes;
immutable string[ushort] dd2innocents;
immutable string[ushort] dd2items;
immutable string[ushort] dd2skillNames;
immutable string[ushort] dd2mapNames;

static immutable parsedClasses = parseData(import("dd2classes.txt"));
static immutable parsedInnocents = parseData(import("dd2innocents.txt"));
static immutable parsedItems = parseData(import("dd2items.txt"));
static immutable parsedSkills = parseData(import("dd2skills.txt"));
static immutable parsedMaps = parseData(import("dd2maps.txt"));
immutable string[] dd2itemRecords = import("dd2itemrecords.txt").split("\n");
shared static this() {
	foreach (tuple; parsedClasses) {
		dd2classes[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedInnocents) {
		dd2innocents[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedItems) {
		dd2items[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedSkills) {
		dd2skillNames[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedMaps) {
		dd2mapNames[tuple.key] = tuple.value;
	}
}
auto parseData(string data) @safe pure {
	import std.typecons : tuple, Tuple;
	import std.conv : to;
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : startsWith;
	import std.string : lineSplitter;
	Tuple!(ushort, "key", string, "value")[] output;
	foreach (line; data.lineSplitter) {
		if (line.startsWith("#")) {
			continue;
		}
		auto split = line.splitter("\t");
		auto bytesequence = split.front.to!ushort(16);
		split.popFront();
		output ~= tuple!("key","value")(bytesequence, split.front);
	}
	return output;
}