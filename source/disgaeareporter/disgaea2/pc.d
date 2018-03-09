module disgaeareporter.disgaea2.pc;

import disgaeareporter.disgaea2.common;

import std.range : isOutputRange;
import std.traits : isSomeChar;

align(1)
struct Innocent {
	align(1):
	uint level;
	ubyte type;
	ubyte uniquer;
	ubyte[2] unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"Lv%s%s %s"(level > 10000 ? level-10000 : level, level > 10000 ? "+" : "", type.innocentName);
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
	ubyte[18] unknown;
	ubyte rarity;
	ubyte[29] unknown2;
	char[32] _name;
	ubyte[168] unknown3;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"Lv%s %s (Rarity: %s) - %(%s, %)"("level", name, rarity, innocents[].filter!(x => x.type != 0));
		debug(itemstats) {
			sink.formattedWrite!"\n\t\t%s"(stats);
		}
		debug(unknowns) {
			sink.formattedWrite!"\n%s\n%s\n%s"(unknown, unknown2, unknown3);
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
	ubyte[2168] unknown;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		sink.formattedWrite!"%s (Lv%s %s)\n"(name, "level", className);
		sink.formattedWrite!"\tRank: %s, Mana: %s\n"("senateRank", "mana");
		sink.formattedWrite!"\tCounter: %s, MV: %s, JM: %s\n"("counter", "mv", "jm");
		sink.formattedWrite!"\tResists - Fire: %s%%, Wind: %s%%, Ice: %s%%\n"("fireResist", "iceResist", "windResist");
		//if (mentor >= 0) {
		//	sink.formattedWrite("\tMentor: %s\n", chars[cast(size_t)mentor].name);
		//}
		sink.formattedWrite!"\t%s\n"("stats");
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
		//debug(unknowns) formattedWrite!"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n"(sink, unknown1, unknown2, unknown3, unknown4, unknown5, unknown6, unknown7, unknown8, unknown9, unknown10, unknown11);
	}
	auto name() const {
		return _name.fromStringz;
	}
	auto className() const {
		return _className.fromStringz;
	}
}
static assert(Character.sizeof == 0xF00);

private void func() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Character().toString(buf);
}


align(1)
struct PCGame {
	align(1):
	ubyte[0x3D0] unknown;
	ulong totalHL;
	ubyte[2336] unknown2;
	Character[8] _characters;
	ubyte[472576] unknown3;
	Item[24] _bagItems;
	Item[512] _warehouseItems;
	auto characters() const {
		return _characters[];
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
static assert(PCGame.totalHL.offsetof == 0x3D0);
static assert(PCGame._characters.offsetof == 0xCF8);
static assert(PCGame._bagItems.offsetof == 0x7BAF8);


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