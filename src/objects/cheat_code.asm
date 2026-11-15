; objects/cheat_code.asm -- Routines of the build-time cheats (milestone 4)
; Bank $01, after the last routine of the bank (stage_palette_anim.asm), in
; the bank's free space.  Included by main.asm in segment BANK01.
;
; Empty unless a cheat that needs one of these routines is enabled (see
; cheats.inc and the book's "Cheats" page), so the default build is the
; original ROM.  Everything else the cheats change is an `.if CHEAT_X` at
; the place it changes.

.if CHEAT_CODE_NEEDED

.if CHEAT_INVINCIBLE | CHEAT_NO_PIT_DEATH
; Called (JSR) at the top of kill_player, X = player, A16/I16.  Decides
; whether the death goes ahead: if so, returns to kill_player.  Otherwise
; it does not return there: it drops its return address and either
; - (falling off the bottom of the screen, CHEAT_NO_PIT_DEATH) puts the
;   player in PLAYER_STATE_OUT, which respawns it next frame the way a
;   death does (respawn placement, invulnerability) without taking a life,
;   and returns from the state handler (RTL), or
; - (any other death, CHEAT_INVINCIBLE) clears PCONTACT_KILLED and runs the
;   player's state handler again (run_player_state_dispatch), so the
;   frame goes on as if nothing had touched the player.
; Below the screen is tested as in kill_player (y >= $F8, not negative).
cheat_filter_death:
	lda	OBJ_Y,x
	cmp	#$00F8
	bcc	@not_pit
	bmi	@not_pit
.if CHEAT_NO_PIT_DEATH
	pla				; drop the return address into kill_player
	lda	#PLAYER_STATE_OUT
	sta	OBJ_STATE,x
	rtl
.else
	rts				; dies
.endif
@not_pit:
.if CHEAT_INVINCIBLE
	pla				; drop the return address into kill_player
	lda	PLAYER_CONTACT,x
	and	#($FFFF ^ PCONTACT_KILLED)
	sta	PLAYER_CONTACT,x
	jmp	a:run_player_state_dispatch
.else
	rts				; dies
.endif
.endif

.endif
