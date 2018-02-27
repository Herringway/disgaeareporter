module disgaeareporter.disgaea1.pc;

import disgaeareporter.disgaea1.common;

import std.range : isOutputRange;
import std.typecons : BitFlags;

Character[] chars;

align(1)
struct PCGame {
	align(1):
	ubyte[8] unknown1;
	Playtime playtime;
	ubyte[643] unknown_;
	ulong totalHL;
	ulong unknown__;
	ubyte[8] unknown____;
	ulong hpRecovered;
	ulong spRecovered;
	ubyte[2304] unknown2;
	//0x1EC - Shoe Inventory?
	Character[128] _characters;
	Senator[512] senators;
	MapClearData[153] mapClears;
	ubyte[640] unknown4;
	Item[16] _bagItems;
	Item[256] _warehouseItems;
	ubyte[28] unknown5;
	ushort allyKillCount;
	ubyte[2] unknown6;
	ulong revived;
	ubyte[8] unknown7;
	ushort charCount;
	ubyte[70] unknown8;
	ubyte bgmVolume;
	ubyte voiceVolume;
	ubyte sfxVolume;
	ubyte[53] unknown9;
	BitFlags!Rarity[1008] itemRecords;
	ubyte[352] unknown10;
	uint maxDamage;
	uint totalDamage;
	uint geoCombo;
	uint unknown11;
	uint unknown12;
	uint enemiesKilled;
	//???
	uint enemiesKilledCopy;
	uint maxLevel;
	//???
	uint reincarnation;
	uint itemRate;
	uint itemWorldVisits;
	uint itemWorldLevels;
	uint unknown13;
	BitFlags!Defeated defeated;
	ubyte[848] unknown14;
	Character[3] extraNPCs;
	ubyte[8903] unknown15;

	Character[] characters() {
		return _characters[0..charCount];
	}
	static string itemRecordName(size_t record) {
		import d1data : d1itemRecords;
		return d1itemRecords[record];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _bagItems[].filter!(x => x.isValid);
	}
	auto warehouseItems() const {
		import std.algorithm : filter;
		return _warehouseItems[].filter!(x => x.isValid);
	}

	//import std.format;
	//void toString(T, Char)(T sink, FormatSpec!Char fmt) const if (isOutputRange!(T, const(char))) {
	//	import std.algorithm : filter;
	//	sink.formattedWrite("%(%s\n)", characters[0..charCount]);
	//	sink.formattedWrite("Senators: %(%s\n)", senators[].filter!(x => x.attendance > 0));
	//}
}
static assert(PCGame.totalHL.offsetof == 0x290);
static assert(PCGame.mapClears.offsetof == 0x3A7B8);
static assert(PCGame._warehouseItems.offsetof == 0x3B800);
static assert(PCGame.allyKillCount.offsetof == 0x4481C);
static assert(PCGame.revived.offsetof == 0x44820);
static assert(PCGame.charCount.offsetof == 0x44830);
static assert(PCGame.itemRecords.offsetof == 0x448B0);
static assert(PCGame.maxDamage.offsetof == 0x44E00);
static assert(PCGame.extraNPCs.offsetof == 0x45188);
static assert(PCGame.sizeof == 0x48877);

align(1)
struct Playtime {
	align(1):
	ushort hours_;
	ubyte minutes_;
	ubyte seconds_;
	ubyte milliseconds_;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"%s"(duration);
	}
	auto duration() const {
		import core.time : hours, minutes, seconds, msecs;
		return hours_.hours + minutes_.minutes + seconds_.seconds + milliseconds_.msecs;
	}
}

private void playtimeTest() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Playtime().toString(buf);
}

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
	ubyte[10] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"Lv%s %s (Rarity: %s) - %(%s, %)"(level, nameID.itemName, rarity, innocents[].filter!(x => x.type != 0));
	}
	bool isValid() const {
		return nameID != 0;
	}
}
static assert(Item.sizeof == 0x90);



align(1)
struct SkillEXP {
	align(1):
	ubyte[3] count;
}
static assert(SkillEXP.sizeof == 3);

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[4] equipment;
	ubyte[32] sjisName;
	ubyte unknown1;
	ubyte[33] title;
	ubyte[2] unknown2;
	ubyte[32] unknown3;
	Resistance[5] resistances;
	ubyte[110] unknown4;
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
	BaseCharacterStats baseStats;
	ushort level;
	ushort unknown7;
	ushort class_;
	ushort class2;
	ushort skillTree;
	ubyte[10] unknown8;
	byte baseFireResist;
	byte baseIceResist;
	byte baseWindResist;
	byte fireResist;
	byte iceResist;
	byte windResist;
	ubyte baseJM;
	ubyte jm;
	ubyte baseMV;
	ubyte mv;
	ubyte baseCounter;
	ubyte counter;
	ubyte[13] unknown9;
	ubyte senateRank;
	ubyte[2] unknown10;
	byte mentor;
	ubyte[39] unknown11;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		sink.formattedWrite!"%s (Lv%s %s)\n"(name, level, className);
		sink.formattedWrite!"\tRank: %s, Mana: %s\n"(senateRank, mana);
		sink.formattedWrite!"\tCounter: %s, MV: %s, JM: %s\n"(counter, mv, jm);
		sink.formattedWrite!"\tResists - Fire: %s%%, Wind: %s%%, Ice: %s%%\n"(fireResist, windResist, iceResist);
		if (mentor >= 0) {
			//sink.formattedWrite("\tMentor: %s\n", chars[cast(size_t)mentor].name);
		}
		sink.formattedWrite!"\t%s\n"(stats);
		if (weaponMasteryLevel != weaponMasteryLevel.init) {
			sink.formattedWrite!"\tWeapon mastery:\n"();
			foreach (i, masteryRate, masteryLevel; lockstep(weaponMasteryRate[], weaponMasteryLevel[])) {
				if (masteryLevel > 0) {
					sink.formattedWrite!"\t\tLv%s %s\n"(masteryLevel, cast(WeaponTypes)i);
				}
			}
		}
		if (equipment != equipment.init) {
			sink.formattedWrite!"\tEquipment:\n"();
			sink.formattedWrite!"%(\t\t%s\n%)\n"(equipment[].filter!(x => x.nameID != 0));
		}
		if (skills[0] != 0) {
			sink.formattedWrite!"\tAbilities:\n"();
			foreach (i, skill, skillLevel, skillEXP; lockstep(skills[], skillLevels[], skillEXP[])) {
				if ((skill > 0) && (skillLevel != 255)) {
					sink.formattedWrite!"\t\tLv%s %s (%s EXP)\n"(skillLevel, skill.skillName, skillEXP);
				} else if (skillLevel == 255) {
					sink.formattedWrite!"\t\tLearning %s (%s EXP)\n"(skill.skillName, skillEXP);
				}
			}
		}
		debug(unknowns) formattedWrite!"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n"(sink, unknown1, unknown2, unknown3, unknown4, unknown5, unknown6, unknown7, unknown8, unknown9, unknown10, unknown11);
	}
	string name() const {
		return sjisDec(sjisName[]);
	}
	string className() const {
		return sjisDec(title[]);
	}
}

static assert(Character.sizeof == 0x6B8);

private void func() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Character().toString(buf);
}


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
	auto data = loadData!PCGame(getRawData(cast(immutable(ubyte)[])import("d1pc-SAVE000.DAT"), Platforms.pc));
	assert(data.characters.length == 6);

	with(data.characters[0]) {
		assert(name == "Laharl");
		assert(level == 5);
	}

	with(data.characters[5]) {
		assert(mentor == 0);
	}

	with(data._bagItems[0]) {
		assert(nameID.itemName == "Common Sword");
		assert(rarity == 32);
	}
}