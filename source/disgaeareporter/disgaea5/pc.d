module disgaeareporter.disgaea5.pc;

import disgaeareporter.common;
import disgaeareporter.disgaea5.common;

import std.range;

align(1)
struct Innocent {
	align(1):
	@Unknown ubyte[4] unknown1;
	ubyte type;
	@Unknown ubyte[3] unknown2;
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
	@Unknown ubyte[0x1B] unknown2;
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
struct Character {
	align(1):
	ulong exp;
	Item[5] equipment;
	ZeroString!0x34 name;
	ZeroString!0x34 className;
	@Unknown ubyte[0x2098] unknown1;
	ulong currentHP;
	ulong currentSP;
	ModernStats!false stats;
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
	ModernStatsImpl!(short, false) baseStats;
	@Unknown ubyte[0x16D0] unknown9	;
}
static assert(Character.sizeof == 0x4750);
static assert(Character.name.offsetof == 0xBC0);
static assert(Character.stats.offsetof == 0x2CD0);
static assert(Character.baseResist.offsetof == 0x2E0A);
static assert(Character.level.offsetof == 0x304C);

align(1)
struct D5PC {
	align(1):
	@Unknown ubyte[0x23B480] unknown1;
	Character[128] _characters;
	@Unknown ubyte[55152] unknown2;
	Item[999] _items;
	@Unknown ubyte[600068] unknown3;
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
static assert(D5PC._items.offsetof == 0x4833F0);
static assert(D5PC.charCount.offsetof == 0x5A815C);
