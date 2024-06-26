module disgaeareporter.disgaea1.pc;

import d1data;
import disgaeareporter.disgaea1.common;

import disgaeareporter.common;

import reversineer : Offset, VerifyOffsets;

import std.range : isOutputRange;
import std.typecons : BitFlags;

align(1)
struct D1PC {
	align(1):
	@Unknown ubyte[8] unknown1;
	Playtime playtime;
	SJISString!34 fileName;
	ushort level;
	ushort unknown2;
	ushort chapter;
	@Unknown ubyte[603] unknown3;
	@Offset(0x290) ulong totalHL;
	@Unknown ulong unknown4;
	@Unknown ubyte[8] unknown5;
	ulong hpRecovered;
	ulong spRecovered;
	@Unknown ubyte[2304] unknown6;
	//0x1EC - Shoe Inventory?
	Character[128] _characters;
	Senator[512] senators;
	@Offset(0x3A7B8) MapClearData[153] areas;
	@Unknown ubyte[640] unknown7;
	Item[16] _bagItems;
	@Offset(0x3B800) Item[256] _warehouseItems;
	@Unknown ubyte[28] unknown8;
	@Offset(0x4481C) ushort allyKillCount;
	@Unknown ubyte[2] unknown9;
	@Offset(0x44820) ulong revived;
	@Unknown ubyte[8] unknown10;
	@Offset(0x44830) ushort charCount;
	@Unknown ubyte[70] unknown11;
	ubyte bgmVolume;
	ubyte voiceVolume;
	ubyte sfxVolume;
	@Unknown ubyte[53] unknown12;
	@Offset(0x448B0) BitFlags!Rarity[1008] itemRecords;
	bool friendlyEffectDisabled;
	bool enemyEffectDisabled;
	bool japaneseVoices;
	@Unknown ubyte[349] unknown13;
	@Offset(0x44E00) uint maxDamage;
	uint totalDamage;
	uint geoCombo;
	@Unknown uint unknown14;
	@Unknown uint unknown15;
	uint enemiesKilled;
	//???
	uint enemiesKilledCopy;
	uint maxLevel;
	//???
	uint reincarnation;
	uint itemRate;
	uint itemWorldVisits;
	uint itemWorldLevels;
	@Unknown uint unknown16;
	BitFlags!Defeated defeated;
	@Unknown ubyte[848] unknown17;
	@Offset(0x45188) Character[3] extraNPCs;
	@Unknown ubyte[8903] unknown18;

	auto characters() const {
		return _characters[0..charCount];
	}
	static string itemRecordName(size_t record) {
		import d1data : d1itemRecords;
		return d1itemRecords[record];
	}
	enum itemRecordAlignment = 48;
	auto bagItems() const {
		import std.algorithm : filter;
		return _bagItems[].filter!(x => x.isValid);
	}
	auto warehouseItems() const {
		import std.algorithm : filter;
		return _warehouseItems[].filter!(x => x.isValid);
	}
	static auto defeatedStr(const ubyte id) {
		return defeatedString(id);
	}
}

mixin VerifyOffsets!(D1PC, 0x48877);

align(1)
struct Item {
	align(1):
	Innocent[16] innocents;
	ulong price;
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
	@Unknown ubyte[10] unknown;
	string name() const {
		return d1items.get(nameID, format!"Unknown item %04X"(nameID));
	}
	bool isValid() const {
		return nameID != 0;
	}
}
mixin VerifyOffsets!(Item, 0x90);

align(1)
struct Character {
	import siryul: SiryulizeAs;
	align(1):
	ulong exp;
	Item[4] equipment;
	SJISString!32 name;
	@Unknown ubyte unknown1;
	SJISString!33 className;
	@Unknown ubyte[2] unknown2;
	@Unknown ubyte[32] unknown3;
	StatusResistance[5] statusResistances;
	@Unknown ubyte[110] unknown4;
	Skills!(96, d1skillNames) skills;
	uint currentHP;
	uint currentSP;
	Stats stats;
	Stats realStats;
	@Unknown ubyte[32] unknown5;
	uint mana;
	@Unknown ubyte[24] unknown6;
	EquipmentMastery equipmentMastery;
	BaseCharacterStats baseStats;
	ushort level;
	@Unknown ushort unknown7;
	ushort class_;
	ushort class2;
	ushort skillTree;
	@Unknown ubyte[10] unknown8;
	Resistance baseResist;
	Resistance resist;
	MiscStats miscStats;
	@Unknown ubyte[13] unknown9;
	ubyte senateRank;
	@Unknown ubyte[2] unknown10;
	byte mentor;
	@Unknown ubyte[9] unknown11;
	ubyte numTransmigrations;
	@Unknown ubyte[5] unknown12;
	uint storedLevels;
	@Unknown ubyte[20] unknown13;

	alias numReincarnations = numTransmigrations;
}

mixin VerifyOffsets!(Character, 0x6B8);


ubyte[] decompress(const ubyte[] input, uint expected) pure @safe {
	ubyte[] output;
	output.reserve(expected);

	void copyBack(uint length, uint position) {
		output ~= output[$-position..$-position+length];
	}

	for (uint i = 0; i < input.length; i++) {
		if (input[i] == 0) {
			continue;
		} else if (input[i] < 0x80) {
			output ~= input[i+1..i+1+input[i]];
			i += input[i];
		} else if (input[i] < 0xC0) {
			auto compensated = input[i] - 0x80;
			copyBack(((compensated&0xF0)>>4) + 1, (compensated&0xF)+1);
		} else if (input[i] < 0xE0) {
			auto compensated = input[i] - 0xC0;
			copyBack(compensated+2, input[i+1] + 1);
			i++;
		} else if (input[i] <= 0xFF) {
			auto compensated = input[i] - 0xE0;
			copyBack((compensated<<4) + ((input[i+1]&0xF0)>>4) + 3, ((input[i+1]&0xF)<<8) + input[i+2] + 1);
			i += 2;
		}
	}
	return output;
}

//PC
unittest {
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	auto data = loadData!D1PC(getRawData(cast(immutable(ubyte)[])import("d1pc-SAVE000.DAT"), Platforms.pc));
	assert(data.characters.length == 6);
	assert(data.fileName == "Laharl");

	with(data.characters[0]) {
		assert(name == "Laharl");
		assert(level == 5);
	}

	with(data.characters[5]) {
		assert(mentor == 0);
	}

	with(data._bagItems[0]) {
		assert(name == "Common Sword");
		assert(rarity == 32);
	}
}
