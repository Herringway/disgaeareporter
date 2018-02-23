module disgaeareporter.disgaea1.common;

import d1data;
import disgaeareporter.disgaea1;

import memmux : readStruct = read;

import std.bitmanip : bitmanipRead = read, Endian;
import std.conv;
import std.file;
import std.range;
import std.stdio : writefln, writeln;
import std.traits;
import std.typecons;

static immutable d1SteamID = "405900";

//enum SharkPortSaveType {
//	standard
//}
//import std.datetime;
//struct SharkPortSaveDir {
//	ushort entryLength;
//	string name;
//	uint numEntries;
//	ubyte[8] unknown;
//	ushort mode;
//	ushort unknown2;
//	DateTime created;
//	DateTime modified;
//	ubyte[] unknown3;
//}
//struct SharkPortSaveFile {
//	ushort entryLength;
//	string name;
//	uint length;
//	ubyte[8] unknown;
//	ushort mode;
//	ushort unknown2;
//	DateTime created;
//	DateTime modified;
//	ubyte[] unknown3;
//	ubyte[] data;
//}
//struct SharkPortSave {
//	SharkPortSaveType type;
//	string dirName;
//	string comment;
//	string date;
//	uint fileLength;
//	SharkPortSaveDir dir;
//	SharkPortSaveFile[] files;
//	uint checksum;
//}
//auto readSharkPortSave(const ubyte[] data) {

//}


align(1)
struct Resistance {
	align(1):
	ushort strength;
}
static assert(Resistance.sizeof == 2);

align(1)
struct Innocent {
	align(1):
	ushort level;
	ubyte type;
	ubyte uniquer;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"Lv%s%s %s"(sink, level > 10000 ? level-10000 : level, level > 10000 ? "+" : "", type.innocentName);
	}
}
static assert(Innocent.sizeof == 4);
void fooi() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Innocent().toString(buf);
}
align(1)
struct Stats {
	align(1):
	uint hp;
	uint sp;
	uint attack;
	uint defense;
	uint intelligence;
	uint speed;
	uint hit;
	uint resistance;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"HP: %s, SP: %s, Attack: %s, Defense: %s, Intelligence: %s, Speed: %s, Hit: %s, Resistance: %s"(sink, hp, sp, attack, defense, intelligence, speed, hit, resistance);
	}
}
static assert(Stats.sizeof == 32);

align(1)
struct BaseItemStats {
	align(1):
	ushort hp;
	ushort sp;
	ushort attack;
	ushort defense;
	ushort intelligence;
	ushort speed;
	ushort hit;
	ushort resistance;
}
static assert(BaseItemStats.sizeof == 16);

align(1)
struct BaseCharacterStats {
	align(1):
	ubyte hp;
	ubyte sp;
	ubyte attack;
	ubyte defense;
	ubyte intelligence;
	ubyte speed;
	ubyte hit;
	ubyte resistance;
}
static assert(BaseCharacterStats.sizeof == 8);

enum Defeated {
	itemGeneral = 1,
	itemKing = 2,
	unknown = 4,
	unknown2 = 8,
	unknown3 = 16,
	unknown4 = 32,
	unknown5 = 64,
	unknown6 = 128,
	unknown7 = 256,
	unknown8 = 512,
	unknown9 = 1024,
	unknown10 = 2048,
	unknown11 = 4096
}
align(1)
struct MapClearData {
	align(1):
	ushort clears;
	ushort kills;
	ushort mapID;
	ubyte bonusRank;
	ubyte unknown;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"%s - Clears: %s, Kills: %s"(mapID.mapName, clears, kills);
		debug(unknowns) {
			sink.formattedWrite!", Unknown: %s"(unknown);
		}
	}
}

align(1)
struct Senator {
	align(1):
	ushort level;
	ushort classID;
	ushort attendance;
	ushort timesKilled;
	ubyte nameBank;
	ubyte nameIndex;
	ubyte unknown;
	ushort rarityPreference;
	ubyte[16] sjisName;
	ubyte unknown2;
	byte favour;
	ubyte unknown3;
	string name() const {
		return sjisDec(sjisName[]);
	}
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"%s (Level %s %s)\n\t"(name, level, classID.className);
		sink.formattedWrite!"%s (%s)\n"(favour.favourString, favour);
		if (timesKilled > 0) {
			sink.formattedWrite!"\tKilled %s time%s\n"(timesKilled, timesKilled > 1 ? "s" : "");
		}
		debug(unknowns) sink.formattedWrite!"%s"([unknown, unknown2, unknown3]);
	}
}

private void func2() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Senator().toString(buf);
}

enum Rarity : ubyte {
	common = 1,
	rare = 2,
	legendary = 4
}

void printCharacterData(alias Game)(const ubyte[] data) {
	import std.algorithm : until;
	static if (is(Game == PS2Game)) {
		ps2Chars = data[Game.charOffset..(Game.charOffset + Game.numChars * Game.charSize)].readStruct!(Game.CharactersType).characters[];
	} else {
		chars = data[Game.charOffset..(Game.charOffset + Game.numChars * Game.charSize)].readStruct!(Game.CharactersType).characters[];
	}
	foreach (chara; chars.until!(x => !shouldPrint(x))) {
		writeln(chara);
	}
}

void printSenators(alias Game)(const ubyte[] data) {
	static if (is(Game == PCGame)) {
		foreach (senator; data[Game.senatorOffset..(Game.senatorOffset + Game.numSenators * Game.senatorSize)].readStruct!(Game.SenatorsType).senators[]) {
			if (senator.classID == 0) {
				break;
			}
			if (senator.attendance == 0) {
				continue;
			}
			writeln(senator);
		}
	}
}

bool shouldPrint(T)(T data) {
	import std.algorithm : among;
	debug(printall) {
		return true;
	} else {
		return data.class_.among(0, 2906, 2918) == 0;
	}
}


enum WeaponTypes {
	Fist,
	Sword,
	Spear,
	Bow,
	Gun,
	Axe,
	Rod,
	Monster
}


string skillName(ushort id) {
	if (id in d1skillNames) {
		return d1skillNames[id];
	}
	return "Unknown skill "~id.to!string(16);
}

string className(ushort id) {
	if (id in d1classes) {
		return d1classes[id];
	}
	return "Unknown class "~id.to!string(16);
}

string itemName(ushort id) {
	if (id in d1items) {
		return d1items[id];
	}
	return "Unknown item "~id.to!string(16);
}
string mapName(ushort id) {
	if (id in d1mapNames) {
		return d1mapNames[id];
	}
	return "Unknown map "~id.to!string(16);
}
string innocentName(const ushort id) {
	import std.conv : to;
	if (id in d1innocents) {
		return d1innocents[id];
	}
	return "Unknown specialist "~id.to!string(16);
}

string favourString(const byte input) {
	switch (input) {
		case -128: .. case -41: return "Loathe";
		case -40: .. case -27: return "Total opposition";
		case -26: .. case -17: return "Strongly against";
		case -16: .. case -12: return "Against";
		case -11: .. case -6: return "Leaning no";
		case -5: .. case 3: return "Either way";
		case 4: .. case 10: return "Leaning yes";
		case 11: .. case 15: return "In favor of";
		case 16: .. case 24: return "Strongly for";
		case 25: .. case 38: return "Total support";
		case 39: .. case 127: return "Love";
		default: return "Unknown";
	}
}

string sjisDec(const ubyte[] data) {
	import sjis : parseSJIS;
	auto str = parseSJIS(data);
	string output;
	foreach(dchar chr; str) {
		if (chr >= '！' && (chr <= '～')) {
			output ~= chr - 0xFEE0;
		} else if (chr == '　') {
			output ~= ' ';
		} else if (chr == '〜') {
			output ~= '~';
		} else {
			output ~= chr;
		}
	}
	return output;
}

unittest {
	auto data = cast(ubyte[])[0x82, 0x6B, 0x82, 0x81, 0x82, 0x88, 0x82, 0x81, 0x82, 0x92, 0x82, 0x8C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
	assert(sjisDec(data) == "Laharl");
}


