module d1data;

import gamebits.staticdata;

import std.string : split;

mixin StaticData!(ushort, string, "d1classes.txt", "d1classes", "Unknown class %04X");
mixin StaticData!(ushort, string, "d1innocents.txt", "d1innocents", "Unknown innocent %04X");
mixin StaticData!(ushort, string, "d1items.txt", "d1items", "Unknown item %04X");
mixin StaticData!(ushort, string, "d1skills.txt", "d1skillNames", "Unknown skill %04X");
mixin StaticData!(ushort, string, "d1maps.txt", "d1mapNames", "Unknown map %04X");

immutable string[] d1itemRecords = import("d1itemrecords.txt").split("\n");