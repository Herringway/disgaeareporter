module d4data;

import gamebits.staticdata;

import std.string : split;

mixin StaticData!(ushort, string, "d4classes.txt", "d4classes", "Unknown class %04X");
mixin StaticData!(ushort, string, "d4innocents.txt", "d4innocents", "Unknown innocent %04X");
mixin StaticData!(ushort, string, "d4items.txt", "d4items", "Unknown item %04X");
mixin StaticData!(ushort, string, "d4skills.txt", "d4skillNames", "Unknown skill %04X");
mixin StaticData!(ushort, string, "d4maps.txt", "d4mapNames", "Unknown map %04X");

immutable string[] d4itemRecords = import("d4itemrecords.txt").split("\n");