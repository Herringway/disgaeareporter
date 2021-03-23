module disgaeareporter.disgaea5.common;

static immutable d5SteamID = "803600";

public import d5data;

import reversineer : Offset, VerifyOffsets;

align(1)
struct Evility {
	align(1):
	ushort id;

	alias id this;

	string toString() const {
		return d5evilities(id);
	}

	bool isValid() const {
		return (id != 0x270F) && (id != 2) && (id != 1) && (id != 0);
	}
}
