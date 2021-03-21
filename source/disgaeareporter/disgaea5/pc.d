module disgaeareporter.disgaea5.pc;

import disgaeareporter.common;
import disgaeareporter.disgaea5.common;

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
	ushort itemID;
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

static assert(Item.sizeof == 0x258);
static assert(Item.itemID.offsetof == 0x128);

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
	ZeroString!0x34 name;
	ZeroString!0x34 className;
	@Unknown ubyte[144] unknown_;
	Skill5[26] skills;
	@Unknown ubyte[0x1E68] unknown1;
	ulong currentHP;
	ulong currentSP;
	ModernStats stats;
	@Unknown ubyte[0x90] unknown2;
	EquipmentMastery5 equipmentMastery;
	uint mana;
	@Unknown ubyte[0x16] unknown3;
	ModernResistance baseResist;
	ModernResistance resist;
	MiscStatsExpanded miscStats;
	@Unknown ubyte[11] unknown4;
	uint storedLevels;
	ushort numReincarnations;
	@Unknown ubyte[6] unknown5;
	ushort numKills;
	@Unknown ubyte[10] unknown6;
	ulong maxDamage;
	ulong totalDamage;
	@Unknown ubyte[0x1F4] unknown7;
	ushort level;
	@Unknown ubyte[34] unknown8;
	ModernStatsImpl!short baseStats;
	@Unknown ubyte[0x16D0] unknown9	;
}
static assert(Character.sizeof == 0x4750);
static assert(Character.name.offsetof == 0xBC0);
static assert(Character.skills.offsetof == 0xCB8);
static assert(Character.stats.offsetof == 0x2CD0);
static assert(Character.baseResist.offsetof == 0x2E0A);
static assert(Character.level.offsetof == 0x304C);

align(1)
struct D5PC {
	align(1):
	@Unknown ubyte[0x23B480] unknown1;
	Character[128] _characters;
	@Unknown ubyte[54552] unknown2;
	Item[2000] _items;
	@Unknown ubyte[68] unknown3;
	ushort charCount;
	auto characters() const {
		return _characters[0..charCount];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _items[].filter!(x => x.isValid);
	}
}

static assert(D5PC._characters.offsetof == 0x23B480);
static assert(D5PC._items.offsetof == 0x483198);
static assert(D5PC.charCount.offsetof == 0x5A815C);
