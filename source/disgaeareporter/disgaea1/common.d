module disgaeareporter.disgaea1.common;

import d1data;
import disgaeareporter.disgaea1;
import disgaeareporter.common : favourString, Unknown;

import memmux : readStruct = read;

import std.bitmanip : bitmanipRead = read, Endian;
import std.conv;
import std.file;
import std.range;
import std.stdio : writefln, writeln;
import std.traits;
import std.typecons;

static immutable d1SteamID = "405900";

align(1)
struct StatusResistance {
	align(1):
	ushort strength;
}
static assert(StatusResistance.sizeof == 2);

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
	bool isValid() const {
		return type != 0;
	}
}
static assert(Innocent.sizeof == 4);
void fooi() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Innocent().toString(buf);
}

align(1)
struct BaseItemStats {
	align(1):
	short hp;
	short sp;
	short attack;
	short defense;
	short intelligence;
	short speed;
	short hit;
	short resistance;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"HP: %s, SP: %s, Attack: %s, Defense: %s, Intelligence: %s, Speed: %s, Hit: %s, Resistance: %s"(hp, sp, attack, defense, intelligence, speed, hit, resistance);
	}
}
static assert(BaseItemStats.sizeof == 16);

enum Defeated {
	itemGeneral = 1,
	itemKing = 2,
	itemGod = 4,
	itemGod2 = 8,
	astroCarter = 16,
	prinnyGod = 32,
	priere = 64,
	marjoly = 128,
	baal = 256,
	uberPrinnyBaal = 512,
	zetta = 1024,
	unknown10 = 2048,
	adellRozalin = 4096
}
align(1)
struct MapClearData {
	align(1):
	ushort clears;
	ushort kills;
	ushort mapID;
	ubyte bonusRank;
	@Unknown ubyte unknown;
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
	@Unknown ubyte unknown;
	ushort rarityPreference;
	SJISString!16 name;
	@Unknown ubyte unknown2;
	byte favour;
	@Unknown ubyte unknown3;
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

string sjisDec(const ubyte[] data) {
	import sjisish : toUTF;
	import std.algorithm : countUntil;
	import std.string : representation;
	auto str = toUTF(data);
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
	auto endIndex = output.representation.countUntil('\0');
	return output[0..endIndex == -1 ? output.length : endIndex];
}

unittest {
	auto data = cast(ubyte[])[0x82, 0x6B, 0x82, 0x81, 0x82, 0x88, 0x82, 0x81, 0x82, 0x92, 0x82, 0x8C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
	assert(sjisDec(data) == "Laharl");
}

struct SJISString(size_t length) {
	import siryul : SerializationMethod;
	ubyte[length] raw;
	alias toString this;
	@SerializationMethod
	auto toString() const {
		return sjisDec(raw[]);
	}
}

double itemStatsMultiplier(ulong level) {
	if (level <= 100) {
		return 1.0;
	} else if (level <= 500) {
		return cast(double)((level + 100) / 2) / 100.0;
	} else if (level <= 2000) {
		return cast(double)((level + 1000) / 5) / 100.0;
	} else {
		return cast(double)((level + 4000) / 10) / 100.0;
	}
}

unittest {
	assert(itemStatsMultiplier(100) == 1.0);
	assert(itemStatsMultiplier(500) == 3.0);
	assert(itemStatsMultiplier(2000) == 6.0);
	assert(itemStatsMultiplier(10000) == 14.0);
}