import std.stdio;
import std.traits : isSomeChar;
import reversineer;

import libgamefs.nis.nispack;

auto parseAllData(ubyte[] data) {
	struct Output {
		HabitEntry[] innocents;
		Skill[] skills;
		Feature[] features;
		string[] names;
	}
	auto output = Output();
	return NISPack(data);
	//foreach (file; pack.files) {
	//	switch (file.filename) {
	//		case "HABIT.dat":
	//			output.innocents = parseHabitDat(file.data);
	//			break;
	//		case "magic.dat":
	//			output.skills = parseMagicDat(file.data);
	//			break;
	//		case "Feature.dat":
	//			output.features = parseFeatureDat(file.data);
	//			break;
	//		//case "name.dat":
	//		//	output.names = parseNameDat(file.data);
	//		//	break;
	//		default: break;
	//	}
	//}
	//return output;
}

void main(string[] args) {
	import std.algorithm : canFind;
	import std.file : read;
	import std.stdio : writefln;
	import siryul;
	auto pack = parseAllData(cast(ubyte[])read(args[1]));
	static struct Title {
		bool isSuffix;
		string title;
	}
	foreach (file; pack.root.subEntries) {
		if (file.filename == "CharTitle.dat") {
			auto count = (cast(BigEndian!ushort[])(file.data[0 .. 2]))[0];
			Title[] titles;
			foreach (i, title; cast(BigEndian!D2Title[])(file.data[4 .. $])) {
				titles ~= Title(title.format == 512, title.title);
				//writefln!"%s - [%(%02X %)]"(title.title, title.unknown2[0 .. 90]);
				//writefln!"%s - %s"(title.title, title.format);
				//writefln!"%s. %s"(i, title.title);
			}
			titles.toFile!YAML("d2titles.yaml");
		}
	}
	//foreach (skill; data.skills) {
	//	writefln!"%04X\t%s"(skill.id, skill.name);
	//}
	//foreach (file; data.files) {
	//	writefln!"%08X-%06X-%s"(file.offset, file.size, file.filename);
	//}
}

align(1) struct D2Title {
	align(1):
	ushort unknown;
	ZeroString!(0x24) title;
	ushort format;
	ubyte[108] unknown2;
}

struct HabitEntry {
	ubyte[8] unknown;
	ushort id;
	ubyte[2] unknown2;
	char[64] _name;
	char[340] _description;
	auto name() const {
		return _name[].fromStringz();
	}
	auto description() const {
		return _description[].fromStringz();
	}
}

auto parseHabitDat(ubyte[] data) {
	HabitEntry[] output;
	while (data.length >= 0x1A0) {
		HabitEntry entry;
		entry.unknown = data[0..8];
		entry.id = cast(ushort)((data[8]<<8) + data[9]);
		entry.unknown2 = data[10..12];
		entry._name = cast(char[])data[0x0C..0x4C];
		entry._description = cast(char[])data[0x4C..0x1A0];
		output ~= entry;
		data = data[0x1A0..$];
	}
	return output;
}

struct Skill {
	ushort unknown1;
	ushort id;
	ubyte[8] unknown;
	char[0x94] _description;
	char[0x30] _name;
	char[0x30] _name2;
	ubyte[0x28] unknown2;
	auto name() const {
		return _name[].fromStringz();
	}
	auto name2() const {
		return _name2[].fromStringz();
	}
	auto description() const {
		return _description[].fromStringz();
	}
}

auto parseMagicDat(ubyte[] data) {
	Skill[] skills;

	auto count = (data[0]<<8)+data[1];

	foreach (i; 0..count) {
		auto base = 2 + i*0x128;
		Skill skill;
		skill.unknown1 = (data[base+0]<<8)+data[base+1];
		skill.id = (data[base+2]<<8)+data[base+3];
		skill.unknown = data[base+4..base+12];
		skill._description = cast(char[])data[base+0xC..base+0xA0];
		skill._name = cast(char[])data[base+0xA0..base+0xD0];
		skill._name2 = cast(char[])data[base+0xD0..base+0x100];
		skill.unknown2 = data[base+0x100..base+0x128];
		skills ~= skill;
	}

	return skills;
}

struct CharHelp {
	ushort unknown;
	ZeroString!0x5C line1;
	ZeroString!0x5C line2;
	ZeroString!0x5C line3;
	auto description() const {
		return fromStringz(line1[])~"\n"~fromStringz(line2[])~"\n"~fromStringz(line3[]);
	}
}

auto parseCharHelpDat(ubyte[] data) {
	CharHelp[] output;
	foreach (i; 0..0x100) {
		auto base = 4 + i*0x116;
		CharHelp charHelp;
		charHelp.unknown = (data[base]<<8) + data[base+1];
		charHelp.line1.raw = cast(char[])data[base+2..base+0x5E];
		charHelp.line2.raw = cast(char[])data[base+0x5E..base+0xBA];
		charHelp.line3.raw = cast(char[])data[base+0xBA..base+0x116];
		output ~= charHelp;
	}
	return output;
}

struct Feature {
	uint id1;
	ubyte id2;
	ZeroString!0x57 line;
}

auto parseFeatureDat(ubyte[] data) {
	Feature[] output;
	ushort count = (data[0]<<8) + data[1];
	foreach (i; 0..count) {
		auto base = 2 + i*0x5C;
		Feature feature;
		feature.id1 = (data[base]<<24) + (data[base+1]<<16) + (data[base+2]<<8) + data[base+3];
		feature.id2 = data[base+4];
		feature.line.raw = cast(char[])data[base+5..base+0x5C];
		output ~= feature;
	}
	return output;
}

struct MSkill {
	ubyte[10] unknown;
	ushort id;
	ubyte[5] unknown2;
	ZeroString!0x50 name;
	ZeroString!0x80 description;
	ubyte[7] unknown3;
}

auto parseMSkillDat(ubyte[] data) {
	MSkill[] output;
	ushort count = (data[0]<<8) + data[1];
	foreach (i; 0..count) {
		auto base = 2 + i*0xE8;
		MSkill mskill;
		mskill.unknown = data[base..base+10];
		mskill.id = (data[base+10]<<8) + data[base+11];
		mskill.unknown2 = data[base+12..base+17];
		mskill.name.raw = cast(char[])data[base+17..base+17+0x50];
		mskill.description.raw = cast(char[])data[base+0x61..base+0x61+0x80];
		mskill.unknown3 = data[base+0xE1..base+0xE8];
		output ~= mskill;
	}
	return output;
}

struct NameListsPS3 {
	string[][] lists;
}


auto parseNameDatPS3(ubyte[] data, bool sjis) {
	import std.algorithm;
	NameListsPS3 output;
	enum listCount = 5;
	output.lists.length = listCount;
	ushort totalNames;
	ushort[] counts;
	foreach (i; 0..listCount) {
		totalNames += (data[i*2]<<8) + data[i*2+1];
		counts ~= (data[i*2]<<8) + data[i*2+1];
	}
	foreach (list; 0..listCount) {
		auto basePtr = counts[0..list].sum;
		ushort count = counts[list];
		foreach (i; 0..count) {
			auto ptrAddr = (basePtr + listCount + i)*2;
			auto base = (data[ptrAddr]<<8) + data[ptrAddr+1] + listCount*2 + totalNames*2;
			if (sjis) {
				output.lists[list] ~= sjisDec(data[base..$]);
			} else {
				output.lists[list] ~= (cast(char[])data[base..$]).fromStringz;
			}
		}
	}
	return output;
}

auto parseNameDatPS2(ubyte[] data, bool sjis) {
	import std.algorithm;
	NameListsPS3 output;
	enum listCount = 5;
	output.lists.length = listCount;
	ushort totalNames;
	ushort[] counts;
	foreach (i; 0..listCount) {
		totalNames += (data[i*2+1]<<8) + data[i*2];
		counts ~= (data[i*2+1]<<8) + data[i*2];
	}
	foreach (list; 0..listCount) {
		auto basePtr = counts[0..list].sum;
		ushort count = counts[list];
		foreach (i; 0..count) {
			auto ptrAddr = (basePtr + listCount + i)*2;
			auto base = (data[ptrAddr+1]<<8) + data[ptrAddr] + listCount*2 + totalNames*2;
			if (sjis) {
				output.lists[list] ~= sjisDec(data[base..$]);
			} else {
				output.lists[list] ~= (cast(char[])data[base..$]).fromStringz;
			}
		}
	}
	return output;
}

struct NameListsD5 {
	string[][][] lists;
}
auto parseNameDatD5(ubyte[] data) {
	import std.algorithm : sum;
	uint readPtr(size_t offset) {
		return data[offset] + (data[offset+1]<<8) + (data[offset+2]<<16) + (data[offset+3]<<24);
	}
	NameListsD5 output;
	enum langCount = 6;
	enum listCount = 5;
	uint totalNames;
	uint[] counts;
	uint[] pointers;
	foreach (i; 0..listCount*langCount) {
		totalNames += readPtr(i*4);
		counts ~= readPtr(i*4);
	}
	writeln(counts.sum);
	pointers.reserve(counts.sum);
	foreach (p; 0..counts.sum) {
		auto ptr = readPtr((langCount*listCount + p)*4) + counts.sum * 4 + (langCount*listCount) * 4;
		assert(ptr >= 0xA6EC);
		pointers ~= ptr;
	}
	foreach (l; 0..langCount) {
		string[][] langList;
		langList.length = listCount;
		foreach (list; 0..listCount) {
			auto basePtr = counts[0..l*5+list].sum;
			auto count = counts[l*5+list];
			foreach (i; 0..count) {
				auto base = pointers[basePtr+i];
				langList[list] ~= (cast(char[])data[base..$]).fromStringz;
			}
		}
		output.lists ~= langList;
	}
	return output;
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
struct ZeroString(size_t length) {
	import siryul : SerializationMethod;
	char[length] raw = 0;
	alias toString this;

	@SerializationMethod
	auto toString() const {
		import std.format : format;
		import std.utf : validate;
		debug {
			import std.algorithm.searching : countUntil;
			auto firstNull = (cast(ubyte[])raw[]).countUntil(0);
			if (firstNull > -1) {
				foreach (i, b; raw[firstNull .. $]) {
					assert(b == 0, format!"non-zero at position %s+%s"(firstNull, i));
				}
			}
		}
		auto str = raw[].fromStringz;
		validate(str);
		return str;
	}
}