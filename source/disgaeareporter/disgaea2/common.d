module disgaeareporter.disgaea2.common;

import disgaeareporter.disgaea2;

public import d2data;

static immutable d2SteamID = "495280";

align(1)
struct BaseItemStats {
	align(1):
	ushort hp;
	ushort sp;
	ushort attack;
	ushort defense;
	ushort intelligence;
	ushort speed;
	ushort hit;
	ushort resistance;
}
static assert(BaseItemStats.sizeof == 16);