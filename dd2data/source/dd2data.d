module dd2data;

import std.string : split;

immutable string[ushort] dd2classes = parseData!(string[ushort])(import("dd2classes.txt"));
immutable string[ushort] dd2innocents = parseData!(string[ushort])(import("dd2innocents.txt"));
immutable string[ushort] dd2items = parseData!(string[ushort])(import("dd2items.txt"));
immutable string[ushort] dd2skillNames = parseData!(string[ushort])(import("dd2skills.txt"));
immutable string[ushort] dd2mapNames = parseData!(string[ushort])(import("dd2maps.txt"));
immutable string[ushort] dd2evilities = parseData!(string[ushort])(import("dd2evilities.txt"));

auto parseData(T)(string data) @safe pure {
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : startsWith;
	import std.array : empty;
	import std.conv : to;
	import std.string : lineSplitter, strip;
	import std.typecons : tuple, Tuple;
	T output;
	foreach (line; data.lineSplitter) {
		if (line.startsWith("#") || line.strip().empty) {
			continue;
		}
		auto split = line.splitter("\t");
		auto bytesequence = split.front.to!(typeof(output.keys[0]))(16);
		split.popFront();
		output[bytesequence] = split.front;
	}
	return output;
}
immutable string[] dd2itemRecords = import("dd2itemrecords.txt").split("\n");