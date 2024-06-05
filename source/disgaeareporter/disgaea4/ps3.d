module disgaeareporter.disgaea4.ps3;

import disgaeareporter.common;
import disgaeareporter.disgaea4.common;

import reversineer : Offset, VerifyOffsets;
import std.range : isOutputRange;

align(1)
struct Innocent {
	align(1):
	uint level;
	ushort type;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level, isSubdued ? "+" : "", name);
	}
	bool isValid() const {
		return type != 0;
	}
	string name() const {
		return d4innocents.get(type, format!"Unknown innocent %04X"(type));
	}
	bool isSubdued() const {
		return false;
	}
}

align(1)
struct Item {
	align(1):
	@Unknown ubyte[4] unknown1;
	Innocent[8] innocents;
	@Unknown ubyte[140] unknown2;
	ushort id;
	@Unknown ubyte[30] unknown3;
	@Offset(0xF0) ubyte rarity;
	@Unknown ubyte[30] unknown4;
	ZeroString!64 name;
	@Unknown ubyte[0x61] unknown5;
	bool isValid() const {
		return id != 0;
	}
	string level() const {
		return "?";
	}
}
mixin VerifyOffsets!(Item, 0x1B0);

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[4] equipment;
	ZeroString!48 name;
	ZeroString!48 className;
	@Unknown ubyte[1128] unknown1;
	@Offset(0xB90) ulong currentHP;
	ulong currentSP;
	LongStats stats;
	LongStats realStats;
	@Unknown ubyte[912] unknown2;
	@Offset(0xFB0) ushort level;
	@Unknown ubyte[12854] unknown3;
}

mixin VerifyOffsets!(Character, 0x41E8);

align(1)
struct D4PS3 {
	align(1):
	@Unknown ubyte[8] unknown1;
	Playtime playtime;
	ZeroString!34 fileName;
	@Unknown ubyte[5041] unknown2;
	@Offset(0x13E0) Character[64] _characters;
	@Unknown ubyte[336176] unknown3;
	@Offset(0x15AF10) Item[32] _bagItems;
	Item[512] _warehouseItems;
	@Unknown ubyte[34828] unknown4;
	@Offset(0x19CD1C) ushort charCount;
	@Unknown ubyte[0x3D2A32] unknown19CD1E;

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

mixin VerifyOffsets!(D4PS3, 0x56F750);
