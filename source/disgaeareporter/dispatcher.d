module disgaeareporter.dispatcher;

import reversineer : readStruct = read;

import std.bitmanip : bitmanipRead = read, Endian;

enum Games {
	disgaea1,
	disgaea2,
	disgaea3,
	disgaea4,
	disgaea5,
	disgaead2
}

enum Platforms {
	ps2,
	ps3,
	ps4,
	ds,
	psp,
	psVita,
	pc,
	switch_
}

enum ReportFormat {
	text,
	html,
	json,
	yaml
}

struct DisgaeaGame {
	Games game;
	Platforms platform;
	ubyte[] rawData;
}


immutable ubyte[256] d5PCTable = genTable();

ubyte[256] genTable() {
	ubyte[256] output;
	foreach (ubyte i; 0..256) {
		ubyte b = cast(ubyte)(((i&0xF0)>>4) | ((0xF - (i&0xF))<<4));
		output[b] = i;
	}
	return output;
}

auto detectGame(ubyte[] input) {
	auto output = DisgaeaGame();
	if (input.length == 0x16DC28) {
		output.platform = Platforms.ps3;
		output.game = Games.disgaead2;
		output.rawData = input;
		return output;
	}
	if (input.length == 0x165890) {
		output.platform = Platforms.ps3;
		output.game = Games.disgaea3;
		output.rawData = input;
		return output;
	}
	if (input.length == 0x56F750) {
		output.platform = Platforms.ps3;
		output.game = Games.disgaea4;
		output.rawData = input;
		return output;
	}
	if (input.length == 9026184) {
		output.platform = Platforms.pc;
		output.game = Games.disgaea5;
		output.rawData = decrypt5(input);
		return output;
	}
	if (input.length >= 0x38) {
		auto key = input[0x20..0x24];

		auto encMagic = [0x59, 0x4B, 0x43, 0x4D, 0x50, 0x5F, 0x56, 0x31];
		foreach (index, ref dataByte; encMagic) {
			dataByte ^= key[index%4];
		}
		if (input[0x30..0x38] == encMagic) {
			output.platform = Platforms.pc;
			output.rawData = getRawData(input, Platforms.pc);

			if (output.rawData.length == 0x48878) {
				output.game = Games.disgaea1;
			} else {
				output.game = Games.disgaea2;
			}
			return output;
		}
	}
	if (input.length >= 0x28) {
		if (input[0x20..0x29] == [0x81, 0x82, 0x88, 0x82, 0x81, 0x82, 0x92, 0x82, 0x8C]) {
			output.game = Games.disgaea1;
			output.platform = Platforms.psp;
			output.rawData = input[0x10..$];
			return output;
		}
	}
	if (input.length >= 0x18) {
		if (input[0x10..0x19] == [0x81, 0x82, 0x88, 0x82, 0x81, 0x82, 0x92, 0x82, 0x8C]) {
			output.game = Games.disgaea1;
			output.platform = Platforms.ps2;
			output.rawData = input;
			return output;
		}
	}
	if (input.length >= 0x18) {
		if (input[0x10..0x19] == [0x84, 0x82, 0x85, 0x82, 0x8C, 0x82, 0x8C, 0x00, 0x00]) {
			output.game = Games.disgaea2;
			if (input.length > 0x79400) {
				output.platform = Platforms.psp;
			} else {
				output.platform = Platforms.ps2;
			}
			output.rawData = input;
			return output;
		}
	}
	if (input.length >= 0x10) {
		if (input[0..16] == [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]) {
			output.platform = Platforms.ds;
			output.game = Games.disgaea1;
			output.rawData = input;
			return output;
		}
	}
	throw new Exception("No known disgaea data found.");
}

ubyte[] getRawData(const ubyte[] input, Platforms platform) {
	final switch (platform) {
		case Platforms.ps2: break;
		case Platforms.ps3:
			return input.dup;
		case Platforms.ps4: break;
		case Platforms.ds:
			return input.dup;
		case Platforms.psp: break;
		case Platforms.pc:
			bool oldStyle = true;
			if (oldStyle) {
				ubyte[4] key = input[0x20..0x24];
				auto decrypted = input[0..0x30]~decrypt(input[0x30..$], key);
				auto sizeBuffer = decrypted[0x3C..0x40];
				const size = sizeBuffer.bitmanipRead!(uint, Endian.littleEndian);
				auto expectedBuffer = decrypted[0x40..0x44];
				const expected = expectedBuffer.bitmanipRead!(uint, Endian.littleEndian);

				return decompress(decrypted[0x44..$], expected);
			} else {
				return [];
			}
		case Platforms.psVita: break;
		case Platforms.switch_: break;
	}
	assert(0);
}

ubyte[] decrypt(const ubyte[] input, ubyte[4] key) {
	ubyte[] decrypted;
	decrypted.reserve(input.length);
	foreach (index, dataByte; input) {
		decrypted ~= dataByte^key[index%4];
	}
	return decrypted;
}
ubyte[] decrypt5(const ubyte[] input) {
	ubyte[] decrypted;
	decrypted.reserve(input.length);
	foreach (dataByte; input) {
		decrypted ~= d5PCTable[dataByte];
	}
	return decrypted;
}

unittest {
	import std.string : representation;
	assert(decrypt5([0x85, 0x06, 0x36, 0x96, 0x86, 0xE6, 0x16, 0x86]) == "Wolfgang".representation);
}

ubyte[] decompress(const ubyte[] input, size_t expected) pure @safe {
	ubyte[] output;
	output.reserve(expected);

	void copyBack(uint length, uint position) {
		output ~= output[$-position..$-position+length];
	}

	for (uint i = 0; i < input.length; i++) {
		if (input[i] == 0) {
			continue;
		} else if (input[i] < 0x80) {
			output ~= input[i+1..i+1+input[i]];
			i += input[i];
		} else if (input[i] < 0xC0) {
			auto compensated = input[i] - 0x80;
			copyBack(((compensated&0xF0)>>4) + 1, (compensated&0xF)+1);
		} else if (input[i] < 0xE0) {
			auto compensated = input[i] - 0xC0;
			copyBack(compensated+2, input[i+1] + 1);
			i++;
		} else if (input[i] <= 0xFF) {
			auto compensated = input[i] - 0xE0;
			copyBack((compensated<<4) + ((input[i+1]&0xF0)>>4) + 3, ((input[i+1]&0xF)<<8) + input[i+2] + 1);
			i += 2;
		}
	}
	return output;
}

//doesn't actually compress, but makes compatible with decompression algorithm
ubyte[] compress(const ubyte[] input) pure @safe {
	import std.range : chunks;
	ubyte[] output;
	output.reserve(input.length + input.length/127);

	foreach (chunk; input.chunks(127)) {
		output ~= cast(ubyte)chunk.length ~ chunk;
	}

	return output;
}

unittest {
	import std.array : array;
	import std.range : repeat;
	bool identity(const ubyte[] input) {
		return input == decompress(compress(input), input.length);
	}
	assert(identity([]));
	assert(identity([0]));
	assert(identity([0xFF]));
	assert(identity((cast(ubyte)0xFF).repeat(256).array));
	assert(identity((cast(ubyte)0xFF).repeat(127).array));
	assert(identity((cast(ubyte)0xFF).repeat(128).array));
}

auto loadData(Game)(const ubyte[] data) {
	import std.traits : hasMember;
	Game* game = new Game;
	data.readStruct!Game(game);
	debug(dumpraw) {
		import std.file : mkdirRecurse, write;
		import std.traits : moduleName;
		mkdirRecurse("dumps");
		write("dumps/raw-"~moduleName!Game~".dat", data);
	}
	return game;
}


unittest {
	{
		auto detected = detectGame(cast(ubyte[])import("d1pc-SAVE000.DAT"));
		assert(detected.game == Games.disgaea1);
		assert(detected.platform == Platforms.pc);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d2pc-SAVE000.DAT"));
		assert(detected.game == Games.disgaea2);
		assert(detected.platform == Platforms.pc);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d1psp-raw.dat"));
		assert(detected.game == Games.disgaea1);
		assert(detected.platform == Platforms.psp);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d1ps2-raw.dat"));
		assert(detected.game == Games.disgaea1);
		assert(detected.platform == Platforms.ps2);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d2ps2-raw.dat"));
		assert(detected.game == Games.disgaea2);
		assert(detected.platform == Platforms.ps2);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d2psp-raw.dat"));
		assert(detected.game == Games.disgaea2);
		assert(detected.platform == Platforms.psp);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d1ds-raw.dat"));
		assert(detected.game == Games.disgaea1);
		assert(detected.platform == Platforms.ds);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("dd2ps3-raw.DAT"));
		assert(detected.game == Games.disgaead2);
		assert(detected.platform == Platforms.ps3);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d4ps3-raw.DAT"));
		assert(detected.game == Games.disgaea4);
		assert(detected.platform == Platforms.ps3);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d3ps3-raw.DAT"));
		assert(detected.game == Games.disgaea3);
		assert(detected.platform == Platforms.ps3);
	}
	{
		auto detected = detectGame(cast(ubyte[])import("d5pc-Save_001.sav"));
		assert(detected.game == Games.disgaea5);
		assert(detected.platform == Platforms.pc);
	}
}