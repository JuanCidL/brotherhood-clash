class_name MapUtils

const role_to_character = {
	Statics.Role.NONE : preload("res://scenes/characters/base_character.tscn"),
	Statics.Role.ROLE_A : preload("res://scenes/characters/base_character.tscn"),
	Statics.Role.ROLE_B : preload("res://scenes/characters/base_character.tscn"),
	Statics.Role.ROLE_C : preload("res://scenes/characters/base_character.tscn"),
	Statics.Role.ROLE_D : preload("res://scenes/characters/base_character.tscn")
}

const role_to_sprite = {
	Statics.Role.ROLE_A : "res://resources/character_sprite/inge-dcc",
	Statics.Role.ROLE_B : "res://resources/character_sprite/inge-quim",
	Statics.Role.ROLE_C : "res://resources/character_sprite/inge-bio",
	Statics.Role.ROLE_D : "res://resources/character_sprite/inge-minas"
}

const weapon_map = {
	"Damage": preload("res://scenes/weapons/weapon_damage.tscn"),
	"Dron": preload("res://scenes/weapons/dron_weapon.tscn")
}
