module disgaeareporter.app;

import disgaeareporter.disgaea1;
import disgaeareporter.disgaea2;
import disgaeareporter.disgaea3;
import disgaeareporter.disgaea4;
import disgaeareporter.disgaea5;
import disgaeareporter.disgaead2;

import disgaeareporter.dispatcher;
import disgaeareporter.common;

import siryul;
import easysettings;

import std.file;
import std.getopt;
import std.stdio;

void main(string[] args) {
	bool steamDisgaea1;
	bool steamDisgaea2;
	bool steamDisgaea5;
	bool json;
	bool yaml;
	bool html;
	bool genReports;
	bool showUnknown;
	auto helpInformation = getopt(args,
		"unknown|u", "Includes unknown data", &showUnknown,
		"dumpjson|j", "Dumps data as JSON", &json,
		"dumpyaml|y", "Dumps data as YAML", &yaml,
		"dumphtml|h", "Dumps data as HTML", &html,
		"reports|r", "Automatically generates reports as defined in settings", &genReports,
		"steamdisgaea1", "Automatically find steam save for Disgaea 1", &steamDisgaea1,
		"steamdisgaea2", "Automatically find steam save for Disgaea 2", &steamDisgaea2,
		"steamdisgaea5", "Automatically find steam save for Disgaea 5", &steamDisgaea5);

	if (args.length < 2 && !steamDisgaea1 && !steamDisgaea2 && !genReports) {
		helpInformation.helpWanted = true;
	}
	if (helpInformation.helpWanted) {
		defaultGetoptPrinter("Gives a nice long report of disgaea saves.", helpInformation.options);
		return;
	}
	if (!genReports) {
		string filePath;
		if (steamDisgaea1) {
			filePath = getD1SteamPath();
		} else if (steamDisgaea2) {
			filePath = getD2SteamPath();
		} else if (steamDisgaea5) {
			filePath = getD5SteamPath();
		} else {
			filePath = args[1];
		}
		ReportFormat format;
		if (yaml) {
			format = ReportFormat.yaml;
		} else if (json) {
			format = ReportFormat.json;
		} else if (html) {
			format = ReportFormat.html;
		} else {
			format = ReportFormat.text;
		}
		if (filePath.exists) {
			handleFile(filePath, "", format, showUnknown);
		}
	} else {
		auto settings = loadSettings!DisgaeaReporterFiles("Herringway/disgaeareporter");
		foreach (file; settings.files) {
			if (file.steamDisgaea1) {
				file.savePath = getD1SteamPath();
			} else if (file.steamDisgaea2) {
				file.savePath = getD2SteamPath();
			} else if (file.steamDisgaea5) {
				file.savePath = getD5SteamPath();
			}
			if (file.savePath.exists) {
				handleFile(file.savePath, file.reportPath, file.format, showUnknown);
			} else {
				if (file.steamDisgaea1) {
					writeln("Warning: Steam save for disgaea 1 not found");
				} else if (file.steamDisgaea2) {
					writeln("Warning: Steam save for disgaea 2 not found");
				} else if (file.steamDisgaea5) {
					writeln("Warning: Steam save for disgaea 5 not found");
				} else {
					if (file.savePath == "") {
						writeln("Warning: No save specified");
					} else {
						writefln!"Warning: %s not found"(file.savePath);
					}
				}
			}
		}
	}
}

struct DisgaeaReporterFile {
	import siryul : Optional;
	@Optional bool steamDisgaea1 = false;
	@Optional bool steamDisgaea2 = false;
	@Optional bool steamDisgaea5 = false;
	@Optional string savePath;
	@Optional ReportFormat format;
	string reportPath;
}

struct DisgaeaReporterFiles {
	DisgaeaReporterFile[] files;
}

alias getD1SteamPath = getSteamPath!d1SteamID;
alias getD2SteamPath = getSteamPath!d2SteamID;
alias getD5SteamPath = getSteamPath!d5SteamID;

auto getSteamPath(string id)() nothrow {
	import std.path : buildPath;
	import std.exception : assumeWontThrow;
	try {
		debug(steam) {
			writeln("steam dir: ", getSteamDirectory());
			writeln("steam id: ", id);
			writeln("full path: ", buildPath(getSteamDirectory(), id, "remote"));
			writeln("found save: ", getLatestSaveFile(buildPath(getSteamDirectory(), id, "remote")));
		}
		return getLatestSaveFile(buildPath(getSteamDirectory(), id, "remote"));
	} catch (Exception e) {
		debug assumeWontThrow(writeln("Error finding latest steam save: ", e.msg));
		return "";
	}
}

auto handleFile(string path, string outPath, const ReportFormat format, bool showUnknown) {
	auto data = cast(ubyte[])read(path);
	File outFile;
	if (outPath == "") {
		outFile = stdout;
	} else {
		outFile = File(outPath, "w");
	}
	try {
		const detected = detectGame(data);
		debug(printdetected) writefln!"Detected %s for %s"(detected.game, detected.platform);
		switch (detected.game) {
			case Games.disgaea1:
				switch (detected.platform) {
					case Platforms.ps2:
						dumpData(loadData!(disgaeareporter.disgaea1.D1PS2)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.pc:
						dumpData(loadData!(disgaeareporter.disgaea1.D1PC)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.psp:
						dumpData(loadData!(disgaeareporter.disgaea1.D1PSP)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.ds:
						dumpData(loadData!(disgaeareporter.disgaea1.D1DS)(detected.rawData), outFile, format, showUnknown);
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			case Games.disgaea2:
				switch (detected.platform) {
					case Platforms.ps2:
						dumpData(loadData!(disgaeareporter.disgaea2.D2PS2)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.pc:
						dumpData(loadData!(disgaeareporter.disgaea2.D2PC)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.psp:
						dumpData(loadData!(disgaeareporter.disgaea2.D2PSP)(detected.rawData), outFile, format, showUnknown);
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			case Games.disgaea3:
				switch (detected.platform) {
					case Platforms.ps3:
						dumpData(loadData!(disgaeareporter.disgaea3.D3PS3, true)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.psVita:
						dumpData(loadData!(disgaeareporter.disgaea3.D3Vita)(detected.rawData), outFile, format, showUnknown);
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			case Games.disgaea4:
				switch (detected.platform) {
					case Platforms.ps3:
						dumpData(loadData!(disgaeareporter.disgaea4.D4PS3, true)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.psVita:
						dumpData(loadData!(disgaeareporter.disgaea4.D4Vita)(detected.rawData), outFile, format, showUnknown);
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			case Games.disgaea5:
				switch (detected.platform) {
					case Platforms.ps4:
						dumpData(loadData!(disgaeareporter.disgaea5.D5PS4)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.switch_:
						dumpData(loadData!(disgaeareporter.disgaea5.D5Switch)(detected.rawData), outFile, format, showUnknown);
						break;
					case Platforms.pc:
						dumpData(loadData!(disgaeareporter.disgaea5.D5PC)(detected.rawData), outFile, format, showUnknown);
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			case Games.disgaead2:
				switch(detected.platform) {
					case Platforms.ps3:
						dumpData(loadData!(disgaeareporter.disgaead2.DD2PS3, true)(detected.rawData), outFile, format, showUnknown);
						break;
					default: writeln("Unsupported"); return;
				}
				break;
			default: writeln("Unsupported"); return;
		}
	} catch (Exception e) {
		writefln!"Invalid save file %s: %s"(path, e.msg);
	}
}

void dumpData(T)(const T* data, File output, const ReportFormat format, bool showUnknown) {
	final switch (format) {
		case ReportFormat.yaml:
			output.writeln(toString!(YAML, Siryulize.omitNulls & Siryulize.omitInits)(data));
			break;
		case ReportFormat.json:
			output.writeln(toString!(JSON, Siryulize.omitNulls & Siryulize.omitInits)(data));
			break;
		case ReportFormat.text:
			output.printData(data, showUnknown);
			break;
		case ReportFormat.html:
			output.printHTML(data);
			break;
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
