module disgaeareporter.disgaea1.ds;

import reversineer : Offset, VerifyOffsets;
align(1)
struct D1DS {
	align(1):
	ubyte[1952] unknown;
	@Offset(0x7A0) Character[128] _characters;

	auto characters() const return {
		return _characters[];
	}
}

mixin VerifyOffsets!(D1DS, D1DS.sizeof); //figure out actual size later I guess

align(1)
struct Character {
	align(1):
	uint _exp;
	ubyte _expMSB;
	ubyte[643] unknown;
	char[12] name;
	ubyte[30] unknown2;

	ulong exp() const {
		return _exp | (cast(ulong)_expMSB<<32);
	}
}

mixin VerifyOffsets!(Character, 0x2B2);

version(none) unittest {
	import disgaeareporter.common : printData;
	import disgaeareporter.dispatcher : getRawData, loadData, Platforms;
	auto data = loadData!DSGame(getRawData(cast(immutable(ubyte)[])import("d1ds-raw.dat"), Platforms.ds));
	printData(data);
	//assert(data.characters.length == 6);

	with(data.characters[0]) {
		assert(exp == 16957361757);
		assert(name == "Divine Majin");
		//assert(level == 4716);
	}
	with(data.characters[2]) {
		assert(exp == 9919801982);
	}

	//with(data._bagItems[0]) {
	//	assert(nameID.itemName == "Common Sword");
	//	assert(rarity == 32);
	//}
}
