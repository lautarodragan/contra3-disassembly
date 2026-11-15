; sound/stage_music.asm -- Stage music
; Bank $04, $04:D9F1-$04:DA06. Included by main.asm in segment BANK04.
;
; sub_04D9F1 loads the song set of stage $86 (data_05F364) and sends its start
; command (data_05F38A).

sub_04D9F1:
	lda	stage_number
	asl	a
	tay
	lda	a:data_05F364,y
	tax
	phy
	jsl	f:sub_0098D4
	ply
	lda	a:data_05F38A,y
	jsl	f:send_sound_command_now
	rtl
