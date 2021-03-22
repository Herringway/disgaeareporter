module disgaeareporter.disgaea1.ps2;

import d1data;
import disgaeareporter.disgaea1.common;

import disgaeareporter.common;

import reversineer : Offset, VerifyOffsets;

import std.range : isOutputRange;

PS2Character[] ps2Chars;

align(1)
struct D1PS2 {
	align(1):
	ubyte[640] unknown;
	@Offset(0x280) ulong totalHL;
	ubyte[2336] unknown2;
	@Offset(0xBA8) PS2Character[128] _characters;
	@Offset(0x3EFA8) Senator[512] senators;
	ubyte[4] unknown3;
	@Offset(0x42FAC) PS2MapClearData[144] areas;
	ubyte[7964] unknown4;
	@Offset(0x472C8) PS2Item[16] _bagItems;
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

mixin VerifyOffsets!(D1PS2, 0x54840);

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
	@Offset(0x9A) SJISString!32 _name; //Unused
	ubyte[14] unknown3;
	bool isValid() const {
		return nameID != 0;
	}
	string name() const {
		return d1items(nameID);
	}
}
mixin VerifyOffsets!(PS2Item, 0xC8);

align(1)
struct PS2Character {
	align(1):
	ulong exp;
	PS2Item[4] equipment;
	SJISString!32 name;
	ushort unknown1;
	SJISString!32 className;
	ubyte[2] unknown2;
	ubyte[34] unknown3;
	StatusResistance[5] statusResistances;
	ubyte[112] unknown4;
	Skills!(96, d1skillNames) skills;
	uint currentHP;
	uint currentSP;
	Stats stats;
	Stats realStats;
	ubyte[32] unknown5;
	uint mana;
	ubyte[24] unknown6;
	EquipmentMastery equipmentMastery;
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
}
mixin VerifyOffsets!(PS2Character, 0x7C8);

struct PS2MapClearData {
	ushort clears;
	ushort kills;
	ushort mapID;
	ubyte bonusRank;
	ubyte[57] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"%s - Clears: %s, Kills: %s"(name, clears, kills);
		debug(unknowns) {
			sink.formattedWrite!", Unknown: %s"(unknown);
		}
	}
	string name() const {
		return d1mapNames(mapID);
	}
}

//PS2
unittest {
	import disgaeareporter.common : printData;
	import disgaeareporter.dispatcher : loadData;
	auto data = loadData!D1PS2(cast(immutable(ubyte)[])import("d1ps2-raw.dat"));

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
		assert(name == "Flan");
	}
	with(data._warehouseItems[0]) {
		assert(name == "Slippers");
	}
}
