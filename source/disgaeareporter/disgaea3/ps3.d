module disgaeareporter.disgaea3.ps3;

import disgaeareporter.common;
import disgaeareporter.disgaea3.common;


import std.range : isOutputRange;

align(1)
struct Item {
	align(1):
	Innocent[8] innocents;
	@Unknown ubyte[8] unknown1;
	LongStats!true stats;
	LongStats!true realStats;
	BigEndian!ushort nameID;
	@Unknown ubyte[30] unknown2;
	ubyte rarity;
	@Unknown ubyte[30] unknown3;
	SJISString!80 name;
	@Unknown ubyte[1] unknown4;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		//sink.formattedWrite!"Lv.? %s"(name);
		sink.formattedWrite!"Lv%s %s (Rarity: %s) - %(%s, %)"("?"/+level+/, name, rarity, innocents[].filter!(x => x.isValid));
		debug (unknowns) {
			sink.formattedWrite!" - Unknown data:"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
	bool isValid() const {
		return nameID != 0;
	}
}
static assert(Item.sizeof == 344);
static assert(Item.stats.offsetof == 0x48);
static assert(Item.rarity.offsetof == 0xE8);

align(1)
struct Character {
	align(1):
	BigEndian!ulong exp;
	Item[4] equipment;
	SJISString!40 name;
	SJISString!40 className;
	@Unknown ubyte[1032] unknown1;
	BigEndian!ulong currentHP;
	BigEndian!ulong currentSP;
	LongStats!true stats;
	LongStats!true realStats;
	@Unknown ubyte[92] unknown2;
	BigEndian!ushort level;
	@Unknown ubyte[16] unknown3;
	Resistance baseResist;
	Resistance resist;
	@Unknown ubyte[6676] unknown4;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		sink.formattedWrite!"%s (Lv%s %s)\n"(name, level, className);
		//sink.formattedWrite!"\tMana: %s\n"(senateRank, mana);
		//sink.formattedWrite!"\tTransmigrations: %s, Transmigrated Levels: %s\n"(numTransmigrations, transmigratedLevels);
		//sink.formattedWrite!"\t%s\n"(miscStats);
		sink.formattedWrite!"\tElemental Affinity: %s\n"(resist);
		//sink.formattedWrite!"\tBase Stats: %s\n"(baseStats);
		sink.formattedWrite!"\tStats: %s\n"(stats);
		//sink.formattedWrite!"\tItem Stat Multiplier: %s\n"(level.itemStatsMultiplier);
		//if (weaponMasteryLevel != weaponMasteryLevel.init) {
		//	sink.formattedWrite!"\tWeapon mastery:\n"();
		//	foreach (i, masteryRate, masteryLevel; lockstep(weaponMasteryRate[], weaponMasteryLevel[])) {
		//		if (masteryLevel > 0) {
		//			sink.formattedWrite!"\t\tLv%s %s\n"(masteryLevel, cast(WeaponTypes)i);
		//		}
		//	}
		//}
		if (equipment != equipment.init) {
			sink.formattedWrite!"\tEquipment:\n"();
			sink.formattedWrite!"%(\t\t%s\n%)\n"(equipment[].filter!(x => x.isValid));
		}
		debug (unknowns) {
			sink.formattedWrite!"\tUnknown data:\n"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
}

static assert(Character.sizeof == 9432);
static assert(Character.name.offsetof == 0x568);
static assert(Character.stats.offsetof == 0x9D0);
static assert(Character.level.offsetof == 0xAAC);
static assert(Character.baseResist.offsetof == 0xABE);


align(1)
struct Innocent {
	align(1):
	BigEndian!uint level;
	BigEndian!ushort type;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"Lv%s%s %s"(level, /+level > 10000 ? "+" : ""+/ "", type.toInt.innocentName);
	}
	bool isValid() const {
		return type != 0;
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
	Character[64] _characters;
	@Unknown ubyte[47712] unknown3;
	Item[32] _bagItems;
	Item[512] _warehouseItems;
	@Unknown ubyte[36780] unknown4;
	BigEndian!ushort charCount;

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

static assert(D3PS3._characters.offsetof == 0xCC8);
static assert(D3PS3._bagItems.offsetof == 0x9FD28);
static assert(D3PS3.charCount.offsetof == 0xD67D4);

unittest {
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	auto data = loadData!D3PS3(getRawData(cast(immutable(ubyte)[])import("d3ps3-raw.DAT"), Platforms.ps3));
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