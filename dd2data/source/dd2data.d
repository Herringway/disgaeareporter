module dd2data;

import gamebits.staticdata;

import std.string : split;

mixin StaticData!(ushort, string, "dd2classes.txt", "dd2classes", "Unknown class %04X");
mixin StaticData!(ushort, string, "dd2innocents.txt", "dd2innocents", "Unknown innocent %04X");
mixin StaticData!(ushort, string, "dd2items.txt", "dd2items", "Unknown item %04X");
mixin StaticData!(ushort, string, "dd2skills.txt", "dd2skillNames", "Unknown skill %04X");
mixin StaticData!(ushort, string, "dd2maps.txt", "dd2mapNames", "Unknown map %04X");
mixin StaticData!(ushort, string, "dd2evilities.txt", "dd2evilities", "Unknown evility %04X");

immutable string[] dd2itemRecords = import("dd2itemrecords.txt").split("\n");