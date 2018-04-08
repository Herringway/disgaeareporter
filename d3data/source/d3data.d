module d3data;

import std.string : split;

immutable string[ushort] d3classes;
immutable string[ushort] d3innocents;
immutable string[ushort] d3items;
immutable string[ushort] d3skillNames;
immutable string[ushort] d3mapNames;

static immutable parsedClasses = parseData(import("d3classes.txt"));
static immutable parsedInnocents = parseData(import("d3innocents.txt"));
static immutable parsedItems = parseData(import("d3items.txt"));
static immutable parsedSkills = parseData(import("d3skills.txt"));
static immutable parsedMaps = parseData(import("d3maps.txt"));
immutable string[] d3itemRecords = import("d3itemrecords.txt").split("\n");

shared static this() {
	foreach (tuple; parsedClasses) {
		d3classes[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedInnocents) {
		d3innocents[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedItems) {
		d3items[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedSkills) {
		d3skillNames[tuple.key] = tuple.value;
	}
	foreach (tuple; parsedMaps) {
		d3mapNames[tuple.key] = tuple.value;
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