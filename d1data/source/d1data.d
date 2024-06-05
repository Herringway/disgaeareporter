module d1data;

import std.string : split;

immutable string[ushort] d1classes = parseData!(string[ushort])(import("d1classes.txt"));
immutable string[ushort] d1innocents = parseData!(string[ushort])(import("d1innocents.txt"));
immutable string[ushort] d1items = parseData!(string[ushort])(import("d1items.txt"));
immutable string[ushort] d1skillNames = parseData!(string[ushort])(import("d1skills.txt"));
immutable string[ushort] d1mapNames = parseData!(string[ushort])(import("d1maps.txt"));

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

immutable string[] d1itemRecords = import("d1itemrecords.txt").split("\n");