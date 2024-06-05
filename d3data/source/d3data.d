module d3data;

import std.string : split;

immutable string[ushort] d3classes = parseData!(string[ushort])(import("d3classes.txt"));
immutable string[ushort] d3innocents = parseData!(string[ushort])(import("d3innocents.txt"));
immutable string[ushort] d3items = parseData!(string[ushort])(import("d3items.txt"));
immutable string[ushort] d3skillNames = parseData!(string[ushort])(import("d3skills.txt"));
immutable string[ushort] d3mapNames = parseData!(string[ushort])(import("d3maps.txt"));

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

immutable string[] d3itemRecords = import("d3itemrecords.txt").split("\n");