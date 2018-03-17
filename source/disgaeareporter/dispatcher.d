module disgaeareporter.dispatcher;

import memmux : readStruct = read;

import std.bitmanip : bitmanipRead = read, Endian;

enum Games {
	disgaea1,
	disgaea2,
	disgaea3,
	disgaea4,
	disgaea5
}

enum Platforms {
	ps2,
	ps3,
	ds,
	psp,
	psVita,
	pc,
	switch_
}

struct DisgaeaGame {
	Games game;
	Platforms platform;
	ubyte[] rawData;
}


auto detectGame(ubyte[] input) {
	auto output = DisgaeaGame();
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
		case Platforms.ps3: break;
		case Platforms.ds:
			return input.dup;
		case Platforms.psp: break;
		case Platforms.pc:
			auto key = input[0x20..0x24];
			ubyte[] decrypted = new ubyte[](input.length);

			decrypted[0..0x30] = input[0..0x30];

			foreach (index, dataByte; input[0x30..$]) {
				decrypted[index+0x30] = dataByte^key[index%4];
			}
			auto sizeBuffer = decrypted[0x3C..0x40];
			const size = sizeBuffer.bitmanipRead!(uint, Endian.littleEndian);
			auto expectedBuffer = decrypted[0x40..0x44];
			const expected = expectedBuffer.bitmanipRead!(uint, Endian.littleEndian);

			return decompress(decrypted[0x44..$], expected);
		case Platforms.psVita: break;
		case Platforms.switch_: break;
	}
	assert(0);
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

auto loadData(Game)(const ubyte[] data) {
	Game* game = new Game;
	data.readStruct!Game(*game);
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
}