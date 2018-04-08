module d5data;

import std.string : split;

immutable string[ushort] d5classes;
immutable string[ushort] d5innocents;
immutable string[ushort] d5items;
immutable string[ushort] d5skillNames;
immutable string[ushort] d5mapNames;

static immutable parsedClasses = parseData(import("d5classes.txt"));
static immutable parsedInnocents = parseData(import("d5innocents.txt"));
static immutable parsedItems = parseData(import("d5items.txt"));
static immutable parsedSkills = parseData(import("d5skills.txt"));
static immutable parsedMaps = parseData(import("d5maps.txt"));
immutable string[] d5itemRecords = import("d5itemrecords.txt").split("\n");

shared static this() {
	foreach (tuple; parsedClasses) {
		d5classes[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedInnocents) {
		d5innocents[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedItems) {
		d5items[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedSkills) {
		d5skillNames[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedMaps) {
		d5mapNames[tuple.key] = tuple.value;
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