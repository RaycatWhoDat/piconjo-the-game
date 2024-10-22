extends Node

export (String) var BOSS_1_AREA_NODE_NAME = "BossArea"
export (String) var BOSS_2_AREA_NODE_NAME = "BossArea2"
export (String) var BOSS_3_AREA_NODE_NAME = "BossArea3"
export (String) var BOSS_4_AREA_NODE_NAME = "Phase1"
export (String) var BOSS_5_AREA_NODE_NAME = "BossArea4"

export (int) var BOSS_1_HEALTH_POINTS = 30
export (int) var BOSS_2_HEALTH_POINTS = 20
export (int) var BOSS_3_HEALTH_POINTS = 30
export (int) var BOSS_4_HEALTH_POINTS = 1
# export (int) var BOSS_5_HEALTH_POINTS = 50

export (String) var BOSS_1_NAME = "Tankman"
export (String) var BOSS_2_NAME = "Skull Kid"
export (String) var BOSS_3_NAME = "Strawberry Clock"
export (String) var BOSS_4_NAME = "P.I.C.O"
# export (String) var BOSS_5_NAME = "P.I.C.O"

export (String) var BOSS_1_MUSIC = "res://assets/music/Ughless_Tankbag_Draft_1.mp3"
export (String) var BOSS_2_MUSIC = "res://assets/music/Korded-ft-Larrynachos.mp3"
export (String) var BOSS_3_MUSIC = "res://assets/music/LOLZ.mp3"
export (String) var BOSS_4_MUSIC = ""
# export (String) var BOSS_5_MUSIC = "res://assets/music/Phase_2_w_choir.mp3"

var BOSS_NAMES = {}
var HEALTH_POINTS = {}
var MUSIC = {}

func _ready():
	for index in range(1, 5): # 6):
		var area_name = get(str("BOSS_", index, "_AREA_NODE_NAME"))
		HEALTH_POINTS[area_name] = get(str("BOSS_", index, "_HEALTH_POINTS"))
		BOSS_NAMES[area_name] = get(str("BOSS_", index, "_NAME"))
		MUSIC[area_name] = get(str("BOSS_", index, "_MUSIC"))
