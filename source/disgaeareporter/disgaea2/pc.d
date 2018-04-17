module disgaeareporter.disgaea2.pc;

import disgaeareporter.disgaea2.common;

import disgaeareporter.common;

import std.range : isOutputRange;
import std.traits : isSomeChar;
import std.typecons : BitFlags;

align(1)
struct Innocent {
	align(1):
	uint level;
	ubyte type;
	ubyte uniquer;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level > 10000 ? level-10000 : level, level > 10000 ? "+" : "", type.innocentName);
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
}
static assert(Innocent.sizeof == 8);
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

static assert(Item.sizeof == 0x180);

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[4] equipment;
	ZeroString!64 name;
	ZeroString!64 className;
	@Unknown ubyte[260] unknown1;
	Skills!(96, "disgaea2", false) skills;
	@Unknown ubyte[508] unknown2;
	Stats stats;
	@Unknown ubyte[64] unknown3;
	uint mana;
	@Unknown ubyte[24] unknown4;
	ubyte[8] weaponMasteryLevel;
	ubyte[8] weaponMasteryRate;
	@Unknown ubyte[8] unknown5;
	BaseCharacterStats baseStats;
	@Unknown ubyte[8] unknown6;
	ushort level;
	@Unknown ubyte[16] unknown7;
	Resistance baseResist;
	Resistance resist;
	MiscStats miscStats;
	@Unknown ubyte[534] unknown8;
}
static assert(Character.sizeof == 0xF00);
static assert(Character.skills.offsetof == 0x78C);
static assert(Character.stats.offsetof == 0xC28);
static assert(Character.baseStats.offsetof == 0xCBC);
static assert(Character.baseResist.offsetof == 0xCDE);

align(1)
struct Senator {
	align(1):
	ushort level;
	ushort classID;
	uint attendance;
	@Unknown ubyte[6] unknown;
	ZeroString!64 name;
	byte favour;
	@Unknown ubyte[17] unknown2;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"%s (Level %s %s)\n\t"(name, level, classID.className);
		sink.formattedWrite!"%s (%s)\n"(favour.favourString, favour);
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

static assert(Senator.sizeof == 0x60);

align(1)
struct D2PC {
	align(1):
	@Unknown ubyte[8] unknown;
	Playtime!false playtime;
	@Unknown ubyte[963] unknown2;
	ulong totalHL;
	@Unknown ubyte[2336] unknown3;
	Character[128] _characters;
	Senator[64] _senators;
	@Unknown ubyte[5632] unknown4;
	Item[24] _bagItems;
	Item[512] _warehouseItems;
	@Unknown ubyte[60] unknown5;
	ushort charCount;
	@Unknown ubyte[526] unknown6;
	BitFlags!Rarity[1680] itemRecords;
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
		import d2data : d2itemRecords;
		return d2itemRecords[record];
	}
	enum itemRecordAlignment = 80;
}
static assert(D2PC.totalHL.offsetof == 0x3D0);
static assert(D2PC._characters.offsetof == 0xCF8);
static assert(D2PC._senators.offsetof == 0x78CF8);
static assert(D2PC._bagItems.offsetof == 0x7BAF8);
static assert(D2PC.charCount.offsetof == 0xADF34);


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
