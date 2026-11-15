; sound/stage_music.asm -- Stage music
; Bank $04, $04:D9F1-$04:DA06. Included by main.asm in segment BANK04.
;
; load_stage_music loads song set number stage_number (song_lists) and sends
; its start command (song_start_commands). Songs are numbered by their entry
; in these two tables; game/sound_check.asm (sound_check_play) uses the same
; tables.

load_stage_music:
	lda	stage_number
	asl	a
	tay
	lda	a:song_lists+2,y
	tax
	phy
	jsl	f:load_song_set
	ply
	lda	a:song_start_commands+2,y
	jsl	f:send_sound_command_now
	rtl
