module disgaeareporter.common;

import disgaeareporter.disgaea1;
import disgaeareporter.disgaea2;

import std.stdio : File;
import std.range;
import std.traits : isArray, isSomeChar, Select;

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
	static if (hasMember!(Game, "itemWorldLevels")) {
		output.writefln!"Max Item World Level Cleared: %s"(game.itemWorldLevels);
	}
	static if (hasMember!(Game, "totalItemWorldLevels")) {
		output.writefln!"Total Item World Levels Cleared: %s"(game.totalItemWorldLevels);
	}
	static if (hasMember!(Game, "itemRate")) {
		output.writefln!"Item Rate: %s%%"(game.itemRate);
	}
	static if (hasMember!(Game, "defeated")) {
		foreach (ubyte bit; 0..Game.defeated.sizeof*8) {
			if ((cast(ulong)game.defeated) & (1<<bit)) {
				output.writefln!"Defeated %s"(Game.defeatedStr(bit));
			}
		}
	}
	output.writeln();
	static if (hasMember!(Game, "characters")) {
		output.writeln("-Characters-");
		foreach (character; game.characters) {
			output.printCharacter(1, character);
		}
	}
	static if (hasMember!(Game, "areas")) {
		output.writefln("-Map Clears-\n\n%(%s\n%)", game.areas[].filter!(x => x.clears > 0));
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
		output.writeln("-Items-");
		output.writeln();
		output.writeln("Bag:");
		foreach (item; game.bagItems) {
			output.printItem(1, item);
		}
	}
	static if (hasMember!(Game, "warehouseItems")) {
		output.writeln("Warehouse:");
		foreach (item; game.warehouseItems) {
			output.printItem(1, item);
		}
	}
	static if (hasMember!(Game, "innocentWarehouse")) {
		output.writefln("-Innocent Warehouse-\n\n%(\t%s\n%)", game.innocentWarehouse);
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

void printCharacter(T)(File output, int indentCount, T character) {
		import std.algorithm : filter;
		import std.range : lockstep;
		import std.traits : hasMember;

		void indentedPrint(string fmt = "%s", T...)(int offset, T args) {
			output.writef!"%-(%s%)"("\t".repeat(indentCount+offset));
			output.writefln!fmt(args);
		}
		static if (hasMember!(T, "className")) {
			auto className = character.className;
		} else {
			auto className = "Unknown";
		}

		static if (hasMember!(T, "name")) {
			auto charName = character.name;
		} else {
			auto charName = "Unknown";
		}

		static if (hasMember!(T, "level")) {
			auto level = character.level;
		} else {
			auto level = "???";
		}
		indentedPrint!"%s (Lv%s %s)"(-1, charName, level, className);

		static if (hasMember!(T, "evilities")) {
			indentedPrint!"Evilities: %(%s, %)"(0, character.evilities);
		}

		static if (hasMember!(T, "mana")) {
			static if (hasMember!(T, "rank")) {
				indentedPrint!"Rank: %s, Mana: %s"(0, character.rank, character.mana);
			} else {
				indentedPrint!"Mana: %s"(0, character.mana);
			}
		}
		static if (hasMember!(T, "numReincarnations") && hasMember!(T, "storedLevels")) {
			indentedPrint!"Reincarnations: %s, Stored Levels: %s"(0, character.numReincarnations, character.storedLevels);
		}
		static if (hasMember!(T, "resist")) {
			indentedPrint!"Elemental Affinity: %s"(0, character.resist);
		}
		static if (hasMember!(T, "baseStats")) {
			indentedPrint!"Base Stats: %s"(0, character.baseStats);
		}
		static if (hasMember!(T, "stats")) {
			indentedPrint(0, character.stats);
		}
		static if (hasMember!(T, "miscStats")) {
			indentedPrint(0, character.miscStats);
		}
		static if (hasMember!(T, "aptitudes")) {
			indentedPrint!"Aptitudes: %s"(0, character.aptitudes);
		}
		static if (hasMember!(T, "maxDamage") && hasMember!(T, "totalDamage")) {
			indentedPrint!"Max Damage: %s, Total Damage: %s"(0, character.maxDamage, character.totalDamage);
		}
		static if (hasMember!(T, "numKills") && hasMember!(T, "numDeaths")) {
			indentedPrint!"Enemy Kill Count: %s, Death Count: %s"(0, character.numKills, character.numDeaths);
		}
		static if (hasMember!(T, "training")) {
			indentedPrint!"Training: %s"(0, character.training);
		}
		static if (hasMember!(T, "equipmentMastery")) {
			auto masteries = character.equipmentMastery.range.filter!(x => x.level > 0);
			if (!masteries.empty) {
				indentedPrint(0, "Equipment mastery:");
				foreach (mastery; masteries) {
					indentedPrint!"Lv%s %s"(1, mastery.level, mastery.type);
				}
			}
		}
		static if (hasMember!(T, "equipment")) {
			auto equips = character.equipment[].filter!(x => x.isValid);
			if (!equips.empty) {
				indentedPrint(0, "Equipment:");
				foreach (item; equips) {
					output.printItem(indentCount+1, item);
				}
			}
		}
		static if (hasMember!(T, "skills")) {
			static if (isArray!(typeof(T.skills))) {
				auto skills = character.skills[].filter!(x => x.isValid);
				if (!skills.empty) {
					indentedPrint(0, "Abilities:");
					foreach (skill; skills) {
						indentedPrint(1, skill);
					}
				}
			} else {
				if (!character.skills.range.empty) {
					indentedPrint(0, "Abilities:");
					foreach (skill; character.skills.range) {
						indentedPrint(1, skill);
					}
				}
			}
		}

		output.printUnknowns(indentCount+1, character);
}

void printItem(ItemType)(File output, uint indentCount, const ItemType item) {
	import std.algorithm : filter;
	import std.traits : hasMember;

	void indentedPrint(string fmt = "%s", T...)(int offset, T args) {
		output.writef!"%-(%s%)"("\t".repeat(indentCount+offset));
		output.writef!fmt(args);
	}

	static if (hasMember!(ItemType, "level")) {
		auto level = item.level;
	} else {
		auto level = "?";
	}
	static if (hasMember!(ItemType, "rarity")) {
		indentedPrint!"Lv%s %s (Rarity: %s)"(0, level, item.name, item.rarity);
	} else {
		indentedPrint!"Lv%s %s"(0, level, item.name);
	}
	static if (hasMember!(ItemType, "innocents")) {
		auto innocents = item.innocents[].filter!(x => x.isValid);
		if (!innocents.empty) {
			output.writef!" - %(%s, %)"(innocents);
		}
	}
	output.write("\n");

	output.printUnknowns(indentCount+1, item);
}

void printUnknowns(T)(File output, uint indentCount, T data) {
	debug (unknowns) {
		void indentedPrint(string fmt = "%s", T...)(int offset, T args) {
			output.writef!"%-(%s%)"("\t".repeat(indentCount+offset));
			output.writefln!fmt(args);
		}
		output.writeln("\tUnknown data:");
		import std.traits : getSymbolsByUDA;
		static foreach (i; 0..getSymbolsByUDA!(T, Unknown).length) {
			indentedPrint!"%s: (%s)"(1, __traits(identifier, getSymbolsByUDA!(T, Unknown)[i]).stringof, mixin("data."~__traits(identifier, getSymbolsByUDA!(T, Unknown)[i])));
		}
	}
}

void printHTML(T)(File output, T data) {
	version(html) {
		import diet.html;
		auto range = output.lockingTextWriter;
		range.compileHTMLDietFile!("report.dt", data)();
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

alias BaseCharacterStats = StatsImpl!ubyte;
static assert(BaseCharacterStats.sizeof == 8);

alias BaseCharacterStatsLater = ModernStatsImpl!ubyte;
static assert(BaseCharacterStatsLater.sizeof == 8);

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
align(1)
struct ModernResistance {
	align(1):
	byte fire;
	byte wind;
	byte ice;
	byte star;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"Fire - %s%%, Wind - %s%%, Ice - %s%%, Star - %s%%"(fire, wind, ice, star);
	}
}

align(1)
struct EquipmentMastery {
	align(1):
	ubyte[8] masteryLevels;
	ubyte[8] masteryRates;

	auto range() const {
		static struct Result {
			ubyte[8] masteryLevels;
			ubyte[8] masteryRates;
			size_t i;
			auto front() const {
				import std.typecons : tuple;
				return tuple!("level", "rate", "type")(masteryLevels[i], masteryRates[i], cast(WeaponTypes)i);
			}
			bool empty() const {
				return i >= 8;
			}
			void popFront() {
				i++;
			}
		}
		return Result(masteryLevels, masteryRates);
	}
}
align(1)
struct EquipmentMasteryD2 {
	align(1):
	ubyte[9] masteryLevels;
	ubyte[9] masteryRates;

	auto range() const {
		static struct Result {
			ubyte[9] masteryLevels;
			ubyte[9] masteryRates;
			size_t i;
			auto front() const {
				import std.typecons : tuple;
				return tuple!("level", "rate", "type")(masteryLevels[i], masteryRates[i], cast(WeaponTypesD2)i);
			}
			bool empty() const {
				return i >= 9;
			}
			void popFront() {
				i++;
			}
		}
		return Result(masteryLevels, masteryRates);
	}
}

align(1)
struct EquipmentMastery5 {
	align(1):
	struct Mastery {
		ushort exp;
		ushort unknown;
		ubyte level;
		ubyte rate;
		ubyte rate2;
		ubyte unknown2;
	}
	Mastery[10] masteries;
	auto range() const {
		static struct Result {
			Mastery[10] masteries;
			size_t i;
			auto front() const {
				import std.typecons : tuple;
				return tuple!("level", "rate", "type")(masteries[i].level, masteries[i].rate, equipmentTypes5[i]);
			}
			bool empty() const {
				return i >= 10;
			}
			void popFront() {
				i++;
			}
		}
		return Result(masteries);
	}
}

alias Stats = StatsImpl!int;
static assert(Stats.sizeof == 32);

alias LongStats = StatsImpl!long;

align(1)
struct StatsImpl(T) {
	align(1):
	T hp;
	T sp;
	T attack;
	T defense;
	T intelligence;
	T speed;
	T hit;
	T resistance;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"HP: %s, SP: %s, Attack: %s, Defense: %s, Intelligence: %s, Speed: %s, Hit: %s, Resistance: %s"(sink, hp, sp, attack, defense, intelligence, speed, hit, resistance);
	}
}

alias ModernStats = ModernStatsImpl!long;
static assert(ModernStats.sizeof == 64);

align(1)
struct ModernStatsImpl(Type) {
	align(1):
	Type hp;
	Type sp;
	Type attack;
	Type defense;
	Type intelligence;
	Type resistance;
	Type hit;
	Type speed;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		formattedWrite!"HP: %s, SP: %s, Attack: %s, Defense: %s, Intelligence: %s, Speed: %s, Hit: %s, Resistance: %s"(sink, hp, sp, attack, defense, intelligence, speed, hit, resistance);
	}
}

align(1)
struct Aptitudes {
	align(1):
	ushort hp;
	ushort sp;
	ushort attack;
	ushort defense;
	ushort intelligence;
	ushort resistance;
	ushort hit;
	ushort speed;
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

align(1)
struct MiscStatsExpanded {
	align(1):
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
	ubyte[8] unknown;
	ubyte range;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"Counter: %s, MV: %s, JM: %s, Throw: %s, Crit: %s, Range: %s"(counter, mv, jm, throw_, crit, range);
		debug(unknowns) {
			sink.formattedWrite!", Unknown: %s"(unknown);
		}
	}
}

align(1)
struct Skills(size_t count, alias Names) {
	align(1):
	uint[count] skillEXP;
	ushort[count] skills;
	ubyte[count] skillLevels;

	auto range() const {
		static struct SkillRange {
			uint[count] skillEXP;
			ushort[count] skills;
			ubyte[count] skillLevels;
			size_t index;
			auto front() const {
				assert(index < count);
				static struct Result {
					uint exp;
					ushort id;
					ubyte level;
					void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
						import std.format : formattedWrite;
						if (level == 255) {
							sink.put("Learning");
						} else {
							sink.formattedWrite!"Lv%s"(level);
						}
						sink.formattedWrite!" %s (%s EXP)"(__ctfe ? "" : Names(id), exp);
					}
				}
				return Result(skillEXP[index], skills[index], skillLevels[index]);
			}
			void popFront() {
				index++;
			}
			bool empty() {
				return (skills[index] == 0) || (index >= count);
			}
		}
		return SkillRange(skillEXP, skills, skillLevels);
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

enum WeaponTypesD2 {
	Fist,
	Sword,
	Spear,
	Bow,
	Gun,
	Axe,
	Rod,
	Book,
	Monster
}
static immutable string[] equipmentTypes5 = [
	"Fist",
	"Sword",
	"Spear",
	"Bow",
	"Gun",
	"Axe",
	"Staff",
	"Monster (Phys)",
	"Monster (Mag)",
	"Armour"
];

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
