module d4data;

import std.string : split;

immutable string[ushort] d4classes = parseData!(string[ushort])(import("d4classes.txt"));
immutable string[ushort] d4innocents = parseData!(string[ushort])(import("d4innocents.txt"));
immutable string[ushort] d4items = parseData!(string[ushort])(import("d4items.txt"));
immutable string[ushort] d4skillNames = parseData!(string[ushort])(import("d4skills.txt"));
immutable string[ushort] d4mapNames = parseData!(string[ushort])(import("d4maps.txt"));

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

immutable string[] d4itemRecords = import("d4itemrecords.txt").split("\n");