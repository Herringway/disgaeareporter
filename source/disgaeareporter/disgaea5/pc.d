module disgaeareporter.disgaea5.pc;

import disgaeareporter.common;
import disgaeareporter.disgaea5.common;

align(1)
struct Innocent {
	align(1):

	bool isValid() const {
		return true;
	}
}

align(1)
struct Item {
	align(1):
	@Unknown ubyte[0x128] unknown1;
	ushort itemID;
	@Unknown ubyte[0x12E] unknown2;

	bool isValid() const {
		return itemID != 0;
	}
	string name() const {
		return itemID.itemName;
	}
	Innocent[] innocents() const {
		return [];
	}
}

static assert(Item.sizeof == 0x258);
static assert(Item.itemID.offsetof == 0x128);

align(1)
struct Character {
	align(1):
	ulong exp;
	Item[5] equipment;
	ZeroString!0x34 name;
	ZeroString!0x34 className;
	@Unknown ubyte[0x3B28] unknown1;
}

static assert(Character.sizeof == 0x4750);
static assert(Character.name.offsetof == 0xBC0);

align(1)
struct D5PC {
	align(1):
	@Unknown ubyte[0x23B480] unknown1;
	Character[128] _characters;
	@Unknown ubyte[55152] unknown2;
	Item[999] _items;
	@Unknown ubyte[600068] unknown3;
	ushort charCount;
	auto characters() const {
		return _characters[0..charCount];
	}
	auto bagItems() const {
		import std.algorithm : filter;
		return _items[].filter!(x => x.isValid);
	}
}

static assert(D5PC._characters.offsetof == 0x23B480);
static assert(D5PC._items.offsetof == 0x4833F0);
static assert(D5PC.charCount.offsetof == 0x5A815C);
