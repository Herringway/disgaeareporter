module d2data;

import std.string : split;

immutable string[ushort] d2classes;
immutable string[ushort] d2innocents;
immutable string[ushort] d2items;
immutable string[ushort] d2skillNames;
immutable string[ushort] d2mapNames;
immutable string[] d2itemRecords = import("itemrecords.txt").split("\n");
shared static this() {
	import std.conv : to;
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : startsWith;
	import std.string : lineSplitter;
	{
		auto str = import("classes.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d2classes[bytesequence] = split.front;
		}
	}
	{
		auto str = import("innocents.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d2innocents[bytesequence] = split.front;
		}
	}
	{
		auto str = import("items.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d2items[bytesequence] = split.front;
		}
	}
	{
		auto str = import("skills.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort(16);
			split.popFront();
			d2skillNames[bytesequence] = split.front;
		}
	}
	{
		auto str = import("maps.txt");
		foreach (line; str.lineSplitter) {
			if (line.startsWith("#")) {
				continue;
			}
			auto split = line.splitter("\t");
			auto bytesequence = split.front.to!ushort();
			split.popFront();
			d2mapNames[bytesequence] = split.front;
		}
	}
}