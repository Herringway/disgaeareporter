module disgaeareporter.app;

import disgaeareporter.disgaea1;
import disgaeareporter.disgaea2;

import disgaeareporter.dispatcher;
import disgaeareporter.common;

import siryul;

import std.file;
import std.getopt;
import std.stdio;

void main(string[] args) {
	import std.path : buildPath;

	bool steamDisgaea1;
	bool steamDisgaea2;
	bool json;
	bool yaml;
	auto helpInformation = getopt(args,
		"dumpjson|j", "Dumps data as JSON", &json,
		"dumpyaml|y", "Dumps data as YAML", &yaml,
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
			debug(steam) {
				writeln("steam dir: ", getSteamDirectory());
				writeln("steam d1 id: ", d1SteamID);
				writeln("full path: ", buildPath(getSteamDirectory(), d1SteamID, "remote"));
				writeln("found save: ", getLatestSaveFile(buildPath(getSteamDirectory(), d1SteamID, "remote")));
			}
			filePath = getLatestSaveFile(buildPath(getSteamDirectory(), d1SteamID, "remote"));
		} catch (Exception e) {
			writeln(e.msg);
			return;
		}
	} else if (steamDisgaea2) {
		try {
			debug(steam) {
				writeln("steam dir: ", getSteamDirectory());
				writeln("steam d2 id: ", d2SteamID);
				writeln("full path: ", buildPath(getSteamDirectory(), d2SteamID, "remote"));
				writeln("found save: ", getLatestSaveFile(buildPath(getSteamDirectory(), d2SteamID, "remote")));
			}
			filePath = getLatestSaveFile(buildPath(getSteamDirectory(), d2SteamID, "remote"));
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
		debug(printdetected) writefln!"Detected %s for %s"(detected.game, detected.platform);
		switch (detected.game) {
			case Games.disgaea1:
				switch (detected.platform) {
					case Platforms.ps2:
						dumpData(loadData!(disgaeareporter.disgaea1.PS2Game)(detected.rawData), yaml, json);
						break;
					case Platforms.pc:
						dumpData(loadData!(disgaeareporter.disgaea1.PCGame)(detected.rawData), yaml, json);
						break;
					case Platforms.psp:
						dumpData(loadData!(disgaeareporter.disgaea1.PSPGame)(detected.rawData), yaml, json);
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			case Games.disgaea2:
				switch (detected.platform) {
					case Platforms.ps2:
						dumpData(loadData!(disgaeareporter.disgaea2.PS2Game)(detected.rawData), yaml, json);
						break;
					case Platforms.pc:
						dumpData(loadData!(disgaeareporter.disgaea2.PCGame)(detected.rawData), yaml, json);
						break;
					case Platforms.psp:
						dumpData(loadData!(disgaeareporter.disgaea2.PSPGame)(detected.rawData), yaml, json);
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

void dumpData(T)(const T data, const bool yaml, const bool json) {
	if (yaml) {
		writeln(data.toString!YAML);
	} else if (json) {
		writeln(data.toString!JSON);
	} else {
		printData(data);
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