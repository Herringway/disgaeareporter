module disgaeareporter.disgaea1.psp;


enum d1key = "DISGAEA120060523";

import d1data;

import disgaeareporter.disgaea1.common;
import disgaeareporter.disgaea1.pc : Item;

import disgaeareporter.common;

struct D1PSP {
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
	SJISString!32 name;
	ubyte unknown1;
	SJISString!33 className;
	ubyte[2] unknown2;
	ubyte[32] unknown3;
	StatusResistance[5] statusResistances;
	ubyte[110] unknown4;
	Skills!(96, d1skillNames, false) skills;
	uint currentHP;
	uint currentSP;
	Stats stats;
	Stats realStats;
	ubyte[32] unknown5;
	uint mana;
	ubyte[24] unknown6;
	EquipmentMastery equipmentMastery;
	BaseCharacterStats baseStats;
	ushort level;
	ushort unknown7;
	ushort class_;
	ushort class2;
	ushort skillTree;
	ubyte[10] unknown8;
	Resistance baseResist;
	Resistance resist;
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
}
static assert(PSPCharacter.sizeof == 0x6A8);