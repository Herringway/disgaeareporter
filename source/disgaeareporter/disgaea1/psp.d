module disgaeareporter.disgaea1.psp;


enum d1key = "DISGAEA120060523";

import disgaeareporter.disgaea1.common;
import disgaeareporter.disgaea1.pc : Item;

struct PSPGame {
	enum charOffset = 0xBB8;
	enum charSize = 0x6A8;
	ubyte[0xBB8] unknown;
	PSPCharacter[128] _characters;
}


align(1)
struct PSPCharacter {
	align(1):
	ulong exp;
	Item[4] equipment;
	ubyte[32] sjisName;
	ubyte unknown1;
	ubyte[33] title;
	ubyte[2] unknown2;
	ubyte[32] unknown3;
	Resistance[5] resistances;
	ubyte[110] unknown4;
	uint[96] skillEXP;
	ushort[96] skills;
	ubyte[96] skillLevels;
	uint currentHP;
	uint currentSP;
	Stats stats;
	Stats realStats;
	ubyte[32] unknown5;
	uint mana;
	ubyte[24] unknown6;
	ubyte[8] weaponMasteryLevel;
	ubyte[8] weaponMasteryRate;
	BaseCharacterStats baseStats;
	ushort level;
	ushort unknown7;
	ushort class_;
	ushort class2;
	ushort skillTree;
	ubyte[10] unknown8;
	byte baseFireResist;
	byte baseIceResist;
	byte baseWindResist;
	byte fireResist;
	byte iceResist;
	byte windResist;
	ubyte baseJM;
	ubyte jm;
	ubyte baseMV;
	ubyte mv;
	ubyte baseCounter;
	ubyte counter;
	ubyte[13] unknown9;
	ubyte senateRank;
	ubyte[2] unknown10;
	byte mentor;
	ubyte[23] unknown11;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.algorithm : filter;
		import std.format;
		import std.range : lockstep;
		sink.formattedWrite!"%s (Lv%s %s)\n"(name, level, className);
		sink.formattedWrite!"\tRank: %s, Mana: %s\n"(senateRank, mana);
		sink.formattedWrite!"\tCounter: %s, MV: %s, JM: %s\n"(counter, mv, jm);
		sink.formattedWrite!"\tResists - Fire: %s%%, Wind: %s%%, Ice: %s%%\n"(fireResist, iceResist, windResist);
		if (mentor >= 0) {
			sink.formattedWrite("\tMentor: %s\n", chars[cast(size_t)mentor].name);
		}
		sink.formattedWrite!"\t%s\n"(stats);
		if (weaponMasteryLevel != weaponMasteryLevel.init) {
			sink.formattedWrite!"\tWeapon mastery:\n"();
			foreach (i, masteryRate, masteryLevel; lockstep(weaponMasteryRate[], weaponMasteryLevel[])) {
				if (masteryLevel > 0) {
					sink.formattedWrite!"\t\tLv%s %s\n"(masteryLevel, cast(WeaponTypes)i);
				}
			}
		}
		if (equipment != equipment.init) {
			sink.formattedWrite!"\tEquipment:\n"();
			sink.formattedWrite!"%(\t\t%s\n%)\n"(equipment[].filter!(x => x.nameID != 0));
		}
		if (skills[0] != 0) {
			sink.formattedWrite!"\tAbilities:\n"();
			foreach (i, skill, skillLevel, skillEXP; lockstep(skills[], skillLevels[], skillEXP[])) {
				if ((skill > 0) && (skillLevel != 255)) {
					sink.formattedWrite!"\t\tLv%s %s (%s EXP)\n"(skillLevel, skill.skillName, skillEXP);
				} else if (skillLevel == 255) {
					sink.formattedWrite!"\t\tLearning %s (%s EXP)\n"(skill.skillName, skillEXP);
				}
			}
		}
		debug(unknowns) formattedWrite!"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n"(sink, unknown1, unknown2, unknown3, unknown4, unknown5, unknown6, unknown7, unknown8, unknown9, unknown10, unknown11);
	}
	string name() const {
		return sjisDec(sjisName[]);
	}
	string className() const {
		return sjisDec(title[]);
	}
}
static assert(PSPCharacter.sizeof == 0x6A8);