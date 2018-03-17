module disgaeareporter.disgaea2.pc;

import disgaeareporter.disgaea2.common;

import disgaeareporter.common;

import std.range : isOutputRange;
import std.traits : isSomeChar;
import std.typecons : BitFlags;

align(1)
struct Innocent {
	align(1):
	uint level;
	ubyte type;
	ubyte uniquer;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level > 10000 ? level-10000 : level, level > 10000 ? "+" : "", type.innocentName);
		debug (unknowns) {
			sink.formattedWrite!" - Unknown data:"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
}
static assert(Innocent.sizeof == 8);
private void funcii() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Innocent().toString(buf);
}

align(1)
struct Item {
	align(1):
	Innocent[8] innocents;
	ulong price;
	Stats stats;
	Stats baseStats;
	@Unknown ubyte[4] unknown;
	ubyte level;
	@Unknown ubyte[13] unknown2;
	ubyte rarity;
	@Unknown ubyte[29] unknown3;
	char[32] _name;
	@Unknown ubyte[168] unknown4;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"Lv%s %s (Rarity: %s) - %(%s, %)"(level, name, rarity, innocents[].filter!(x => x.type != 0));
		debug(itemstats) {
			sink.formattedWrite!"\n\t\t%s"(stats);
		}
		debug (unknowns) {
			sink.formattedWrite!" - Unknown data:"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
	bool isValid() const {
		return (unknown2 != unknown2.init);
	}
	auto name() const {
		return _name.fromStringz;
	}
}

static assert(Item.sizeof == 0x180);


private void funci() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Item().toString(buf);
}

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[4] equipment;
	char[64] _name;
	char[64] _className;
	@Unknown ubyte[260] unknown1;
	uint[96] skillEXP;
	ushort[96] skills;
	ubyte[96] skillLevels;
	@Unknown ubyte[508] unknown2;
	Stats stats;
	@Unknown ubyte[64] unknown3;
	uint mana;
	@Unknown ubyte[24] unknown4;
	ubyte[8] weaponMasteryLevel;
	ubyte[8] weaponMasteryRate;
	@Unknown ubyte[8] unknown5;
	BaseCharacterStats baseStats;
	@Unknown ubyte[8] unknown6;
	ushort level;
	@Unknown ubyte[16] unknown7;
	Resistance baseResist;
	Resistance resist;
	ubyte baseJM;
	ubyte jm;
	ubyte baseMV;
	ubyte mv;
	ubyte baseCounter;
	ubyte counter;
	@Unknown ubyte[534] unknown8;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		sink.formattedWrite!"%s (Lv%s %s)\n"(name, level, className);
		sink.formattedWrite!"\tMana: %s\n"(mana);
		//sink.formattedWrite!"\tTransmigrations: %s, Transmigrated Levels: %s\n"(numTransmigrations, transmigratedLevels);
		sink.formattedWrite!"\tCounter: %s, MV: %s, JM: %s\n"(counter, mv, jm);
		sink.formattedWrite!"\tElemental Affinity: %s\n"(resist);
		sink.formattedWrite!"\t%s\n"(stats);
		sink.formattedWrite!"\tBase Stats: %s\n"(baseStats);
		if (weaponMasteryLevel != weaponMasteryLevel.init) {
			sink.formattedWrite!"\tWeapon mastery:\n"();
			foreach (i, masteryRate, masteryLevel; lockstep(weaponMasteryRate[], weaponMasteryLevel[])) {
				if (masteryLevel > 0) {
					sink.formattedWrite!"\t\tLv%s %s\n"(masteryLevel, cast(WeaponTypes)i);
				}
			}
		}
		auto equips = equipment[].filter!(x => x.isValid);
		if (!equips.empty) {
			sink.formattedWrite!"\tEquipment:\n"();
			sink.formattedWrite!"%(\t\t%s\n%)\n"(equips);
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

		debug (unknowns) {
			sink.formattedWrite!" - Unknown data:"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
	auto name() const {
		return _name.fromStringz;
	}
	auto className() const {
		return _className.fromStringz;
	}
}
static assert(Character.sizeof == 0xF00);
static assert(Character.skills.offsetof == 0x90C);
static assert(Character.stats.offsetof == 0xC28);
static assert(Character.baseStats.offsetof == 0xCBC);
static assert(Character.baseResist.offsetof == 0xCDE);

private void func() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Character().toString(buf);
}

align(1)
struct Senator {
	align(1):
	ushort level;
	ushort classID;
	uint attendance;
	@Unknown ubyte[6] unknown;
	char[64] _name;
	byte favour;
	@Unknown ubyte[17] unknown2;
	auto name() const {
		return _name.fromStringz;
	}
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"%s (Level %s %s)\n\t"(name, level, classID.className);
		sink.formattedWrite!"%s (%s)\n"(favour.favourString, favour);
		//if (timesKilled > 0) {
		//	sink.formattedWrite!"\tKilled %s time%s\n"(timesKilled, timesKilled > 1 ? "s" : "");
		//}
		debug (unknowns) {
			sink.formattedWrite!"\tUnknown data:"();
			import std.traits : getSymbolsByUDA;
			static foreach (i; 0..getSymbolsByUDA!(typeof(this), Unknown).length) {
				sink.formattedWrite!"(%s)"(getSymbolsByUDA!(typeof(this), Unknown)[i]);
			}
		}
	}
}

static assert(Senator.sizeof == 0x60);

align(1)
struct PCGame {
	align(1):
	@Unknown ubyte[8] unknown;
	Playtime playtime;
	@Unknown ubyte[963] unknown2;
	ulong totalHL;
	@Unknown ubyte[2336] unknown3;
	Character[128] _characters;
	Senator[64] _senators;
	ubyte[5632] unknown4;
	Item[24] _bagItems;
	Item[512] _warehouseItems;
	@Unknown ubyte[60] unknown5;
	ushort charCount;
	@Unknown ubyte[526] unknown6;
	BitFlags!Rarity[1680] itemRecords;
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
	auto senators() const {
		return _senators[];
	}
	static string itemRecordName(size_t record) {
		import d2data : d2itemRecords;
		return d2itemRecords[record];
	}
	enum itemRecordAlignment = 80;
}
static assert(PCGame.totalHL.offsetof == 0x3D0);
static assert(PCGame._characters.offsetof == 0xCF8);
static assert(PCGame._senators.offsetof == 0x78CF8);
static assert(PCGame._bagItems.offsetof == 0x7BAF8);
static assert(PCGame.charCount.offsetof == 0xADF34);



string fromStringz(Char)(Char[] cString) if (isSomeChar!Char){
	import std.algorithm : countUntil;
	import std.string : representation;
	auto endIndex = cString.representation.countUntil('\0');
	auto str = cString[0..endIndex == -1 ? cString.length : endIndex];
	string output;
	foreach (dchar chr; str) {
		switch(chr) {
			case '　': output ~= ' '; break;
			default: output ~= chr; break;
		}
	}
	return output;
}

unittest {
	import disgaeareporter.common : printData;
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	auto data = loadData!PCGame(getRawData(cast(immutable(ubyte)[])import("d2pc-SAVE000.DAT"), Platforms.pc));
	assert(data.totalHL == 368);
	with(data.characters[0]) {
		assert(name == "Adell");
		assert(className == "Demon Hunter");
	}
	with (data._bagItems[0]) {
		assert(name == "Mint Gum");
	}
	//printData(data);
}