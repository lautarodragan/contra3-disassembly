; sound/stage_music.asm -- Stage music
; Bank $04, $04:D9F1-$04:DA06. Included by main.asm in segment BANK04.
;
; load_stage_music loads song set number stage_number (song_lists) and sends
; its start command (song_start_commands). Songs are numbered by their entry
; in these two tables; game/sound_check.asm (sound_check_play) uses the same
; tables. In the extra-stage build (game/stages.inc) the song of each stage
; comes from stage_songs instead, so that song_lists keeps its numbering.

load_stage_music:
.if CHEAT_EXTRA_STAGE
	lda	stage_number
	asl	a
	tax
	lda	f:stage_songs,x
	asl	a
	tay
.else
	lda	stage_number
	asl	a
	tay
.endif
	lda	a:song_lists+2,y
	tax
	phy
	jsl	f:load_song_set
	ply
	lda	a:song_start_commands+2,y
	jsl	f:send_sound_command_now
	rtl

.if CHEAT_EXTRA_STAGE
; The song of each stage, by stage_number: an entry of song_lists + 2 (the
; original stage n's song set is entry n; the opening's is entry 0). The
; extra stage plays stage 1's.
stage_songs:
	.word	0
	per_stage_word	1, 2, 3, 4, 5, 6, 1
.endif
