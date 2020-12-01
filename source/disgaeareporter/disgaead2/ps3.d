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
		sink.formattedWrite!"Lv%s%s %s"(level, isSubdued ? "+" : "", name);
	}
	bool isValid() const {
		return type != 0;
	}
	bool isSubdued() const {
		return (unknown[1]&1) == 1;
	}
	string name() const {
		return dd2innocents(type);
	}
}

align(1)
struct Item {
	align(1):
	uint unknown1;
	Innocent[6] innocents;
	@Unknown ubyte[4] unknown2;
	ModernStats stats;
	ModernStats baseStats;
	ushort nameID;
	ushort level;
	@Unknown ubyte[53] unknown3;
	char[64] _name;
	@Unknown ubyte[95] unknown4;
	bool isValid() const {
		return nameID != 0;
	}
	auto name() const {
		return _name.fromStringz;
	}
	string rarity() const {
		return "?";
	}
}

static assert(Item.sizeof == 0x190);
static assert(Item.nameID.offsetof == 0xB8);
static assert(Item._name.offsetof == 0xF1);

align(1)
struct Character {
	align(1):
	ulong exp;

	Item[4] equipment;
	char[52] _name;
	char[52] _className;
	@Unknown ubyte[180] unknown;
	Skills!(256, dd2skillNames) skills;
	@Unknown ubyte[516] unknown2;
	ulong currentHP;
	ulong currentSP;
	ModernStats stats;
	ModernStats realStats;
	@Unknown ubyte[8] unknown3;
	BaseCharacterStatsLater baseStats;
	@Unknown ubyte[36] unknown4;
	EquipmentMasteryD2 equipmentMastery;
	@Unknown ubyte[10] unknown5;
	uint mana;
	ushort level;
	@Unknown ubyte[18] unknown6;
	Resistance baseResist;
	Resistance resist;
	MiscStatsExpanded miscStats;
	@Unknown ubyte[23] unknown7;
	ulong numKills;
	ulong numDeaths;
	ulong maxDamage;
	ulong totalDamage;
	@Unknown ubyte[30] unknown8;
	ubyte _training;
	@Unknown ubyte unknown9;
	Evility[2] _evilities;
	@Unknown ubyte[808] unknown10;
	Aptitudes aptitudes;
	Aptitudes aptitudes2;
	@Unknown ubyte[1348] unknown11;

	auto name() const {
		return _name.fromStringz;
	}
	auto className() const {
		return _className.fromStringz;
	}
	auto training() const {
		return _training.trainingName;
	}
	auto evilities() const {
		import std.algorithm : filter;
		return _evilities[].filter!(x => x.isValid);
	}
}
static assert(Character.sizeof == 0x1A60);
static assert(Character._name.offsetof == 0x648);
static assert(Character.skills.offsetof == 0x764);
static assert(Character.stats.offsetof == 0x1078);
static assert(Character.baseStats.offsetof == 0x1100);
static assert(Character.level.offsetof == 0x114C);
static assert(Character.baseResist.offsetof == 0x1160);
static assert(Character.maxDamage.offsetof == 0x11A0);
static assert(Character._training.offsetof == 0x11CE);
static assert(Character._evilities.offsetof == 0x11D0);
static assert(Character.aptitudes.offsetof == 0x14FC);

align(1)
struct Area {
	align(1):
	@Unknown ubyte[0x1A] unknown1;
	uint clears;
	ushort kills;
	@Unknown ushort unknown2;
	ushort bonusRank;
	@Unknown ubyte[2] unknown3;
	ZeroString!0x38 name;
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format;
		sink.formattedWrite!"%s - Clears: %s, Kills: %s"(name, clears, kills);
	}
}
static assert(Area.sizeof == 0x5E);

align(1)
struct DD2PS3 {
	align(1):
	@Unknown ubyte[8] unknown1;
	Playtime playtime;
	ZeroString!34 fileName;
	@Unknown ubyte[1337] unknown2;
	ulong totalHL;
	@Unknown ubyte[16] unknown3;
	ulong hpRecovered;
	ulong spRecovered;
	@Unknown ubyte[16] unknown4;
	Character[128] _characters;
	@Unknown ubyte[1530] unknown5;
	Area[199] areas;
	@Unknown ubyte[20588] unknown6;
	Item[999] _items;
	@Unknown ubyte[72164] unknown7;
	ushort charCount;
	@Unknown ubyte[6770] unknown8;
	ulong maxDamage;
	ulong totalDamage;
	ushort geoCombo;
	@Unknown ubyte[6] unknown9;
	uint enemiesKilled;
	uint enemiesKilledCopy;
	ushort maxLevel;
	uint reincarnation;
	ushort itemWorldVisits;
	ushort itemWorldLevels;
	@Unknown ushort unknown10;
	uint totalItemWorldLevels;
	@Unknown ubyte[1832] unknown11;
	Innocent[256] _innocentWarehouse;
	auto characters() const {
		return _characters[0..charCount];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _items[].filter!(x => x.isValid);
	}
	auto innocentWarehouse() const {
		import std.algorithm : filter;
		return _innocentWarehouse[].filter!(x => x.isValid);
	}
	enum gameTitle = "Disgaea D2 (PS3)";
}

static assert(DD2PS3.hpRecovered.offsetof == 0x580);
static assert(DD2PS3._characters.offsetof == 0x5A0);
static assert(DD2PS3.areas.offsetof == 0xD3B9A);
static assert(DD2PS3._items.offsetof == 0xDD518);
static assert(DD2PS3.charCount.offsetof == 0x1507EC);
static assert(DD2PS3.geoCombo.offsetof == 0x152270);
static assert(DD2PS3._innocentWarehouse.offsetof == 0x1529B8);

unittest {
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	import std.array : array;
	auto data = loadData!DD2PS3(cast(immutable(ubyte)[])import("dd2ps3-raw.DAT"));
	assert(data.characters.length == 20);

	with(data.characters[0]) {
		assert(name == "Laharl");
		assert(level == 27);
		with(skills.range.front) {
			assert(id == 0x00C9);
			assert(exp == 94);
		}
		assert(exp == 58793);
		assert(mana == 416);
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
		assert(evilities.array.length == 1);
		assert(evilities.array[0] == 10);
	}
	with (data.areas[97]) {
		assert(name == "Silver Witch");
		assert(kills == 45);
		assert(clears == 11);
		assert(bonusRank == 6);
	}

	with(data._items[0]) {
		assert(name == "Bamboo Water Gun");
	}
}