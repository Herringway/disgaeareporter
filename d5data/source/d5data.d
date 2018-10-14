module d5data;

import simap;

import std.string : split;

mixin StaticData!(ushort, string, "d5classes.txt", "d5classes", "Unknown class %04X");
mixin StaticData!(ushort, string, "d5innocents.txt", "d5innocents", "Unknown innocent %04X");
mixin StaticData!(ushort, string, "d5items.txt", "d5items", "Unknown item %04X");
mixin StaticData!(ushort, string, "d5skills.txt", "d5skillNames", "Unknown skill %04X");
mixin StaticData!(ushort, string, "d5maps.txt", "d5mapNames", "Unknown map %04X");

immutable string[] d5itemRecords = import("d5itemrecords.txt").split("\n");