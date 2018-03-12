module disgaeareporter.common;

import disgaeareporter.disgaea1;
import disgaeareporter.disgaea2;

enum Unknown;

void printData(Game)(Game* game) {
	import std.algorithm : filter, map, makeIndex, min, sort, sum;
	import std.array : array;
	import std.range : indexed, iota;
	import std.stdio : writefln, writeln;
	import std.traits : hasMember;
	import std.typecons : BitFlags;

	bool sortSenatorsByFavour = true;
	writeln("-Game stats-\n");
	static if (hasMember!(Game, "playtime")) {
		writefln!"Time Played: %s"(game.playtime);
	}
	static if (hasMember!(Game, "totalHL")) {
		writefln!"HL: %s"(game.totalHL);
	}
	static if (hasMember!(Game, "hpRecovered")) {
		writefln!"Total HP Recovered: %s"(game.hpRecovered);
	}
	static if (hasMember!(Game, "spRecovered")) {
		writefln!"Total SP Recovered: %s"(game.spRecovered);
	}
	static if (hasMember!(Game, "revived")) {
		writefln!"Total Dead Revived: %s"(game.revived);
	}
	static if (hasMember!(Game, "allyKillCount")) {
		writefln!"Ally Kills: %s"(game.allyKillCount);
	}
	static if (hasMember!(Game, "maxDamage")) {
		writefln!"Max Damage: %s"(game.maxDamage);
	}
	static if (hasMember!(Game, "totalDamage")) {
		writefln!"Total Damage: %s"(game.totalDamage);
	}
	static if (hasMember!(Game, "geoCombo")) {
		writefln!"Biggest Geo Combo: %s"(game.geoCombo);
	}
	static if (hasMember!(Game, "enemiesKilled")) {
		writefln!"Enemies Killed: %s"(game.enemiesKilled);
	}
	static if (hasMember!(Game, "maxLevel")) {
		writefln!"Highest Level Reached: %s"(game.maxLevel);
	}
	static if (hasMember!(Game, "itemWorldVisits")) {
		writefln!"Item World Visits: %s"(game.itemWorldVisits);
	}
	static if (hasMember!(Game, "itemRate")) {
		writefln!"Item Rate: %s%%"(game.itemRate);
	}
	static if (hasMember!(Game, "defeated")) {
		if (game.defeated & Defeated.itemGeneral) {
			writeln("Defeated Item General");
		}
		if (game.defeated & Defeated.itemKing) {
			writeln("Defeated Item King");
		}
		if (game.defeated & Defeated.itemGod) {
			writeln("Defeated Item God");
		}
		if (game.defeated & Defeated.unknown2) {
			writeln("Defeated Unknown 2");
		}
		if (game.defeated & Defeated.astroCarter) {
			writeln("Defeated Astro Carter");
		}
		if (game.defeated & Defeated.prinnyGod) {
			writeln("Defeated Prinny God");
		}
		if (game.defeated & Defeated.priere) {
			writeln("Defeated Priere");
		}
		if (game.defeated & Defeated.marjoly) {
			writeln("Defeated Marjoly");
		}
		if (game.defeated & Defeated.unknown7) {
			writeln("Defeated Unknown 7");
		}
		if (game.defeated & Defeated.unknown8) {
			writeln("Defeated Unknown 8");
		}
		if (game.defeated & Defeated.unknown9) {
			writeln("Defeated Unknown 9");
		}
		if (game.defeated & Defeated.unknown10) {
			writeln("Defeated Unknown 10");
		}
		if (game.defeated & Defeated.adellRozalin) {
			writeln("Defeated Adell & Rozalin");
		}
	}
	writeln();
	static if (hasMember!(Game, "mapClears")) {
		writefln("-Map Clears-\n\n%(%s\n%)", game.mapClears);
	}
	static if (hasMember!(Game, "characters")) {
		writefln("-Characters-\n\n%(%s\n%)", game.characters);
	}
	static if (hasMember!(Game, "senators")) {
		auto index = new size_t[](game.senators.length);
		if (sortSenatorsByFavour) {
			makeIndex!((x,y) => x.favour > y.favour)(game.senators[], index);
		} else {
			index = iota(0,game.senators.length).array;
		}
		writefln("-Senators-\n\n%(%s\n%)", game.senators[].indexed(index).filter!(x => x.attendance > 0));
		auto average = (cast(double)game.senators[].filter!(x => x.attendance > 0).map!(x => x.favour).sum) / (cast(double)game.senators.length);
		writefln!"Average favour: %s (%s)\n"((cast(byte)average).favourString, average);
	}
	static if (hasMember!(Game, "bagItems") && hasMember!(Game, "warehouseItems")) {
		writefln("-Items-\n\nBag:\n%(\t%s\n%)\nWarehouse:\n%(\t%s\n%)", game.bagItems, game.warehouseItems);
	}
	static if (hasMember!(Game, "itemRecords")) {
		writeln("\n-Item Records-\n");
		foreach (id, record; game.itemRecords) {
			if (!record) {
				if (game.itemRecordName(id) != "") {
					writefln("% 3s. ????????????????????", (id%48)+1);
				}
			} else {
				writefln!"% 3s. % -20s - % 1s% 1s% 1s"((id%48)+1, game.itemRecordName(id), (record & Rarity.common) ? "★" : "", (record & Rarity.rare) ? "★" : "", (record & Rarity.legendary) ? "★" : "");
			}
		}
	}
	debug (unknowns) {
		writeln("\n-Unknown data-\n");
		import std.traits : getSymbolsByUDA;
		static foreach (unknown; getSymbolsByUDA!(Game, Unknown)) {
			writeln(mixin("game."~unknown.stringof));
		}
	}
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
