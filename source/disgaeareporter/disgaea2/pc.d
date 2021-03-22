module disgaeareporter.disgaea2.pc;

import disgaeareporter.disgaea2.common;

import disgaeareporter.common;

import reversineer : Offset, VerifyOffsets;
import std.range : isOutputRange;
import std.traits : isSomeChar;
import std.typecons : BitFlags;

align(1)
struct Innocent {
	align(1):
	uint _level;
	ubyte type;
	ubyte uniquer;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level, isSubdued ? "+" : "", name);
		debug (unknowns) {
			sink.formattedWrite!" - Unknown data:"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
	bool isValid() const {
		return type != 0;
	}
	uint level() const {
		return _level > 10000 ? cast(ushort)(_level - 10000) : _level;
	}
	bool isSubdued() const {
		return _level > 10000;
	}
	string name() const {
		return d2innocents(type);
	}
}
mixin VerifyOffsets!(Innocent, 8);
private void funcii() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Innocent().toString(buf);
}

align(1)
struct Item {
	align(1):
	Innocent[8] innocents;
	ulong price;
	Stats stats;
	Stats baseStats;
	@Unknown ubyte[4] unknown;
	ubyte level;
	@Unknown ubyte[13] unknown2;
	ubyte rarity;
	@Unknown ubyte[29] unknown3;
	ZeroString!32 name;
	@Unknown ubyte[168] unknown4;
	bool isValid() const {
		return (unknown2 != unknown2.init);
	}
}

mixin VerifyOffsets!(Item, 0x180);

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[4] equipment;
	ZeroString!64 name;
	ZeroString!64 className;
	@Unknown ubyte[260] unknown1;
	@Offset(0x78C) Skills!(96, d2skillNames) skills;
	@Unknown ubyte[508] unknown2;
	@Offset(0xC28) Stats stats;
	@Unknown ubyte[64] unknown3;
	uint mana;
	@Unknown ubyte[24] unknown4;
	EquipmentMastery equipmentMastery;
	@Unknown ubyte[8] unknown5;
	@Offset(0xCBC) BaseCharacterStats baseStats;
	@Unknown ubyte[8] unknown6;
	ushort level;
	@Unknown ubyte[16] unknown7;
	@Offset(0xCDE) Resistance baseResist;
	Resistance resist;
	MiscStats miscStats;
	@Unknown ubyte[534] unknown8;
}
mixin VerifyOffsets!(Character, 0xF00);

align(1)
struct Senator {
	align(1):
	ushort level;
	ushort classID;
	uint attendance;
	@Unknown ubyte[6] unknown;
	ZeroString!64 name;
	Favour favour;
	@Unknown ubyte[17] unknown2;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"%s (Level %s %s)\n\t"(name, level, d2classes(classID));
		sink.formattedWrite!"%s\n"(favour);
		//if (timesKilled > 0) {
		//	sink.formattedWrite!"\tKilled %s time%s\n"(timesKilled, timesKilled > 1 ? "s" : "");
		//}
		debug (unknowns) {
			sink.formattedWrite!"\tUnknown data:"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
}

mixin VerifyOffsets!(Senator, 0x60);

align(1)
struct D2PC {
	align(1):
	@Unknown ubyte[8] unknown;
	Playtime playtime;
	@Unknown ubyte[963] unknown2;
	@Offset(0x3D0) ulong totalHL;
	@Unknown ubyte[2336] unknown3;
	@Offset(0xCF8) Character[128] _characters;
	@Offset(0x78CF8) Senator[64] _senators;
	@Unknown ubyte[5632] unknown4;
	@Offset(0x7BAF8) Item[24] _bagItems;
	Item[512] _warehouseItems;
	@Unknown ubyte[60] unknown5;
	@Offset(0xADF34) ushort charCount;
	@Unknown ubyte[526] unknown6;
	BitFlags!Rarity[1680] itemRecords;
	@Unknown ubyte[0xAFEB] unknown7;
	auto characters() const {
		return _characters[0..charCount];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _bagItems[].filter!(x => x.isValid);
	}
	auto warehouseItems() const {
		import std.algorithm : filter;
		return _warehouseItems[].filter!(x => x.isValid);
	}
	auto senators() const {
		return _senators[];
	}
	static string itemRecordName(size_t record) {
		return d2itemRecords[record];
	}
	enum itemRecordAlignment = 80;
}
mixin VerifyOffsets!(D2PC, 0xB97BF);


//PC
unittest {
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	auto data = loadData!D2PC(getRawData(cast(immutable(ubyte)[])import("d2pc-SAVE000.DAT"), Platforms.pc));
	assert(data.characters.length == 5);

	with(data.characters[0]) {
		assert(name == "Adell");
		assert(level == 1);
	}

	with(data._bagItems[0]) {
		assert(name == "Mint Gum");
		assert(rarity == 185);
	}
}
