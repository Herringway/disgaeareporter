module disgaeareporter.disgaea1.ps2;

import disgaeareporter.disgaea1.common;

import disgaeareporter.common;

import std.range : isOutputRange;

PS2Character[] ps2Chars;

align(1)
struct PS2Game {
	align(1):
	ubyte[640] unknown;
	ulong totalHL;
	ubyte[2336] unknown2;
	PS2Character[128] _characters;
	Senator[512] senators;
	ubyte[4] unknown3;
	PS2MapClearData[144] mapClears;
	ubyte[7964] unknown4;
	PS2Item[16] _bagItems;
	PS2Item[256] _warehouseItems;
	ubyte[28] unknown5;
	ushort allyKillCount;
	ubyte[18] unknown6;
	ushort charCount;
	ubyte[198] unknown7;

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
static assert(PS2Game.totalHL.offsetof == 0x280);
static assert(PS2Game._characters.offsetof == 0xBA8);
static assert(PS2Game.senators.offsetof == 0x3EFA8);
static assert(PS2Game.mapClears.offsetof == 0x42FAC);
static assert(PS2Game._bagItems.offsetof == 0x472C8);
static assert(PS2Game.sizeof == 0x54840);

align(1)
struct PS2Item {
	align(1):
	Innocent[16] innocents;
	ulong price;
	ubyte[8] unknown;
	Stats stats;
	BaseItemStats baseStats;
	ushort nameID;
	ushort level;
	ushort lastFloor;
	ubyte rarity;
	ubyte type;
	ubyte icon;
	ubyte maxPopulation;
	ubyte mv;
	ubyte jm;
	ubyte rank;
	ubyte range;
	ubyte[12] unknown2;
	ubyte[32] sjisName;
	ubyte[14] unknown3;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"Lv%s %s (Rarity: %s) - %(%s, %)"(level, nameID.itemName, rarity, innocents[].filter!(x => x.type != 0));
	}
	string name() const {
		return sjisDec(sjisName[]);
	}
	bool isValid() const {
		return nameID != 0;
	}
}
static assert(PS2Item.sjisName.offsetof == 0x9A);
static assert(PS2Item.sizeof == 0xC8);

private void func2() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	PS2Item().toString(buf);
}

align(1)
struct PS2Character {
	align(1):
	ulong exp;
	PS2Item[4] equipment;
	ubyte[32] sjisName;
	ushort unknown1;
	ubyte[32] title;
	ubyte[2] unknown2;
	ubyte[34] unknown3;
	StatusResistance[5] statusResistances;
	ubyte[112] unknown4;
	uint[96] skillEXP;
	ushort[96] skills;
	ubyte[96] skillLevels;
	uint currentHP;
	uint currentSP;
	Stats stats;
	Stats realStats;
	ubyte[32] unknown5;
	uint mana;
	ubyte[24] unknown6;
	ubyte[8] weaponMasteryLevel;
	ubyte[8] weaponMasteryRate;
	ubyte[4] unknown6_;
	BaseCharacterStats baseStats;
	ubyte[4] unknown6__;
	ushort level;
	ushort unknown7;
	ushort class_;
	ushort class2;
	ushort skillTree;
	ubyte[10] unknown8;
	Resistance baseResist;
	Resistance resist;
	ubyte baseJM;
	ubyte jm;
	ubyte baseMV;
	ubyte mv;
	ubyte counter;
	ubyte[14] unknown9;
	ubyte senateRank;
	ubyte[78] unknown10;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		formattedWrite!"%s (Lv%s %s)\n"(sink, name, level, className);
		formattedWrite!"\tRank: %s, Mana: %s\n"(sink, senateRank, mana);
		sink.formattedWrite!"\tCounter: %s, MV: %s, JM: %s\n"(counter, mv, jm);
		sink.formattedWrite!"\tElemental Affinity: %s\n"(resist);
		formattedWrite!"\t%s\n"(sink, stats);
		if (weaponMasteryLevel != weaponMasteryLevel.init) {
			formattedWrite!"\tWeapon mastery:\n"(sink);
			foreach (i, masteryRate, masteryLevel; lockstep(weaponMasteryRate[], weaponMasteryLevel[])) {
				if (masteryLevel > 0) {
					formattedWrite!"\t\tLv%s %s\n"(sink, masteryLevel, cast(WeaponTypes)i);
				}
			}
		}
		if (equipment != equipment.init) {
			formattedWrite!"\tEquipment:\n"(sink);
			formattedWrite!"%(\t\t%s\n%)\n"(sink, equipment[].filter!(x => x.nameID != 0));
		}
		if (skills[0] != 0) {
			formattedWrite!"\tAbilities:\n"(sink);
			foreach (i, skill, skillLevel, skillEXP; lockstep(skills[], skillLevels[], skillEXP[])) {
				if ((skill > 0) && (skillLevel != 255)) {
					formattedWrite!"\t\tLv%s %s (%s EXP)\n"(sink, skillLevel, skill.skillName, skillEXP);
				} else if (skillLevel == 255) {
					formattedWrite!"\t\tLearning %s (%s EXP)\n"(sink, skill.skillName, skillEXP);
				}
			}
		}
		debug(unknowns) formattedWrite!"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n"(sink, unknown1, unknown2, unknown3, unknown4, unknown5, unknown6, unknown7, unknown8, unknown9, unknown10);
	}
	string name() const {
		return sjisDec(sjisName[]);
	}
	string className() const {
		return sjisDec(title[]);
	}
}
static assert(PS2Character.sizeof == 0x7C8);

struct PS2MapClearData {
	ushort clears;
	ushort kills;
	ushort mapID;
	ubyte bonusRank;
	ubyte[57] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"%s - Clears: %s, Kills: %s"(mapID.mapName, clears, kills);
		debug(unknowns) {
			sink.formattedWrite!", Unknown: %s"(unknown);
		}
	}
}

private void func() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	PS2Character().toString(buf);
}

//PS2
unittest {
	import disgaeareporter.common : printData;
	import disgaeareporter.dispatcher : loadData;
	auto data = loadData!PS2Game(cast(immutable(ubyte)[])import("d1ps2-raw.dat"));

	assert(data.totalHL == 4172);
	assert(data.allyKillCount == 3);

	with(data.characters[0]) {
		assert(name == "Laharl");
		assert(senateRank == 7);
		assert(mana == 5779);
	}
	with(data.characters[3]) {
		assert(resist.ice == -50);
		assert(resist.wind == 50);
	}
	with(data._bagItems[0]) {
		assert(nameID.itemName == "Flan");
	}
	with(data._warehouseItems[0]) {
		assert(nameID.itemName == "Slippers");
	}
}