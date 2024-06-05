module d2data;

import std.string : split;

immutable string[ushort] d2classes = parseData!(string[ushort])(import("d2classes.txt"));
immutable string[ushort] d2innocents = parseData!(string[ushort])(import("d2innocents.txt"));
immutable string[ushort] d2items = parseData!(string[ushort])(import("d2items.txt"));
immutable string[ushort] d2skillNames = parseData!(string[ushort])(import("d2skills.txt"));
immutable string[ushort] d2mapNames = parseData!(string[ushort])(import("d2maps.txt"));

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

immutable string[] d2itemRecords = import("d2itemrecords.txt").split("\n");