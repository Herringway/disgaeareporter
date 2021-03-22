module disgaeareporter.disgaea3.ps3;

import disgaeareporter.common;
import disgaeareporter.disgaea3.common;

import reversineer : Offset, VerifyOffsets;

import std.range : isOutputRange;

align(1)
struct Item {
	align(1):
	Innocent[8] innocents;
	@Unknown ubyte[8] unknown1;
	@Offset(0x48) LongStats stats;
	LongStats realStats;
	ushort nameID;
	@Unknown ubyte[30] unknown2;
	@Offset(0xE8) ubyte rarity;
	@Unknown ubyte[30] unknown3;
	SJISString!80 name;
	@Unknown ubyte[1] unknown4;

	bool isValid() const {
		return nameID != 0;
	}
	string level() const {
		return "?";
	}
}
mixin VerifyOffsets!(Item, 344);

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[4] equipment;
	@Offset(0x568) SJISString!40 name;
	SJISString!40 className;
	@Unknown ubyte[1032] unknown1;
	ulong currentHP;
	ulong currentSP;
	@Offset(0x9D0) LongStats stats;
	LongStats realStats;
	@Unknown ubyte[92] unknown2;
	@Offset(0xAAC) ushort level;
	@Unknown ubyte[16] unknown3;
	@Offset(0xABE) Resistance baseResist;
	Resistance resist;
	@Unknown ubyte[6676] unknown4;
}

mixin VerifyOffsets!(Character, 9432);


align(1)
struct Innocent {
	align(1):
	uint level;
	ushort type;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"Lv%s%s %s"(level, isSubdued ? "+" : "", name);
	}
	bool isValid() const {
		return type != 0;
	}
	bool isSubdued() const {
		return false;
	}
	string name() const {
		return d3innocents(type);
	}
}

unittest {
	import std.outbuffer;
	Innocent().toString(new OutBuffer);
}

align(1)
struct D3PS3 {
	align(1):
	@Unknown ubyte[8] unknown1;
	Playtime playtime;
	SJISString!34 fileName;
	@Unknown ubyte[3225] unknown2;
	@Offset(0xCC8) Character[64] _characters;
	@Unknown ubyte[47712] unknown3;
	@Offset(0x9FD28) Item[32] _bagItems;
	Item[512] _warehouseItems;
	@Unknown ubyte[36780] unknown4;
	@Offset(0xD67D4) ushort charCount;
	@Unknown ubyte[0x8F0BA] unknownD67D6;
	auto bagItems() const {
		import std.algorithm : filter;
		return _bagItems[].filter!(x => x.isValid);
	}
	auto warehouseItems() const {
		import std.algorithm : filter;
		return _warehouseItems[].filter!(x => x.isValid);
	}
	auto characters() const {
		return _characters[0..charCount];
	}
}

mixin VerifyOffsets!(D3PS3, 0x165890);

unittest {
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	auto data = loadData!(D3PS3, true)(getRawData(cast(immutable(ubyte)[])import("d3ps3-raw.DAT"), Platforms.ps3));
	assert(data.fileName == "Mao");

	with(data._characters[0]) {
		with(equipment[0]) {
			assert(name == "Toy Blade");
			assert(stats.attack == 9);
			with(innocents[0]) {
				assert(type == 3);
				assert(level == 2);
			}
			assert(rarity == 141);
		}
		assert(name == "Mao");
		assert(exp == 15);
		assert(level == 2);
		assert(stats.hp == 39);
		assert(stats.attack == 36);
		assert(stats.resistance == 15);
		assert(stats.speed == 14);
		assert(resist.fire == -25);
		assert(resist.ice == 50);
	}
}
