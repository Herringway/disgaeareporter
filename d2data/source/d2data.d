module d2data;

import std.string : split;

immutable string[ushort] d2classes;
immutable string[ushort] d2innocents;
immutable string[ushort] d2items;
immutable string[ushort] d2skillNames;
immutable string[ushort] d2mapNames;

static immutable parsedClasses = parseData(import("d2classes.txt"));
static immutable parsedInnocents = parseData(import("d2innocents.txt"));
static immutable parsedItems = parseData(import("d2items.txt"));
static immutable parsedSkills = parseData(import("d2skills.txt"));
static immutable parsedMaps = parseData(import("d2maps.txt"));
immutable string[] d2itemRecords = import("d2itemrecords.txt").split("\n");
shared static this() {
	foreach (tuple; parsedClasses) {
		d2classes[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedInnocents) {
		d2innocents[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedItems) {
		d2items[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedSkills) {
		d2skillNames[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedMaps) {
		d2mapNames[tuple.key] = tuple.value;
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