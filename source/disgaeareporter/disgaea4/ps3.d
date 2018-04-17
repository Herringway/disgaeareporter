module disgaeareporter.disgaea4.ps3;

import disgaeareporter.common;
import disgaeareporter.disgaea4.common;

import std.range : isOutputRange;

align(1)
struct Innocent {
	align(1):
	BigEndian!uint level;
	BigEndian!ushort type;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level, /+level > 10000 ? "+" : ""+/ "", type.innocentName);
	}
	bool isValid() const {
		return type != 0;
	}
}

align(1)
struct Item {
	align(1):
	@Unknown ubyte[4] unknown1;
	Innocent[8] innocents;
	@Unknown ubyte[140] unknown2;
	BigEndian!ushort id;
	@Unknown ubyte[30] unknown3;
	ubyte rarity;
	@Unknown ubyte[30] unknown4;
	ZeroString!64 name;
	@Unknown ubyte[0x61] unknown5;
	bool isValid() const {
		return id != 0;
	}
}
static assert(Item.sizeof == 0x1B0);
static assert(Item.rarity.offsetof == 0xF0);

align(1)
struct Character {
	align(1):
	BigEndian!ulong exp;
	Item[4] equipment;
	ZeroString!48 name;
	ZeroString!48 className;
	@Unknown ubyte[1128] unknown1;
	BigEndian!ulong currentHP;
	BigEndian!ulong currentSP;
	LongStats!true stats;
	LongStats!true realStats;
	@Unknown ubyte[912] unknown2;
	BigEndian!ushort level;
	@Unknown ubyte[12854] unknown3;
}

static assert(Character.sizeof == 0x41E8);
static assert(Character.currentHP.offsetof == 0xB90);
static assert(Character.level.offsetof == 0xFB0);

align(1)
struct D4PS3 {
	align(1):
	@Unknown ubyte[8] unknown1;
	Playtime!true playtime;
	ZeroString!34 fileName;
	@Unknown ubyte[5041] unknown2;
	Character[64] _characters;
	@Unknown ubyte[336176] unknown3;
	Item[32] _bagItems;
	Item[512] _warehouseItems;
	@Unknown ubyte[34828] unknown4;
	BigEndian!ushort charCount;

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
}

static assert(D4PS3._characters.offsetof == 0x13E0);
static assert(D4PS3._bagItems.offsetof == 0x15AF10);
static assert(D4PS3.charCount.offsetof == 0x19CD1C);