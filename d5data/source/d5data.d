module d5data;

import std.string : split;

immutable string[ushort] d5classes = parseData!(string[ushort])(import("d5classes.txt"));
immutable string[ushort] d5innocents = parseData!(string[ushort])(import("d5innocents.txt"));
immutable string[ushort] d5items = parseData!(string[ushort])(import("d5items.txt"));
immutable string[ushort] d5skillNames = parseData!(string[ushort])(import("d5skills.txt"));
immutable string[ushort] d5mapNames = parseData!(string[ushort])(import("d5maps.txt"));
immutable string[ushort] d5evilities = parseData!(string[ushort])(import("d5evilities.txt"));

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

immutable string[] d5itemRecords = import("d5itemrecords.txt").split("\n");

immutable ubyte[256] d5PCTable = genTable();

ubyte[256] genTable() {
	ubyte[256] output;
	foreach (ubyte i; 0..256) {
		ubyte b = cast(ubyte)(((i&0xF0)>>4) | ((0xF - (i&0xF))<<4));
		output[b] = i;
	}
	return output;
}
