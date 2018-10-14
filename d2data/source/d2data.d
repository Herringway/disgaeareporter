module d2data;

import simap;

import std.string : split;

mixin StaticData!(ushort, string, "d2classes.txt", "d2classes", "Unknown class %04X");
mixin StaticData!(ushort, string, "d2innocents.txt", "d2innocents", "Unknown innocent %04X");
mixin StaticData!(ushort, string, "d2items.txt", "d2items", "Unknown item %04X");
mixin StaticData!(ushort, string, "d2skills.txt", "d2skillNames", "Unknown skill %04X");
mixin StaticData!(ushort, string, "d2maps.txt", "d2mapNames", "Unknown map %04X");

immutable string[] d2itemRecords = import("d2itemrecords.txt").split("\n");