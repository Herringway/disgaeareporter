module d3data;

import gamebits.staticdata;

import std.string : split;

mixin StaticData!(ushort, string, "d3classes.txt", "d3classes", "Unknown class %04X");
mixin StaticData!(ushort, string, "d3innocents.txt", "d3innocents", "Unknown innocent %04X");
mixin StaticData!(ushort, string, "d3items.txt", "d3items", "Unknown item %04X");
mixin StaticData!(ushort, string, "d3skills.txt", "d3skillNames", "Unknown skill %04X");
mixin StaticData!(ushort, string, "d3maps.txt", "d3mapNames", "Unknown map %04X");

immutable string[] d3itemRecords = import("d3itemrecords.txt").split("\n");