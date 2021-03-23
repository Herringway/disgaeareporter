module disgaeareporter.disgaea5.pc;

import disgaeareporter.common;
import disgaeareporter.disgaea5.common;

import reversineer : Offset, VerifyOffsets;
import std.range;

align(1)
struct Innocent {
	align(1):
	@Unknown ubyte[4] unknown1;
	ushort type;
	@Unknown ubyte[2] unknown2;
	uint level;
	@Unknown ubyte[8] unknown3;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level, isSubdued ? "+" : "", name);
	}
	bool isValid() const {
		return type != 0;
	}
	bool isSubdued() const {
		return false;
	}
	string name() const {
		return d5innocents(type);
	}
}

align(1)
struct Item {
	align(1):
	Innocent[8] innocents;
	@Unknown ubyte[0x88] unknown1;
	@Offset(0x128) ushort itemID;
	ushort unknown;
	ushort level;
	@Unknown ubyte[0x17] unknown2;
	ubyte rarity;
	@Unknown ubyte[0x112] unknown3;

	bool isValid() const {
		return itemID != 0;
	}
	string name() const {
		return d5items(itemID);
	}
}

mixin VerifyOffsets!(Item, 0x258);

align(1)
struct Skill5 {
	align(1):
	uint unknown;
	uint id;
	ubyte[1] unknown2;
	ubyte level;
	ubyte boosts;
	ubyte[5] unknown3;
	bool isValid() const {
		return id != 0;
	}
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		if (level == 255) {
			sink.put("Learning");
		} else {
			sink.formattedWrite!"Lv%s + %s"(level, boosts);
		}
		sink.formattedWrite!" %s (%s EXP)"(__ctfe ? "" : d5skillNames(cast(ushort)id), 0);
	}
	void __toString() {
		import std.array : appender;
		auto a = appender!(char[]);
		toString(a);
	}
}

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[5] equipment;
	@Offset(0xBC0) ZeroString!0x34 name;
	ZeroString!0x34 className;
	@Unknown ubyte[144] unknown_;
	@Offset(0xCB8) Skill5[26] skills;
	@Unknown ubyte[0x1E68] unknown1;
	ulong currentHP;
	ulong currentSP;
	@Offset(0x2CD0) ModernStats stats;
	@Unknown ubyte[0x90] unknown2;
	EquipmentMastery5 equipmentMastery;
	uint mana;
	@Unknown ubyte[0x16] unknown3;
	@Offset(0x2E0A) ModernResistance baseResist;
	ModernResistance resist;
	MiscStatsExpanded miscStats;
	@Unknown ubyte[11] unknown4;
	uint storedLevels;
	ushort numReincarnations;
	@Unknown ubyte[6] unknown5;
	ushort numKills;
	@Unknown ubyte[4] unknown6;
	@Offset(0x2E42) uint numDeaths;
	@Unknown ushort unknown2E46;
	ulong maxDamage;
	ulong totalDamage;
	@Unknown ubyte[0x8E] unknown2E56;
	@Offset(0x2EE6) Evility[27] _evilities;
	@Unknown ubyte[0x130] unknown2F1C;
	@Offset(0x304C) ushort level;
	@Unknown ubyte[34] unknown8;
	ModernStatsImpl!short baseStats;
	@Unknown ubyte[0x16D0] unknown9	;

	auto evilities() const {
		import std.algorithm : filter;
		return _evilities[].filter!(x => x.isValid);
	}
}
mixin VerifyOffsets!(Character, 0x4750);

align(1)
struct D5PC {
	align(1):
	@Unknown ubyte[0x23B480] unknown1;
	@Offset(0x23B480) Character[128] _characters;
	@Unknown ubyte[54552] unknown2;
	@Offset(0x483198) Item[2000] _items;
	@Unknown ubyte[68] unknown3;
	@Offset(0x5A815C) ushort charCount;
	@Unknown ubyte[0x2F392A] unknown5A815E;

	auto characters() const {
		return _characters[0..charCount];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _items[].filter!(x => x.isValid);
	}
}

mixin VerifyOffsets!(D5PC, 0x89BA88);
