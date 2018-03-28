module disgaeareporter.disgaead2.ps3;

import disgaeareporter.common;
import disgaeareporter.disgaead2.common;

import std.range : isOutputRange;

align(1)
struct Innocent {
	align(1):
	uint level;
	ushort type;
	@Unknown ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level, /+level > 10000 ? "+" : ""+/ "", type.innocentName);
	}
	void postRead() {
		version(LittleEndian) {
			import std.bitmanip : swapEndian;
			level = swapEndian(level);
			type = swapEndian(type);
		}
	}
	bool isValid() const {
		return type != 0;
	}
}

align(1)
struct Item {
	align(1):
	uint unknown1;
	Innocent[6] innocents;
	@Unknown ubyte[4] unknown2;
	ModernStats!true stats;
	ModernStats!true baseStats;
	ushort nameID;
	ushort level;
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
	void postRead() {
		version(LittleEndian) {
			import std.bitmanip : swapEndian;
			unknown1 = swapEndian(unknown1);
			level = swapEndian(level);
			nameID = swapEndian(nameID);
		}
		stats.postRead();
		foreach (ref innocent; innocents) {
			innocent.postRead();
		}
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
	ulong exp;

	Item[4] equipment;
	char[52] _name;
	char[52] _className;
	@Unknown ubyte[2488] unknown;
	ulong currentHP;
	ulong currentSP;
	ModernStats!true stats;
	ModernStats!true realStats;
	@Unknown ubyte[84] unknown2;
	ushort level;
	@Unknown ubyte[2322] unknown3;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		sink.formattedWrite!"%s (Lv%s %s)\n"(name, level, className);
		//sink.formattedWrite!"\tMana: %s\n"(mana);
		//sink.formattedWrite!"\tTransmigrations: %s, Transmigrated Levels: %s\n"(numTransmigrations, transmigratedLevels);
		//sink.formattedWrite!"\tCounter: %s, MV: %s, JM: %s\n"(counter, mv, jm);
		//sink.formattedWrite!"\tElemental Affinity: %s\n"(resist);
		sink.formattedWrite!"\t%s\n"(stats);
		//sink.formattedWrite!"\tBase Stats: %s\n"(baseStats);
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
		//if (skills[0] != 0) {
		//	sink.formattedWrite!"\tAbilities:\n"();
		//	foreach (i, skill, skillLevel, skillEXP; lockstep(skills[], skillLevels[], skillEXP[])) {
		//		if ((skill > 0) && (skillLevel != 255)) {
		//			sink.formattedWrite!"\t\tLv%s %s (%s EXP)\n"(skillLevel, skill.skillName, skillEXP);
		//		} else if (skillLevel == 255) {
		//			sink.formattedWrite!"\t\tLearning %s (%s EXP)\n"(skill.skillName, skillEXP);
		//		}
		//	}
		//}

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
	void postRead() {
		version(LittleEndian) {
			import std.bitmanip : swapEndian;
			exp = swapEndian(exp);
			level = swapEndian(level);
		}
		stats.postRead();
		realStats.postRead();
		foreach (ref item; equipment) {
			item.postRead();
		}
	}
}
static assert(Character.sizeof == 0x1A60);
static assert(Character._name.offsetof == 0x648);
static assert(Character.stats.offsetof == 0x1078);
static assert(Character.level.offsetof == 0x114C);

private void func() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Character().toString(buf);
}

align(1)
struct PS3Game {
	align(1):
	@Unknown ubyte[1440] unknown1;
	Character[128] _characters;
	@Unknown ubyte[40824] unknown2;
	Item[999] _items;
	@Unknown ubyte[72164] unknown3;
	ushort charCount;


	auto characters() const {
		return _characters[0..charCount];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _items[].filter!(x => x.isValid);
	}
	void postRead() {
		version(LittleEndian) {
			import std.bitmanip : swapEndian;
			charCount = swapEndian(charCount);
		}
		foreach (ref character; _characters) {
			character.postRead();
		}
		foreach (ref item; _items) {
			item.postRead();
		}
	}
}

static assert(PS3Game._characters.offsetof == 0x5A0);
static assert(PS3Game._items.offsetof == 0xDD518);
static assert(PS3Game.charCount.offsetof == 0x1507EC);

private void x() {
	PS3Game().postRead();
}