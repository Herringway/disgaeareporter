module disgaeareporter.common;

import disgaeareporter.disgaea1;
import disgaeareporter.disgaea2;

import std.stdio : File;
import std.range;
import std.traits : isSomeChar;

enum Unknown;

void printData(Game)(File output, Game* game) {
	import std.algorithm : filter, map, makeIndex, min, sort, sum;
	import std.array : array;
	import std.range : indexed, iota;
	import std.stdio : writefln, writeln;
	import std.traits : hasMember;
	import std.typecons : BitFlags;

	bool sortSenatorsByFavour = true;
	output.writeln("-Game stats-\n");
	static if (hasMember!(Game, "playtime")) {
		output.writefln!"Time Played: %s"(game.playtime);
	}
	static if (hasMember!(Game, "totalHL")) {
		output.writefln!"HL: %s"(game.totalHL);
	}
	static if (hasMember!(Game, "hpRecovered")) {
		output.writefln!"Total HP Recovered: %s"(game.hpRecovered);
	}
	static if (hasMember!(Game, "spRecovered")) {
		output.writefln!"Total SP Recovered: %s"(game.spRecovered);
	}
	static if (hasMember!(Game, "revived")) {
		output.writefln!"Total Dead Revived: %s"(game.revived);
	}
	static if (hasMember!(Game, "allyKillCount")) {
		output.writefln!"Ally Kills: %s"(game.allyKillCount);
	}
	static if (hasMember!(Game, "maxDamage")) {
		output.writefln!"Max Damage: %s"(game.maxDamage);
	}
	static if (hasMember!(Game, "totalDamage")) {
		output.writefln!"Total Damage: %s"(game.totalDamage);
	}
	static if (hasMember!(Game, "geoCombo")) {
		output.writefln!"Biggest Geo Combo: %s"(game.geoCombo);
	}
	static if (hasMember!(Game, "enemiesKilled")) {
		output.writefln!"Enemies Killed: %s"(game.enemiesKilled);
	}
	static if (hasMember!(Game, "maxLevel")) {
		output.writefln!"Highest Level Reached: %s"(game.maxLevel);
	}
	static if (hasMember!(Game, "itemWorldVisits")) {
		output.writefln!"Item World Visits: %s"(game.itemWorldVisits);
	}
	static if (hasMember!(Game, "itemRate")) {
		output.writefln!"Item Rate: %s%%"(game.itemRate);
	}
	static if (hasMember!(Game, "defeated")) {
		if (game.defeated & Defeated.itemGeneral) {
			output.writeln("Defeated Item General");
		}
		if (game.defeated & Defeated.itemKing) {
			output.writeln("Defeated Item King");
		}
		if (game.defeated & Defeated.itemGod) {
			output.writeln("Defeated Item God");
		}
		if (game.defeated & Defeated.itemGod2) {
			output.writeln("Defeated Item God 2");
		}
		if (game.defeated & Defeated.astroCarter) {
			output.writeln("Defeated Astro Carter");
		}
		if (game.defeated & Defeated.prinnyGod) {
			output.writeln("Defeated Prinny God");
		}
		if (game.defeated & Defeated.priere) {
			output.writeln("Defeated Priere");
		}
		if (game.defeated & Defeated.marjoly) {
			output.writeln("Defeated Marjoly");
		}
		if (game.defeated & Defeated.baal) {
			output.writeln("Defeated Baal");
		}
		if (game.defeated & Defeated.uberPrinnyBaal) {
			output.writeln("Defeated Uber Prinny Baal");
		}
		if (game.defeated & Defeated.zetta) {
			output.writeln("Defeated Zetta");
		}
		if (game.defeated & Defeated.unknown10) {
			output.writeln("Defeated Unknown 10");
		}
		if (game.defeated & Defeated.adellRozalin) {
			output.writeln("Defeated Adell & Rozalin");
		}
	}
	output.writeln();
	static if (hasMember!(Game, "mapClears")) {
		output.writefln("-Map Clears-\n\n%(%s\n%)", game.mapClears[].filter!(x => x.clears > 0));
	}
	static if (hasMember!(Game, "characters")) {
		output.writefln("-Characters-\n\n%(%s\n%)", game.characters);
	}
	static if (hasMember!(Game, "senators")) {
		auto index = new size_t[](game.senators.length);
		if (sortSenatorsByFavour) {
			makeIndex!((x,y) => x.favour > y.favour)(game.senators[], index);
		} else {
			index = iota(0,game.senators.length).array;
		}
		output.writefln("-Senators-\n\n%(%s\n%)", game.senators[].indexed(index).filter!(x => x.attendance > 0));
		auto average = (cast(double)game.senators[].filter!(x => x.attendance > 0).map!(x => x.favour).sum) / (cast(double)game.senators.length);
		output.writefln!"Average favour: %s\n"(Favour(cast(byte)average));
	}
	static if (hasMember!(Game, "bagItems")) {
		output.writefln("-Items-\n\nBag:\n%(\t%s\n%)", game.bagItems);
	}
	static if (hasMember!(Game, "warehouseItems")) {
		output.writefln("Warehouse:\n%(\t%s\n%)", game.warehouseItems);
	}
	static if (hasMember!(Game, "itemRecords")) {
		output.writeln("\n-Item Records-\n");
		foreach (id, record; game.itemRecords) {
			if (!record) {
				if (game.itemRecordName(id) != "") {
					output.writefln!"% 3s - % 3s. ????????????????????"(id/game.itemRecordAlignment, (id%game.itemRecordAlignment)+1);
				}
			} else {
				output.writefln!"% 3s - % 3s. % -20s - % 1s% 1s% 1s"(id/game.itemRecordAlignment, (id%game.itemRecordAlignment)+1, game.itemRecordName(id), (record & Rarity.common) ? "★" : "", (record & Rarity.rare) ? "★" : "", (record & Rarity.legendary) ? "★" : "");
			}
		}
	}
	debug (unknowns) {
		output.writeln("\n-Unknown data-\n");
		import std.traits : getSymbolsByUDA;
		static foreach (unknown; getSymbolsByUDA!(Game, Unknown)) {
			output.writeln(mixin("game."~unknown.stringof));
		}
	}
}

align(1)
struct Favour {
	align(1):
	byte raw;
	alias raw this;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		switch (raw) {
			case -128: .. case -41: sink.put("Loathe"); break;
			case -40: .. case -27: sink.put("Total opposition"); break;
			case -26: .. case -17: sink.put("Strongly against"); break;
			case -16: .. case -12: sink.put("Against"); break;
			case -11: .. case -6: sink.put("Leaning no"); break;
			case -5: .. case 3: sink.put("Either way"); break;
			case 4: .. case 10: sink.put("Leaning yes"); break;
			case 11: .. case 15: sink.put("In favor of"); break;
			case 16: .. case 24: sink.put("Strongly for"); break;
			case 25: .. case 38: sink.put("Total support"); break;
			case 39: .. case 127: sink.put("Love"); break;
			default: sink.put("Unknown"); break;
		}
		sink.formattedWrite!" (%s)"(raw);
	}
}

alias BaseCharacterStats = StatsImpl!(ubyte, false);
static assert(BaseCharacterStats.sizeof == 8);

alias BaseCharacterStatsLater(bool bigEndian) = ModernStatsImpl!(ubyte, bigEndian);
static assert(BaseCharacterStatsLater!true.sizeof == 8);

align(1)
struct Resistance {
	align(1):
	byte fire;
	byte wind;
	byte ice;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"Fire - %s%%, Wind - %s%%, Ice - %s%%"(fire, wind, ice);
	}
}

alias Stats = StatsImpl!(int, false);
static assert(Stats.sizeof == 32);

alias LongStats(bool bigEndian) = StatsImpl!(long, bigEndian);

align(1)
struct StatsImpl(T, bool isBigEndian) {
	static if (isBigEndian) {
		alias Endian = BigEndian;
	} else {
		alias Endian = LittleEndian;
	}
	align(1):
	Endian!T hp;
	Endian!T sp;
	Endian!T attack;
	Endian!T defense;
	Endian!T intelligence;
	Endian!T speed;
	Endian!T hit;
	Endian!T resistance;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"HP: %s, SP: %s, Attack: %s, Defense: %s, Intelligence: %s, Speed: %s, Hit: %s, Resistance: %s"(sink, hp, sp, attack, defense, intelligence, speed, hit, resistance);
	}
}

alias ModernStats(bool bigEndian) = ModernStatsImpl!(long, bigEndian);
static assert(ModernStats!true.sizeof == 64);

align(1)
struct ModernStatsImpl(Type, bool isBigEndian) {
	static if (isBigEndian) {
		alias Endian = BigEndian;
	} else {
		alias Endian = LittleEndian;
	}
	align(1):
	Endian!Type hp;
	Endian!Type sp;
	Endian!Type attack;
	Endian!Type defense;
	Endian!Type intelligence;
	Endian!Type resistance;
	Endian!Type hit;
	Endian!Type speed;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"HP: %s, SP: %s, Attack: %s, Defense: %s, Intelligence: %s, Speed: %s, Hit: %s, Resistance: %s"(sink, hp, sp, attack, defense, intelligence, speed, hit, resistance);
	}
}

align(1)
struct Aptitudes(bool isBigEndian) {
	static if (isBigEndian) {
		alias Endian = BigEndian;
	} else {
		alias Endian = LittleEndian;
	}
	align(1):
	Endian!ushort hp;
	Endian!ushort sp;
	Endian!ushort attack;
	Endian!ushort defense;
	Endian!ushort intelligence;
	Endian!ushort resistance;
	Endian!ushort hit;
	Endian!ushort speed;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"HP: %s%%, SP: %s%%, Attack: %s%%, Defense: %s%%, Intelligence: %s%%, Speed: %s%%, Hit: %s%%, Resistance: %s%%"(sink, hp, sp, attack, defense, intelligence, speed, hit, resistance);
	}
}

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
struct MiscStats {
	align(1):
	ubyte baseJM;
	ubyte jm;
	ubyte baseMV;
	ubyte mv;
	ubyte baseCounter;
	ubyte counter;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"Counter: %s, MV: %s, JM: %s"(counter, mv, jm);
	}
}

enum Rarity : ubyte {
	common = 1,
	rare = 2,
	legendary = 4
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

struct ZeroString(size_t length) {
	import siryul : SerializationMethod;
	char[length] raw = 0;
	alias toString this;
	@SerializationMethod
	auto toString() const {
		return raw[].fromStringz;
	}
}


string fromStringz(Char)(Char[] cString) if (isSomeChar!Char){
	import std.algorithm : countUntil;
	import std.string : representation;
	auto endIndex = cString.representation.countUntil('\0');
	auto str = cString[0..endIndex == -1 ? cString.length : endIndex];
	string output;
	foreach (dchar chr; str) {
		switch(chr) {
			case '　': output ~= ' '; break;
			case '．': output ~= '.'; break;
			case '，': output ~= ','; break;
			case '？': output ~= '?'; break;
			default: output ~= chr; break;
		}
	}
	return output;
}

unittest {
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	import std.conv : hexString;

	auto str = hexString!"41 64 65 6C 6C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00";
	assert(str.fromStringz == "Adell");
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

struct LittleEndian(T) {
	import siryul : SerializationMethod;
	ubyte[T.sizeof] raw;
	alias toInt this;
	@SerializationMethod
	auto toInt() const {
		import std.bitmanip : littleEndianToNative;
		if (__ctfe) {
			return 0;
		}
		return littleEndianToNative!T(raw);
	}
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"%s"(this.toInt());
	}
}
struct BigEndian(T) {
	import siryul : SerializationMethod;
	ubyte[T.sizeof] raw;
	alias toInt this;
	@SerializationMethod
	T toInt() const {
		import std.bitmanip : bigEndianToNative;
		if (__ctfe) {
			return 0;
		}
		return bigEndianToNative!T(raw);
	}
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"%s"(this.toInt());
	}
}

unittest {
	import std.outbuffer;
	auto buf = new OutBuffer;
	BigEndian!ushort().toString(buf);
}