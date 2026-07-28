extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var start_marker: Marker2D = $StartMarker
@onready var finish_area: Area2D = $FinishArea
@onready var win_panel: PanelContainer = $HUD/WinPanel
@onready var controls_label: Label = $HUD/HeaderPanel/MarginContainer/VBoxContainer/ControlsLabel
@onready var state_label: Label = $HUD/StateLabel

var game_won: bool = false

func _ready() -> void:
	if finish_area:
		finish_area.body_entered.connect(_on_finish_area_body_entered)

	if player and start_marker:
		player.global_position = start_marker.global_position
		if player.has_signal("died"):
			player.connect("died", _on_player_died)

	if win_panel:
		win_panel.visible = false

func _process(_delta: float) -> void:
	_update_hud()
	
	if Input.is_action_just_pressed("ui_cancel") or Input.is_key_pressed(KEY_R):
		restart_level()

func _update_hud() -> void:
	if not player or not state_label:
		return
	
	var state_str = "Ground" if player.is_on_floor() else "Air"
	if player.get("is_backdashing") == true:
		state_str = "BACKDASH"
	elif player.get("is_attacking") == true:
		state_str = "ATTACK"
		
	state_label.text = "Player Status: " + state_str + " | Pos: (" + str(int(player.global_position.x)) + ", " + str(int(player.global_position.y)) + ")"

func _on_finish_area_body_entered(body: Node2D) -> void:
	if body == player and not game_won:
		game_won = true
		if win_panel:
			win_panel.visible = true

func _on_player_died() -> void:
	restart_level()

func restart_level() -> void:
	game_won = false
	if win_panel:
		win_panel.visible = false
	if player and start_marker:
		player.global_position = start_marker.global_position
		player.velocity = Vector2.ZERO
		if player.get("current_hp") != null and player.get("max_hp") != null:
			player.set("current_hp", player.get("max_hp"))

func _on_pit_hazard_body_entered(body: Node2D) -> void:
	if body == player:
		restart_level()
