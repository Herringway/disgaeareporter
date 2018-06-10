module disgaeareporter.disgaea1.common;

import d1data;
import disgaeareporter.disgaea1;
import disgaeareporter.common;

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
	ushort _level;
	ubyte type;
	ubyte uniquer;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"Lv%s%s %s"(sink, level, isSubdued ? "+" : "", name);
	}
	bool isValid() const {
		return type != 0;
	}
	ushort level() const {
		return _level > 10000 ? cast(ushort)(_level - 10000) : _level;
	}
	bool isSubdued() const {
		return _level > 10000;
	}
	string name() const {
		return d1innocents(type);
	}
}
static assert(Innocent.sizeof == 4);
void fooi() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Innocent().toString(buf);
}

alias BaseItemStats = StatsImpl!(short, false);
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
		sink.formattedWrite!"%s - Clears: %s, Kills: %s"(name, clears, kills);
		debug(unknowns) {
			sink.formattedWrite!", Unknown: %s"(unknown);
		}
	}
	string name() const {
		return d1mapNames(mapID);
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
	Favour favour;
	@Unknown ubyte unknown3;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		sink.formattedWrite!"%s (Level %s %s)\n\t"(name, level, d1classes(classID));
		sink.formattedWrite!"Favour: %s\n"(favour);
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

deprecated alias skillName = d1skillNames;
deprecated alias className = d1classes;
deprecated alias itemName = d1items;
deprecated alias mapName = d1mapNames;
deprecated alias innocentName = d1innocents;

static immutable defeatedStrings = [
	"Item General",
	"Item King",
	"Item God",
	"Item God 2",
	"Astro Carter",
	"Prinny God",
	"Priere",
	"Marjoly",
	"Baal",
	"Uber Prinny Baal",
	"Zetta",
	"Unknown 10",
	"Adell & Rozalin",
	"All extra bosses?",
];
string defeatedString(const ubyte id) {
	import std.conv : text;
	if (id >= defeatedStrings.length) {
		return "Unknown "~id.text;
	}
	return defeatedStrings[id];
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