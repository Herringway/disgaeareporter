module disgaeareporter.app;

import disgaeareporter.disgaea1;
import disgaeareporter.disgaea2;

import disgaeareporter.dispatcher;
import disgaeareporter.common;

import std.file;
import std.getopt;
import std.stdio;

void main(string[] args) {
	import std.path : buildPath;

	bool steamDisgaea1;
	bool steamDisgaea2;
	auto helpInformation = getopt(args,
		"steamdisgaea1", "Automatically find steam save for Disgaea 1", &steamDisgaea1,
		"steamdisgaea2", "Automatically find steam save for Disgaea 2", &steamDisgaea2);

	if (args.length < 2 && !steamDisgaea1 && !steamDisgaea2) {
		helpInformation.helpWanted = true;
	}
	if (helpInformation.helpWanted) {
		defaultGetoptPrinter("Gives a nice long report of disgaea saves.", helpInformation.options);
		return;
	}
	string filePath;
	if (steamDisgaea1) {
		try {
			filePath = getLatestSaveFile(buildPath(getSteamDirectory(), d1SteamID, "/remote/"));
		} catch (Exception e) {
			writeln(e.msg);
			return;
		}
	} else if (steamDisgaea2) {
		try {
			filePath = getLatestSaveFile(buildPath(getSteamDirectory(), d2SteamID, "/remote/"));
		} catch (Exception e) {
			writeln(e.msg);
			return;
		}
	} else {
		filePath = args[1];
	}

	auto file = cast(ubyte[])read(filePath);
	try {
		const detected = detectGame(file);
		debug writefln!"Detected %s for %s"(detected.game, detected.platform);
		switch (detected.game) {
			case Games.disgaea1:
				switch (detected.platform) {
					case Platforms.ps2:
						printData(loadData!(disgaeareporter.disgaea1.PS2Game)(detected.rawData));
						break;
					case Platforms.pc:
						printData(loadData!(disgaeareporter.disgaea1.PCGame)(detected.rawData));
						break;
					case Platforms.psp:
						printData(loadData!(disgaeareporter.disgaea1.PSPGame)(detected.rawData));
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			case Games.disgaea2:
				switch (detected.platform) {
					case Platforms.ps2:
						printData(loadData!(disgaeareporter.disgaea2.PS2Game)(detected.rawData));
						break;
					case Platforms.pc:
						printData(loadData!(disgaeareporter.disgaea2.PCGame)(detected.rawData));
						break;
					case Platforms.psp:
						printData(loadData!(disgaeareporter.disgaea2.PSPGame)(detected.rawData));
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			default: writeln("Unsupported"); return;
		}
	} catch (Exception e) {
		writefln!"Invalid save file: %s"(e.msg);
	}
}

string getSteamDirectory() {
	version(Windows) {
		import std.conv : text;
		import std.path : buildPath;
		import std.windows.registry : Registry;
		try {
			auto key = Registry.currentUser()
				.getKey("Software")
				.getKey("Valve")
				.getKey("Steam");
			auto steamPath = key.getValue("SteamPath");
			auto userID = key.getKey("ActiveProcess").getValue("ActiveUser");

			return buildPath(steamPath.value_SZ, "userdata", userID.value_DWORD.text);
		} catch (Exception e) {
			throw new Exception("Error getting active steam save directory. Is user logged in?");
		}
	} else {
		assert(0, "Unimplemented");
	}
}

string getLatestSaveFile(string path) {
	import std.datetime : SysTime;
	import std.path : buildPath;

	SysTime best = SysTime.min;
	string bestMatch;
	foreach (save; dirEntries(path, "*.DAT", SpanMode.shallow)) {
		if (best > save.timeLastModified) {
			continue;
		} else {
			best = save.timeLastModified;
			bestMatch = save;
		}
	}
	if (best == SysTime.min) {
		throw new Exception("No saves found for current steam user!");
	}
	return buildPath(path, bestMatch);
}