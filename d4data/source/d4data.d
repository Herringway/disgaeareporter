module d4data;

import std.string : split;

immutable string[ushort] d4classes;
immutable string[ushort] d4innocents;
immutable string[ushort] d4items;
immutable string[ushort] d4skillNames;
immutable string[ushort] d4mapNames;

static immutable parsedClasses = parseData(import("d4classes.txt"));
static immutable parsedInnocents = parseData(import("d4innocents.txt"));
static immutable parsedItems = parseData(import("d4items.txt"));
static immutable parsedSkills = parseData(import("d4skills.txt"));
static immutable parsedMaps = parseData(import("d4maps.txt"));
immutable string[] d4itemRecords = import("d4itemrecords.txt").split("\n");

shared static this() {
	foreach (tuple; parsedClasses) {
		d4classes[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedInnocents) {
		d4innocents[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedItems) {
		d4items[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedSkills) {
		d4skillNames[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedMaps) {
		d4mapNames[tuple.key] = tuple.value;
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