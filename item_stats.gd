@tool
class_name ItemStats extends RefCounted

enum Item {
	LA_LAPIN_DE_VICTORIE,
	ESTAQUE,
	SERPENT_WOOD_CARVING,
	PIERCED_FORM_AMULET,
	PURPLE_CAT,
	LOBSTER_TELEPHONE,
	YELLOW_PEONIES,
	STARRY_NIGHT,
	CLOWN_AU_CHAPEAU_POINTU,
	VASE,
	TRANQUIL_NIGHT,
	MARILYN_DYPTYCH,
	CHEETAH_IN_RED,
	PLUM_BLOSSOMS_AND_BIRDS,
	WATER_LILIES,
}

var item_name : String
var weight : float
var value : float
var image_path: String

func _init(_name: String, _weight: float, _value: float, _image_path: String = ""):
	item_name = _name
	weight = _weight
	value = _value
	image_path = _image_path

static var items : Dictionary[Item, ItemStats] = {
	Item.LA_LAPIN_DE_VICTORIE:    ItemStats.new("La Lapin de Victorie",            13.0,       300000.0, "res://assets/items/La_Lapin_De_Victoire.png"),
	Item.ESTAQUE:                 ItemStats.new("Estaque - André DeRain",          2.0,        700000.0, "res://assets/items/Estaque_AndreDerain.png"),
	Item.SERPENT_WOOD_CARVING:    ItemStats.new("Serpent from Wood Carving",       2.0,         12000.0, "res://assets/items/Serpent_From_Wood_Carving.png"),
	Item.PIERCED_FORM_AMULET:     ItemStats.new("Pierced Form Amulet",            12.0,        111000.0, "res://assets/items/Pierced_Form_Amulet_BarbaraHepworth.png"),
	Item.PURPLE_CAT:              ItemStats.new("Purple Cat - Bill Traylor",       1.0,         10000.0, "res://assets/items/Purple_Cat_BillTraylor.png"),
	Item.LOBSTER_TELEPHONE:       ItemStats.new("Lobster Telephone",              10.0,        500000.0, "res://assets/items/Lobster_Telephone_SalvadorDali.png"),
	Item.YELLOW_PEONIES:          ItemStats.new("Yellow Peonies - Yaohua",         0.5,         15000.0, "res://assets/items/Yellow_Peonies_YaoHua.png"),
	Item.STARRY_NIGHT:            ItemStats.new("Starry Night - Van Gogh",         2.0,     100000000.0, "res://assets/items/The_Starry_Night_VincentvanGogh.png"),
	Item.CLOWN_AU_CHAPEAU_POINTU: ItemStats.new("Clown Au Chapeau Pointu",        2.0,         10000.0, "res://assets/items/Clown_Au_Chapeau_Pointu_BenardBuffet.png"),
	Item.VASE:                    ItemStats.new("Vase",                           7.0,         20000.0, "res://assets/items/Default_Vase.png"),
	Item.TRANQUIL_NIGHT:          ItemStats.new("Tranquil Night",                  2.0,         40000.0, "res://assets/items/Tranquil_Night_MontagueDawson.png"),
	Item.MARILYN_DYPTYCH:         ItemStats.new("Marilyn Dyptych - Andy Warhol",   1.0,        100000.0, "res://assets/items/Marilyn_Diptych_AndyWarhol.png"),
	Item.CHEETAH_IN_RED:          ItemStats.new("Cheetah in Red - William Skilling", 2.0,       20000.0, "res://assets/items/Cheetah_In_Red_ Harness_WilliamSkilling.png"),
	Item.PLUM_BLOSSOMS_AND_BIRDS: ItemStats.new("Plum Blossoms and Birds",         1.0,         30000.0, "res://assets/items/Plum_Blossoms_And_Birds_ZhuChan.png"),
	Item.WATER_LILIES:            ItemStats.new("Water Lilies - Claude Monet",     1.0,        500000.0, "res://assets/items/Water_Lilies_ClaudeMonet.png"),
}

static func get_item(item: Item) -> ItemStats:
	return items[item]
