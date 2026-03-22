extends Node
class_name AudioManager

enum Track {MAIN_MENU,LEVEL,GAME_OVER,VICTORY}

var _current_track : Track

@onready var track_audio_streams : Dictionary[Track,AudioStreamPlayer] = {
	Track.MAIN_MENU : %MenuTheme,
	Track.LEVEL : %UhOhBuddyFullTrack,
	Track.GAME_OVER : %MaybeNextTime,
	Track.VICTORY : %TheHighLife
}


func _ready() -> void:
	Global.audio_manager = self
	_current_track = -1

func play_track(track, delay : float = 0.0):
	if track == _current_track:
		return
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	if _current_track >= 0:
		var old_player = track_audio_streams[_current_track]
		old_player.stop()
	var new_player = track_audio_streams[track]
	new_player.play()
	_current_track = track

func pause_current_track():
	if _current_track:
		track_audio_streams[_current_track].stream_paused = true

func unpause_current_track():
	if _current_track:
		track_audio_streams[_current_track].stream_paused = false
