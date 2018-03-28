module dd2data;

import std.string : split;

immutable string[ushort] dd2classes;
immutable string[ushort] dd2innocents;
immutable string[ushort] dd2items;
immutable string[ushort] dd2skillNames;
immutable string[ushort] dd2mapNames;
immutable string[] dd2itemRecords = import("dd2itemrecords.txt").split("\n");
shared static this() {
	import std.conv : to;
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : startsWith;
	import std.string : lineSplitter;
	{
		auto str = import("dd2classes.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			dd2classes[bytesequence] = split.front;
		}
	}
	{
		auto str = import("dd2innocents.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			dd2innocents[bytesequence] = split.front;
		}
	}
	{
		auto str = import("dd2items.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			dd2items[bytesequence] = split.front;
		}
	}
	{
		auto str = import("dd2skills.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			dd2skillNames[bytesequence] = split.front;
		}
	}
	{
		auto str = import("dd2maps.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort();
			split.popFront();
			dd2mapNames[bytesequence] = split.front;
		}
	}
}