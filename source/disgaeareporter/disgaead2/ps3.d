module disgaeareporter.disgaead2.ps3;

import disgaeareporter.common;
import disgaeareporter.disgaead2.common;

import std.range : isOutputRange;

align(1)
struct Innocent {
	align(1):
	BigEndian!uint level;
	BigEndian!ushort type;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level, /+level > 10000 ? "+" : ""+/ "", type.innocentName);
	}
	bool isValid() const {
		return type != 0;
	}
}

align(1)
struct Item {
	align(1):
	BigEndian!uint unknown1;
	Innocent[6] innocents;
	@Unknown ubyte[4] unknown2;
	ModernStats!true stats;
	ModernStats!true baseStats;
	BigEndian!ushort nameID;
	BigEndian!ushort level;
	@Unknown ubyte[53] unknown3;
	char[64] _name;
	@Unknown ubyte[95] unknown4;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		auto validInnocents = innocents[].filter!(x => x.isValid);
		sink.formattedWrite!"Lv%s %s%s%(%s, %)"(level, name, validInnocents.empty ? "" : " - ", validInnocents);
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
	auto name() const {
		return _name.fromStringz;
	}
}

static assert(Item.sizeof == 0x190);
static assert(Item.nameID.offsetof == 0xB8);
static assert(Item._name.offsetof == 0xF1);

private void funci() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Item().toString(buf);
}
align(1)
struct Character {
	align(1):
	BigEndian!ulong exp;

	Item[4] equipment;
	char[52] _name;
	char[52] _className;
	@Unknown ubyte[180] unknown;
	BigEndian!uint[256] skillEXP;
	BigEndian!ushort[256] skills;
	ubyte[256] skillLevels;
	@Unknown ubyte[516] unknown2;
	BigEndian!ulong currentHP;
	BigEndian!ulong currentSP;
	ModernStats!true stats;
	ModernStats!true realStats;
	@Unknown ubyte[8] unknown3;
	BaseCharacterStatsLater!true baseStats;
	@Unknown ubyte[64] unknown4;
	BigEndian!uint mana;
	BigEndian!ushort level;
	@Unknown ubyte[18] unknown5;
	Resistance baseResist;
	Resistance resist;
	ubyte baseJM;
	ubyte jm;
	ubyte baseMV;
	ubyte mv;
	ubyte baseCounter;
	ubyte counter;
	ubyte baseThrow;
	ubyte throw_;
	ubyte baseCrit;
	ubyte crit;
	@Unknown ubyte[8] unknown6;
	ubyte range;
	@Unknown ubyte[23] unknown7;
	BigEndian!ulong numKills;
	BigEndian!ulong numDeaths;
	BigEndian!ulong maxDamage;
	BigEndian!ulong totalDamage;
	@Unknown ubyte[844] unknown8;
	Aptitudes!true aptitudes;
	Aptitudes!true aptitudes2;
	@Unknown ubyte[1348] unknown9;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		sink.formattedWrite!"%s (Lv%s %s)\n"(name, level, className);
		sink.formattedWrite!"\tMana: %s\n"(mana);
		//sink.formattedWrite!"\tTransmigrations: %s, Transmigrated Levels: %s\n"(numTransmigrations, transmigratedLevels);
		sink.formattedWrite!"\tCounter: %s, move: %s, jump: %s, throw: %s, range: %s, crit: %s%%\n"(counter, mv, jm, throw_, range, crit);
		sink.formattedWrite!"\tElemental Affinity: %s\n"(resist);
		sink.formattedWrite!"\t%s\n"(stats);
		sink.formattedWrite!"\tAptitudes: %s\n"(aptitudes);
		sink.formattedWrite!"\tBase Stats: %s\n"(baseStats);
		sink.formattedWrite!"\tMax Damage: %s, Total Damage: %s\n"(maxDamage, totalDamage);
		sink.formattedWrite!"\tEnemy Kill Count: %s, Death Count: %s\n"(numKills, numDeaths);
		//if (weaponMasteryLevel != weaponMasteryLevel.init) {
		//	sink.formattedWrite!"\tWeapon mastery:\n"();
		//	foreach (i, masteryRate, masteryLevel; lockstep(weaponMasteryRate[], weaponMasteryLevel[])) {
		//		if (masteryLevel > 0) {
		//			sink.formattedWrite!"\t\tLv%s %s\n"(masteryLevel, cast(WeaponTypes)i);
		//		}
		//	}
		//}
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
static assert(Character.sizeof == 0x1A60);
static assert(Character._name.offsetof == 0x648);
static assert(Character.skillEXP.offsetof == 0x764);
static assert(Character.skills.offsetof == 0xB64);
static assert(Character.stats.offsetof == 0x1078);
static assert(Character.baseStats.offsetof == 0x1100);
static assert(Character.level.offsetof == 0x114C);
static assert(Character.baseResist.offsetof == 0x1160);
static assert(Character.maxDamage.offsetof == 0x11A0);
static assert(Character.aptitudes.offsetof == 0x14FC);

private void func() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Character().toString(buf);
}

align(1)
struct DD2PS3 {
	align(1):
	@Unknown ubyte[1440] unknown1;
	Character[128] _characters;
	@Unknown ubyte[40824] unknown2;
	Item[999] _items;
	@Unknown ubyte[72164] unknown3;
	BigEndian!ushort charCount;


	auto characters() const {
		return _characters[0..charCount];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _items[].filter!(x => x.isValid);
	}
}

static assert(DD2PS3._characters.offsetof == 0x5A0);
static assert(DD2PS3._items.offsetof == 0xDD518);
static assert(DD2PS3.charCount.offsetof == 0x1507EC);

unittest {
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	auto data = loadData!DD2PS3(cast(immutable(ubyte)[])import("dd2ps3-raw.DAT"));
	assert(data.characters.length == 20);

	with(data.characters[0]) {
		assert(name == "Laharl");
		assert(level == 27);
		assert(skills[0] == 0x00C9);
		assert(exp == 58793);
		assert(mana == 416);
		assert(skillEXP[0] == 94);
		assert(totalDamage == 43038);
		assert(maxDamage == 1203);
		assert(numDeaths == 4);
		assert(numKills == 120);
		assert(aptitudes.hp == 120);
		with(equipment[0]) {
			assert(level == 0);
			assert(nameID == 209);
			with(innocents[0]) {
				assert(level == 5);
				assert(type == 4);
			}
		}
	}

	with(data._items[0]) {
		assert(name == "Bamboo Water Gun");
	}
}