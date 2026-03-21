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
	Item.LA_LAPIN_DE_VICTORIE:    ItemStats.new("La Lapin de Victorie",       30.0,       300000.0, "res://assets/items/la_lapin_de_victorie.png"),
	Item.ESTAQUE:                 ItemStats.new("Estaque - André DeRain",      2.0,        500000.0, "res://assets/items/estaque.png"),
	Item.SERPENT_WOOD_CARVING:    ItemStats.new("Serpent from Wood Carving",   2.0,         12000.0, "res://assets/items/serpent_wood_carving.png"),
	Item.PIERCED_FORM_AMULET:     ItemStats.new("Pierced Form Amulet",        15.0,        111000.0, "res://assets/items/pierced_form_amulet.png"),
	Item.PURPLE_CAT:              ItemStats.new("Purple Cat - Bill Traylor",   1.0,         10000.0, "res://assets/items/purple_cat.png"),
	Item.LOBSTER_TELEPHONE:       ItemStats.new("Lobster Telephone",          10.0,        500000.0, "res://assets/items/lobster_telephone.png"),
	Item.YELLOW_PEONIES:          ItemStats.new("Yellow Peonies - Yaohua",     0.5,         15000.0, "res://assets/items/yellow_peonies.png"),
	Item.STARRY_NIGHT:            ItemStats.new("Starry Night - Van Gogh",     2.0,     100000000.0, "res://assets/items/starry_night.png"),
	Item.CLOWN_AU_CHAPEAU_POINTU: ItemStats.new("Clown Au Chapeau Pointu",    2.0,         10000.0, "res://assets/items/clown_au_chapeau_pointu.png"),
	Item.VASE:                    ItemStats.new("Vase",                       10.0,         20000.0, "res://assets/items/vase.png"),
	Item.TRANQUIL_NIGHT:          ItemStats.new("Tranquil Night",              2.0,         40000.0, "res://assets/items/tranquil_night.png"),
	Item.MARILYN_DYPTYCH:         ItemStats.new("Marilyn Dyptych - Andy Warhol", 1.0,     100000.0, "res://assets/items/marilyn_dyptych.png"),
	Item.CHEETAH_IN_RED:          ItemStats.new("Cheetah in Red - William Skilling", 2.0,  20000.0, "res://assets/items/cheetah_in_red.png"),
	Item.PLUM_BLOSSOMS_AND_BIRDS: ItemStats.new("Plum Blossoms and Birds",    1.0,         30000.0, "res://assets/items/plum_blossoms_and_birds.png"),
	Item.WATER_LILIES:            ItemStats.new("Water Lilies - Claude Monet", 1.0,        500000.0, "res://assets/items/water_lilies.png"),
}

static func get_item(item: Item) -> ItemStats:
	return items[item]
