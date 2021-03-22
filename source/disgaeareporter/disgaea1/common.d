module disgaeareporter.disgaea1.common;

import d1data;
import disgaeareporter.common;
import disgaeareporter.disgaea1;

import reversineer : Offset, VerifyOffsets;
import std.range;

static immutable d1SteamID = "405900";

align(1)
struct StatusResistance {
	align(1):
	ushort strength;
}
mixin VerifyOffsets!(StatusResistance, 2);

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
mixin VerifyOffsets!(Innocent, 4);

void fooi() {
	import std.outbuffer;
	auto buf = new OutBuffer;
	Innocent().toString(buf);
}

alias BaseItemStats = StatsImpl!short;
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
