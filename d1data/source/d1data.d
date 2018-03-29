module d1data;

import std.string : split;

immutable string[ushort] d1classes;
immutable string[ushort] d1innocents;
immutable string[ushort] d1items;
immutable string[ushort] d1skillNames;
immutable string[ushort] d1mapNames;

static immutable parsedClasses = parseData(import("d1classes.txt"));
static immutable parsedInnocents = parseData(import("d1innocents.txt"));
static immutable parsedItems = parseData(import("d1items.txt"));
static immutable parsedSkills = parseData(import("d1skills.txt"));
static immutable parsedMaps = parseData(import("d1maps.txt"));
immutable string[] d1itemRecords = import("d1itemrecords.txt").split("\n");

shared static this() {
	foreach (tuple; parsedClasses) {
		d1classes[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedInnocents) {
		d1innocents[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedItems) {
		d1items[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedSkills) {
		d1skillNames[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedMaps) {
		d1mapNames[tuple.key] = tuple.value;
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