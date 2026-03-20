class_name ItemStats extends RefCounted

enum Item {
	EXAMPLE_ITEM,
	ITEM_2,
	ITEM_3,
}

var item_name : String
var weight : float
var value : float

func _init(_name: String, _weight: float, _value: float):
	item_name = _name
	weight = _weight
	value = _value

static var items : Dictionary[Item, ItemStats] = {
	Item.EXAMPLE_ITEM: ItemStats.new("Example Item", 1.0, 100.0),
	Item.ITEM_2: ItemStats.new("Item 2", 2.0, 200.0),
	Item.ITEM_3: ItemStats.new("Item 3", 3.0, 300.0),
}

static func get_item(item: Item) -> ItemStats:
	return items[item]
