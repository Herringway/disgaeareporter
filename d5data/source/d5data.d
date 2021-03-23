module d5data;

import simap;

import std.string : split;

mixin StaticData!(ushort, string, "d5classes.txt", "d5classes", "Unknown class %04X");
mixin StaticData!(ushort, string, "d5innocents.txt", "d5innocents", "Unknown innocent %04X");
mixin StaticData!(ushort, string, "d5items.txt", "d5items", "Unknown item %04X");
mixin StaticData!(ushort, string, "d5skills.txt", "d5skillNames", "Unknown skill %04X");
mixin StaticData!(ushort, string, "d5maps.txt", "d5mapNames", "Unknown map %04X");
mixin StaticData!(ushort, string, "d5evilities.txt", "d5evilities", "Unknown evility %04X");

immutable string[] d5itemRecords = import("d5itemrecords.txt").split("\n");

immutable ubyte[256] d5PCTable = genTable();

ubyte[256] genTable() {
	ubyte[256] output;
	foreach (ubyte i; 0..256) {
		ubyte b = cast(ubyte)(((i&0xF0)>>4) | ((0xF - (i&0xF))<<4));
		output[b] = i;
	}
	return output;
}
