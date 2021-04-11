extends Node

export (String) var BOSS_1_AREA_NODE_NAME = "BossArea"
export (String) var BOSS_2_AREA_NODE_NAME = "BossArea2"
export (String) var BOSS_3_AREA_NODE_NAME = "BossArea3"
export (String) var BOSS_4_AREA_NODE_NAME = "BossArea4"

export (int) var BOSS_1_HEALTH_POINTS = 5
export (int) var BOSS_2_HEALTH_POINTS = 20
export (int) var BOSS_3_HEALTH_POINTS = 25
export (int) var BOSS_4_HEALTH_POINTS = 30

export (String) var BOSS_1_NAME = "Tankman"
export (String) var BOSS_2_NAME = "Skeleton Boy"
export (String) var BOSS_3_NAME = "Strawberry Clock"
export (String) var BOSS_4_NAME = "P.I.C.O"

var BOSS_NAMES = {}
var HEALTH_POINTS = {}

func _ready():
	for index in range(1, 4):
		var area_name = get(str("BOSS_", index, "_AREA_NODE_NAME"))
		HEALTH_POINTS[area_name] = get(str("BOSS_", index, "_HEALTH_POINTS"))
		BOSS_NAMES[area_name] = get(str("BOSS_", index, "_NAME"))
