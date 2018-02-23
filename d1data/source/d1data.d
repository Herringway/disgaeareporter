module d1data;

import std.string : split;

immutable string[ushort] d1classes;
immutable string[ushort] d1innocents;
immutable string[ushort] d1items;
immutable string[ushort] d1skillNames;
immutable string[ushort] d1mapNames;
immutable string[] d1itemRecords = import("d1itemrecords.txt").split("\n");
shared static this() {
	import std.conv : to;
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : startsWith;
	import std.string : lineSplitter;
	{
		auto str = import("d1classes.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d1classes[bytesequence] = split.front;
		}
	}
	{
		auto str = import("d1innocents.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d1innocents[bytesequence] = split.front;
		}
	}
	{
		auto str = import("d1items.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d1items[bytesequence] = split.front;
		}
	}
	{
		auto str = import("d1skills.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d1skillNames[bytesequence] = split.front;
		}
	}
	{
		auto str = import("d1maps.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort();
			split.popFront();
			d1mapNames[bytesequence] = split.front;
		}
	}
}