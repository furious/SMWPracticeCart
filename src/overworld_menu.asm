; this code is run once on overworld menu load
; GAME MODE #$1D
ORG !_F+$188000
overworld_menu_load:
		PHP
		PHB
		PHK
		PLB
		
		LDA #$09 ; special world theme
		STA $1DFB ; apu i/o
		STZ $0D9F ; hdmaen
		
		LDA $1F28 ; yellow switch
		BEQ .store_yellow
		LDA #$01
	.store_yellow:
		STA.L !status_yellow
		LDA $1F27 ; green switch
		BEQ .store_green
		LDA #$01
	.store_green:
		STA.L !status_green
		LDA $1F2A ; red switch
		BEQ .store_red
		LDA #$01
	.store_red:
		STA.L !status_red
		LDA $1F29 ; blue switch
		BEQ .store_blue
		LDA #$01
	.store_blue:
		STA.L !status_blue
		
		JSL load_yoshi_color
		
		LDA $19 ; powerup
		STA.L !status_powerup
		LDA $0DC2 ; itembox
		STA.L !status_itembox
		LDA #$00
		STA.L !status_erase
		STA.L !status_enemy
		STA.L !erase_records_flag
		STA.L !status_moviesave
		STA.L !status_movieload
		
		STZ !text_timer
		
		LDA #$80
		STA $2100 ; force blank
		STZ $4200 ; nmi disable
		STZ $420C ; hdmaen
		
		JSR upload_overworld_menu_graphics
		
		REP #$10
		LDA #$21
		STA $40 ; cgadsub mirror
		LDA #$20
		STA $2107 ; bg1 base address & size
		LDA #$33
		STA $2108 ; bg2 base address & size
		STZ $210B ; bg12 name base address
		LDA #$01
		STA $212C ; through main
		LDA #$16
		STA $212D ; through sub
		LDX #$0000
		STX $1E ; layer 2 x position
		LDX #$0000
		STX $20 ; layer 2 y position
		LDA $13
		AND #$EF
		STA $0701
		LDA $14
		AND #$7D
		STA $0702 ; back area color
		SEP #$10
		
		LDX #!number_of_options-1
	.loop_item:
		JSL draw_menu_selection
		DEX
		BPL .loop_item
		
		JSL !_F+$0084C8
		JSL $7F8000
		
		LDX #$07
	.loop_graphics_files:
		STZ $0101,X
		DEX
		BPL .loop_graphics_files
		
		REP #$30
		LDA #$FF00
		LDX #$01BE
	.loop_window:
		STA $04A0,X
		DEX
		DEX
		BPL .loop_window
		SEP #$30
		
		LDA #$01
		STA !in_overworld_menu
		
		LDA #$01
		STA $2105 ; mode
		
		LDA #$81
		STA $4200 ; nmi enable
		STZ $2100 ; exit force blank
		INC $0100
		
		PLB
		PLP
		RTL

; upload all necessary graphics and tilemaps to vram
upload_overworld_menu_graphics:
		PHP
		REP #$10
		SEP #$20
		
		LDA #$80
		STA $2115 ; vram increment
		
		LDX #$2000
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer1_tilemap
		LDX #menu_layer1_tilemap
		LDY #$0800
		JSL load_vram
		
		LDX #$0000
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer2_tiles
		LDX #menu_layer2_tiles
		LDY #$4000
		JSL load_vram
		
		LDX #$3000
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer2_tilemap
		LDX #menu_layer2_tilemap
		LDY #$0800
		JSL load_vram
		
		LDX #$3800
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer2_tilemap
		LDX #menu_layer2_tilemap
		LDY #$0800
		JSL load_vram
		
		LDX #$6000
		STX $2116 ; vram address
		LDA #$18 ; #bank of menu_object_tiles
		LDX #menu_object_tiles
		LDY #$1000
		JSL load_vram
		
		LDA #$00
		STA $2121 ; cgram address
		LDA #$19 ; #bank of menu_palette
		LDX #menu_palette
		LDY #$0100
		JSL load_cgram
		
		LDA #$80
		STA $2121 ; cgram address
		LDA #$19 ; #bank of menu_palette
		LDX #menu_palette
		LDY #$0100
		JSL load_cgram
		
		LDX #$5000
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer3_tilemap
		LDX #menu_layer3_tilemap
		LDY #$0800
		JSL load_vram
		
		PLP
		RTS

; draw one of the menu options to the screen, where X = menu index
draw_menu_selection:
		PHX
		PHP
		PHB
		PHK
		PLB
		
		LDA option_x_position,X
		STA $00
		LDA option_y_position,X
		STA $01
		
		REP #$30
		LDA.L !status_table,X
		AND #$00FF
		STA $0E
		TXA
		ASL A
		TAX
		LDA $0E
		CLC
		ADC option_index,X
		STA $03
		
		LDA $7F837B
		TAX
		SEP #$20
		
		LDA $01
		LSR #3
		ORA #$30
		STA $7F837D+00,X
		LDA $01
		INC A
		LSR #3
		ORA #$30
		STA $7F837D+08,X
		LDA $01
		ASL #5
		ORA $00
		STA $7F837D+01,X
		LDA $01
		INC A
		ASL #5
		ORA $00
		STA $7F837D+09,X
		LDA #$00
		STA $7F837D+02,X
		STA $7F837D+10,X
		LDA #$03
		STA $7F837D+03,X
		STA $7F837D+11,X
		LDA #$FF
		STA $7F837D+16,X
		
		REP #$20
		LDA $03
		ASL #3
		TAY
		LDA menu_option_tiles,Y
		STA $7F837D+04,X
		LDA menu_option_tiles+2,Y
		STA $7F837D+06,X
		LDA menu_option_tiles+4,Y
		STA $7F837D+12,X
		LDA menu_option_tiles+6,Y
		STA $7F837D+14,X
		
		TXA
		CLC
		ADC #$0010
		STA $7F837B
		
		PLB
		PLP
		PLX
		RTL

;		db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E
option_x_position:
		db $06,$06,$06,$06,$06,$09,$09,$09,$09,$18,$0C,$15,$12,$12,$15,$0C,$0F,$0F,$0C,$0F,$18,$0F,$12,$15,$12,$15,$0E,$10,$12,$14,$0C
option_y_position:
		db $03,$06,$09,$0C,$0F,$06,$09,$0C,$03,$0F,$09,$06,$0C,$09,$09,$0F,$06,$09,$06,$0C,$03,$0F,$06,$0C,$0F,$0F,$02,$02,$02,$02,$0C
option_width:
		db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$08,$08,$08,$08,$10
option_height:
		db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
option_type:
		db $01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$01,$01,$01,$03,$03,$01,$01,$01,$01,$01
option_index:
		dw $0001,$0003,$0005,$0007,$0009,$000B,$010B,$020B
		dw $030B,$030C,$0316,$031A,$031D,$031F,$0321,$0323
		dw $0325,$0327,$0332,$033A,$033C,$033D,$033F,$0000
		dw $03A4,$03A6,$03AC,$03AC,$03AC,$03AC,$03AA
menu_option_tiles:
		incbin "bin/menu_option_tiles.bin"
menu_object_tiles:
		incbin "bin/menu_object_tiles.bin"
		
; the text for option titles and descriptions
		incsrc "option_text.asm"

ORG !_F+$198000

; the layer 1 tilemap for the overworld menu
menu_layer1_tilemap:
		incbin "bin/menu_layer1_tilemap.bin"

; the overworld menu graphics
menu_layer2_tiles:
		incbin "bin/menu_layer2_tiles.bin"

; the layer 2 tilemap for the overworld menu
menu_layer2_tilemap:
		incbin "bin/menu_layer2_tilemap.bin"

; the layer 3 tilemap for the overworld menu
menu_layer3_tilemap:
		incbin "bin/menu_layer3_tilemap.bin"

; the palette for the overworld menu
menu_palette:
		incbin "bin/menu_palette.bin"

; which selection to go to when a direction is pressed
;		db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E
selection_press_up:
		db $04,$00,$01,$02,$03,$08,$05,$06,$07,$14,$12,$1D,$0D,$16,$0B,$1E,$1B,$10,$1A,$11,$09,$13,$1C,$0E,$0C,$17,$0F,$15,$18,$19,$0A
selection_press_down:                                                                           
		db $01,$02,$03,$04,$00,$06,$07,$08,$05,$14,$1E,$0E,$18,$0C,$17,$1A,$11,$13,$0A,$15,$09,$1B,$0D,$19,$1C,$1D,$12,$10,$16,$0B,$0F
selection_press_left:                                                                           
		db $14,$0B,$0E,$17,$09,$01,$02,$03,$00,$19,$06,$16,$13,$11,$0D,$04,$12,$0A,$05,$1E,$1D,$0F,$10,$0C,$15,$18,$08,$1A,$1B,$1C,$07
selection_press_right:                                                                          
		db $08,$05,$06,$07,$0F,$12,$0A,$1E,$1A,$04,$11,$01,$17,$0E,$02,$15,$16,$0D,$10,$0C,$00,$18,$0B,$03,$19,$09,$1B,$1C,$1D,$14,$13

; the number of options to allow when holding x or y
minimum_selection_extended:
		db $01,$01,$01,$01,$01,$FF,$FF,$FF,$00,$09,$03,$02,$01,$01,$01,$01,$01,$0A,$07,$01,$00,$01,$64,$00,$01,$03,$28,$28,$28,$28,$01

; the number of options to allow when not holding x or y
minimum_selection_normal:
		db $01,$01,$01,$01,$01,$03,$04,$04,$00,$09,$03,$02,$01,$01,$01,$01,$01,$0A,$07,$01,$00,$01,$37,$00,$01,$03,$28,$28,$28,$28,$01

; this code is run on every frame during the overworld menu game mode (after fade in completes)
; GAME MODE #$1F
overworld_menu:
		PHP
		PHB
		PHK
		PLB
		SEP #$30
		INC $14
		JSL $7F8000
		
		LDA #$00
		ASL A
		TAX
		JSR (overworld_menu_submodes,X)
	
		PLB
		PLP
		RTL

overworld_menu_submodes:
		dw option_selection_mode
		
; run the default part of the menu
option_selection_mode:
		LDA !current_selection
		STA $0A
		
		LDA $24
		BEQ .no_scroll
		SEC
		SBC #$04
		STA $24
		LDA $20
		SEC
		SBC #$04
		STA $20
	.no_scroll:
		
		INC !fast_scroll_timer
		LDA !util_axlr_hold
		AND #%00110000
		BNE .fast_scroll
		STZ !fast_scroll_timer
	.fast_scroll:
		LDA !fast_scroll_timer
		CMP #!fast_scroll_delay
		BCC .test_select
		LDA #!fast_scroll_delay
		STA !fast_scroll_timer
		
	.test_select:
		LDA !erase_records_flag
		BEQ .test_dup
		LDA !util_byetudlr_hold
		AND #%00100000
		BEQ .test_dup
		JSR delete_data
		JMP .finish_no_sound
		
	.test_dup:
		LDA !util_byetudlr_frame
		AND #%00001000
		BEQ .test_ddown
		LDA !current_selection
		TAX
		LDA selection_press_up,X
		STA !current_selection
		JMP .finish_sound
		
	.test_ddown:
		LDA !util_byetudlr_frame
		AND #%00000100
		BEQ .test_dleft
		LDA !current_selection
		TAX
		LDA selection_press_down,X
		STA !current_selection
		JMP .finish_sound
		
	.test_dleft:
		LDA !util_byetudlr_frame
		AND #%00000010
		BEQ .test_dright
		LDA !current_selection
		TAX
		LDA selection_press_left,X
		STA !current_selection
		JMP .finish_sound
		
	.test_dright:
		LDA !util_byetudlr_frame
		AND #%00000001
		BEQ .test_left
		LDA !current_selection
		TAX
		LDA selection_press_right,X
		STA !current_selection
		JMP .finish_sound
		
	.test_left:
		LDA !util_axlr_frame
		AND #%00100000
		BNE .go_left
		LDA !util_axlr_hold
		AND #%00100000
		BEQ .test_right
		LDA !fast_scroll_timer
		CMP #!fast_scroll_delay
		BNE .test_right
	.go_left:
		LDX !current_selection
		LDA.L !status_table,X
		DEC A
		STA.L !status_table,X
		LDA #$00
		JSR check_bounds
		JMP .finish_sound
		
	.test_right:
		LDA !util_axlr_frame
		AND #%00010000
		BNE .go_right
		LDA !util_axlr_hold
		AND #%00010000
		BEQ .test_selection
		LDA !fast_scroll_timer
		CMP #!fast_scroll_delay
		BNE .test_selection
	.go_right:
		LDX !current_selection
		LDA.L !status_table,X
		INC A
		STA.L !status_table,X
		LDA #$01
		JSR check_bounds
		JMP .finish_sound
		
	.test_selection:
		LDA !util_axlr_frame
		ORA !util_byetudlr_frame
		AND #%10000000
		BNE .make_selection
		JMP .test_start
	.make_selection:
		LDA !current_selection
		ASL A
		TAX
		JMP (.selection_table,X)
		
	.selection_table:
		dw .select_yellow
		dw .select_green
		dw .select_red
		dw .select_blue
		dw .select_special
		dw .select_powerup
		dw .select_itembox
		dw .select_yoshi
		dw .select_enemy
		dw .select_records
		dw .select_slots
		dw .select_fractions
		dw .select_pause
		dw .select_timedeath
		dw .select_music
		dw .select_drop
		dw .select_states
		dw .select_statedelay
		dw .select_dynmeter
		dw .select_slowdown
		dw .select_help
		dw .select_lrreset
		dw .select_scorelag
		dw .select_placeholder
		dw .select_moviesave
		dw .select_movieload
		dw .select_name
		dw .select_name
		dw .select_name
		dw .select_name
		dw .select_region
		dw .select_exit
		
	.select_yellow:
	.select_green:
	.select_red:
	.select_blue:
	.select_special:
	.select_powerup:
	.select_itembox:
	.select_slots:
	.select_fractions:
	.select_pause:
	.select_timedeath:
	.select_music:
	.select_drop:
	.select_dynmeter:
	.select_states:
	.select_statedelay:
	.select_slowdown:
	.select_lrreset:
	.select_scorelag:
	.select_placeholder:
	.select_region:
	.select_name:
		JMP .finish_no_sound
	.select_help:
		LDA #$0B ; on/off sound
		STA $1DF9 ; apu i/o
		JMP .no_update_text
	.select_yoshi:
		LDA #$1F ; yoshi sound
		STA $1DFC ; apu i/o
		JMP .finish_no_sound
	.select_records:
		LDA #$24 ; "press select to confirm"
		STA $12 ; stripe image loader
		LDA.L !status_erase
		INC A
		STA !erase_records_flag
		LDA #$0B ; itembox sound
		STA $1DFC ; apu i/o
		LDA #$80 ; fade out music
		STA $1DFB ; apu i/o
		JMP .finish_no_sound
	.select_enemy:
		LDA #$01 ; coin sound
		STA $1DFC ; apu i/o
		JSR reset_enemy_states
		JMP .finish_no_sound
	.select_moviesave:
		JSR export_movie_to_sram
		JMP .finish_no_sound
	.select_movieload:
		JSR load_movie
		JMP .finish_no_sound
	.select_exit:
		LDA #$29 ; ding sound
		STA $1DFC ; apu i/o
		JMP .quit
	
	.test_start:
		LDA !util_byetudlr_frame
		AND #%00010000
		BEQ .finish_no_sound
		JMP .select_exit
		
	.quit:
		LDA #$0B
		STA $0100 ; game mode
		
		JSL restore_basic_settings
		
		BRA .finish_no_sound
	
	.finish_sound:
		LDA #$06 ; fireball sound
		STA $1DFC ; apu i/o
		LDX !current_selection
		JSL draw_menu_selection
		
	.finish_no_sound:
		JSL draw_option_cursor
		JSL draw_option_text
		
		LDA !text_timer
		CMP #$31
		BCS .no_inc_text
		INC A
		STA !text_timer
	.no_inc_text:
		LDX !current_selection
		CPX $0A
		BEQ .no_update_text
		STZ !text_timer
	.no_update_text:
		RTS
		
; copy currently loaded movie to sram
export_movie_to_sram:
		PHP
		REP #$30
		LDA #$7070
		STA $02
		LDA #$7000
		STA $00
		LDA.L !status_moviesave
		AND #$00FF
		XBA
		ASL #3
		TAY
		LDX #$0000
		
	.loop:
		LDA.L !movie_location+3,X
		STA [$00],Y
		INY #2
		INX #2
		CPX #$0800
		BNE .loop
		
		SEP #$20
		LDA #$01 ; coin sound
		STA $1DFC ; apu i/o
		
		PLP
		RTS
		
; copy a movie from sram or rom to ram
load_movie:
		PHP
		PHB
		PHK
		PLB
		LDA.L !status_movieload
		CMP #$02
		BCS .getptr
		STA $00
		ASL A
		CLC
		ADC $00
		TAX
		LDA sram_movie_locations,X
		STA $00
		LDA sram_movie_locations+1,X
		STA $01
		LDA sram_movie_locations+2,X
		STA $02
		BRA .copy
	.getptr:
		DEC #2
		STA $00
		ASL A
		CLC
		ADC $00
		TAX
		LDA rom_movie_locations,X
		STA $00
		LDA rom_movie_locations+1,X
		STA $01
		LDA rom_movie_locations+2,X
		STA $02
		LDA !potential_translevel
		ASL A
		TAY
		REP #$20
		LDA [$00],Y
		STA $00
		SEP #$20
		BEQ .error
		
	.copy:
		REP #$30
		LDY #$0000
		LDX #$0000
	.loop:
		LDA [$00],Y
		STA.L !movie_location+3,X
		INY #2
		INX #2
		CPX #$0800
		BNE .loop
		
		SEP #$20
		LDA #$01 ; coin sound
		STA $1DFC ; apu i/o	
		BRA .exit
	.error:
		LDA #$2A ; wrong sound
		STA $1DFC ; apu i/o	
	.exit:
		PLB
		PLP
		RTS
		
sram_movie_locations:
		dl $707000, $707800
rom_movie_locations:
		dl translevel_movie_ptr_A, translevel_movie_ptr_B

		
; restore gameplay settings
restore_basic_settings:
		LDA.L !status_yellow
		STA $1F28 ; yellow switch
		LDA.L !status_green
		STA $1F27 ; green switch
		LDA.L !status_red
		STA $1F2A ; red switch
		LDA.L !status_blue
		STA $1F29 ; blue switch
		JSL save_yoshi_color
		LDA #$01
		STA $0DC1 ; persistant yoshi
		LDA.L !status_powerup
		STA $19 ; powerup
		STA $0DB8 ; ow powerup
		LDA.L !status_itembox
		STA $0DC2 ; itembox
		STA $0DBC ; ow itembox
		RTL
		
; draw the flashing cursor to the screen:
draw_option_cursor:
		PHP
		PHB
		PHK
		PLB
		
		LDA !current_selection
		TAX
		LDA option_width,X
		STA $00
		LDA option_height,X
		STA $01
		LDA option_type,X
		STA $03
		LDA option_y_position,X
		ASL #3
		SEC
		SBC #$09
		REP #$20
		AND #$00FF
		SEC
		SBC $24
		BPL .continue
		CMP #$FFE8
		BCC .done		
	.continue:
		SEP #$20
		TAY
		LDA option_x_position,X
		ASL #3
		SEC
		SBC #$08
		TAX
		
		LDA !util_axlr_hold
		ORA !util_byetudlr_hold
		AND #%01000000
		BEQ .no_color
		LDA #$01
		BRA .merge_color
	.no_color:
		LDA #$00
	.merge_color:
		STA $04
		
		REP #$10
		LDA !fast_scroll_timer
		CMP #!fast_scroll_delay
		BEQ .squeezed
		LDA #$00
		BRA .merge_squeezed
	.squeezed:
		LDA #$01
	.merge_squeezed:
		STA $02
		
		SEP #$10
		JSR draw_generic_cursor
		
	.done:
		SEP #$20
		PLB
		PLP
		RTL
		
; load yoshi color from yoshi space to simple space
load_yoshi_color:
		PHB
		PHK
		PLB
		LDA $0DBA ; ow yoshi color
		CMP #$0B
		BCS .done
		TAX
		LDA yoshi_color_mapping_input,X
	.done:
		STA.L !status_yoshi
		PLB
		RTL
		
; save yoshi color from simple space to yoshi space
save_yoshi_color:
		PHB
		PHK
		PLB
		LDA.L !status_yoshi
		CMP #$0B
		BCS .done
		TAX
		LDA yoshi_color_mapping_output,X
	.done:
		STA $0DBA ; ow yoshi color
		STA $13C7 ; level yoshi color
		PLB
		RTL
		
yoshi_color_mapping_input:
		db $00,$05,$06,$07,$01,$08,$02,$09,$03,$0A,$04
yoshi_color_mapping_output:
		db $00,$04,$06,$08,$0A,$01,$02,$03,$05,$07,$09

; update the background offset and colorg
update_background:
		SEP #$20
		INC $1A ; layer 1 x position
		LDA $13 ; frame counter
		AND #$01
		BEQ .done
		DEC $1C ; layer 1 y position
	.done:
		RTL

; check the bounds on the menu options, and fix them if they are out of bounds
; X = option index
check_bounds:
		PHP
		PHY
		PHA
		LDA.L !status_table,X
		TAY
		PLA
		REP #$10
		PHY
		PHA
		LDA !util_byetudlr_hold
		ORA !util_axlr_hold
		AND #%01000000
		BEQ .not_extended
		LDA minimum_selection_extended,X
		BRA .merge
	.not_extended:
		LDA minimum_selection_normal,X
	.merge:
		REP #$20
		AND #$00FF
		CMP $02,S
		SEP #$30
		BPL .out
		PLY
		BNE .increasing
		STA.L !status_table,X
		BRA .done
	.increasing:
		LDA #$00
		STA.L !status_table,X
		BRA .done
	.out:
		PLY
	.done:
		PLY
		PLY
		PLY
		PLP
		RTS
		
; reset persistant enemy states
; right now this only includes boo cloud and boo ring angles
reset_enemy_states:
		PHP
		REP #$30
		PHX
		STZ $0FAE
		STZ $0FB0 ; boo ring angles
		
		LDX #$004E
	.loop_boo_cloud:
		STZ $1E52,X ; cluster sprite table
		STZ $190A,X ; cluster sprite table
		DEX
		DEX
		BPL .loop_boo_cloud
		
		PLX
		PLP
		RTS

; clear all the times saved in memory
; this is also run the first time you start up the game
delete_all_data:
		PHP
		PHB
		PHK
		PLB
		REP #$30
		
		LDA #$FFFF
		LDX #$0FDE
	.loop:
		STA $700020,X
		CPX #$0320
		BNE +
		TXA
		SEC
		SBC #$0020
		TAX
		LDA #$FFFF
	+	DEX
		DEX
		BPL .loop
		BRA temp
		
temp_default_meters:
		PHP
		PHB
		PHK
		PLB
		REP #$30
temp:
		LDX #$005E
	.loop_meters:
		LDA default_meters,X
		STA.L !statusbar_meters,X
		DEX #2
		BPL .loop_meters
		
		PLB
		PLP
		RTL

; the default set of statusbar meters
default_meters:
		db $01,$00,$00,$21
		db $02,$00,$00,$21
		db $03,$00,$00,$41
		db $04,$00,$00,$61
		db $05,$00,$00,$24
		db $06,$00,$00,$44
		db $08,$00,$00,$26
		db $09,$00,$00,$47
		db $0A,$00,$00,$67
		db $07,$00,$00,$89
		db $0B,$00,$00,$32
		db $11,$14,$8D,$52
		db $11,$14,$8E,$54
		db $0C,$01,$00,$72
		db $0D,$00,$00,$36
		db $0E,$00,$00,$37
		db $0F,$00,$00,$81
		db $10,$00,$00,$98
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00

; clear all records from one level
; A = translevel to delete
delete_translevel_data:
		PHP
		CMP #$00 ; level 00 contains file info, so never delete it
		BEQ .done
		CMP #$19 ; level 19 contains options, so never delete it
		BEQ .done
		
		LDX #$07
	.loop:
		JSL delete_one_record
		DEX
		BPL .loop
		
	.done:		
		PLP
		RTL

; clear a record where A = translevel & X = 00000xkk, x = normal/secret, kk = kind
; restores A & X
delete_one_record:
		PHP
		PHA
		
		REP #$20
		AND #$00FF
		ASL #5
		STA $00
		SEP #$20
		TXA
		ASL #2
		TSB $00
		LDA #$70
		STA $02
		
		LDA #$FF
		LDY #$03
	.loop:
		STA [$00],Y
		DEY
		BPL .loop
		
		PLA
		PLP
		RTL
		
; function that runs if select is pressed after choosing delete data
delete_data:
		LDA #$18 ; thunder
		STA $1DFC ; apu i/o
		LDA #$27 ; "the data has been erased"
		STA $12 ; stripe image loader
		LDA #$09 ; replay music
		STA $1DFB ; apu i/o
		LDA !erase_records_flag
		DEC A
		ASL A
		TAX
		JMP (.delete_table,X)
	
	.delete_table:
		dw .delete_all
		dw .delete_level
		dw .delete_normal_low
		dw .delete_normal_nocape
		dw .delete_normal_cape
		dw .delete_normal_lunardragon
		dw .delete_secret_low
		dw .delete_secret_nocape
		dw .delete_secret_cape
		dw .delete_secret_lunardragon
		
	.delete_all:
		JSL delete_all_data
		JMP .done
	.delete_level:
		LDA !potential_translevel
		JSL delete_translevel_data
		JMP .done
	.delete_normal_low:
	.delete_normal_nocape:
	.delete_normal_cape:
	.delete_normal_lunardragon:
	.delete_secret_low:
	.delete_secret_nocape:
	.delete_secret_cape:
	.delete_secret_lunardragon:
		LDA !erase_records_flag
		DEC A
		DEC A
		DEC A
		TAX
		LDA !potential_translevel
		JSL delete_one_record
		JMP .done
		
	.done:
		STZ !erase_records_flag
		RTS

; A|X = address of data, Y = number of bytes
; requires 8-bit accumulator, 16-bit index
load_vram:
		PHP
		PHA
		
		STX $4302 ; dma0 source address
		STA $4304 ; dma0 source bank
		STY $4305 ; dma0 length
		
		LDA #$01 ; 2-byte, low-high
		STA $4300 ; dma0 parameters
		LDA #$18 ; $2118, vram data
		STA $4301 ; dma0 destination
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		PLA
		PLP
		RTL

; A|X = address of data, Y = number of bytes
; requires 8-bit accumulator, 16-bit index
load_cgram:
		PHP
		PHA
		
		STX $4302 ; dma0 source address
		STA $4304 ; dma0 source bank
		STY $4305 ; dma0 length
		
		LDA #$00 ; 1-byte
		STA $4300 ; dma0 parameters
		LDA #$22 ; $2122, cgram data
		STA $4301 ; dma0 destination
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		PLA
		PLP
		RTL

; stripe images for text when deleting data
stripe_confirm:
		db $52,$42,$00,$31
		db $19,$38
		db $1B,$38,$0E,$38
		db $1C,$38,$1C,$38
		db $FC,$38,$1C,$38
		db $0E,$38,$15,$38
		db $0E,$38,$0C,$38
		db $1D,$38,$FC,$38
		db $1D,$38,$18,$38
		db $FC,$38,$0C,$38
		db $18,$38,$17,$38
		db $0F,$38,$12,$38
		db $1B,$38,$16,$38
		db $FC,$38,$FC,$38
		db $FF
stripe_deleted:
		db $52,$42,$00,$31
		db $1D,$38,$11,$38
		db $0E,$38,$FC,$38
		db $0D,$38,$0A,$38
		db $1D,$38,$0A,$38
		db $FC,$38
		db $11,$38,$0A,$38
		db $1C,$38,$FC,$38
		db $0B,$38,$0E,$38
		db $0E,$38,$17,$38
		db $FC,$38,$0D,$38
		db $0E,$38,$15,$38
		db $0E,$38,$1D,$38
		db $0E,$38,$0D,$38
		db $FF

; draw option title and description
draw_option_text:
		LDA !text_timer
		AND #$07
		BEQ .continue
		BRL .done
		
	.continue:
		LDA !text_timer
		BNE .draw_description_line
		BRL .draw_title_and_clear
	.draw_description_line:
		REP #$30
		LDA !current_selection
		AND #$00FF
		ASL #6
		STA $00
		ASL A
		CLC
		ADC $00
		CLC
		ADC #option_description
		STA $00
		LDA !text_timer
		AND #$00FF
		SEC
		SBC #$0008
		ASL #2
		CLC
		ADC $00
		STA $00
		LDA #$3C3C
		STA $02
		LDA !text_timer
		AND #$00FF
		SEC
		SBC #$0008
		ASL #2
		CLC
		ADC #$52A0
		XBA
		TAY
		
		JSR draw_text_string
		BRL .done
	.draw_title_and_clear:
		REP #$30
		LDA !current_selection
		AND #$00FF
		ASL #5
		CLC
		ADC #option_title
		STA $00
		LDA #$3434
		STA $02
		LDY #$6052
		
		JSR draw_text_string
		
		LDA.L $7F837B
		TAX
		LDA #$A052
		STA.L $7F837D,X
		LDA #$7F41
		STA.L $7F837F,X
		LDA #$38FC
		STA.L $7F8381,X
		LDA #$FFFF
		STA.L $7F8383,X
		TXA
		CLC
		ADC #$0006
		STA.L $7F837B	
	.done:
		SEP #$30
		RTL

; draw a text string
; where $00|01 holds the pointer to the 32-byte long string
; and $02 holds the property byte for the text
; and Y (16-bit) holds the 16-bit header for the stripe image
draw_text_string:
		PHB
		PEA $1818
		PLB
		PLB
		LDA.L $7F837B
		TAX
		TYA
		STA.L $7F837D,X
		LDA #$3F00
		STA.L $7F837F,X
		LDY #$0000
		SEP #$20
		
	.loop_string:
		LDA ($00),Y
		STA.L $7F8381,X
		INX
		LDA $02
		STA.L $7F8381,X
		INX
		INY
		CPY #$0020
		BNE .loop_string
		
		REP #$20
		LDA.L $7F837B
		TAX
		LDA #$FFFF
		STA.L $7F83C1,X
		LDA.L $7F837B
		CLC
		ADC #$0044
		STA.L $7F837B
		PLB
		RTS

; draw a cursor
; where X = x pos, Y = y pos, $00 = width, $01 = height, $02 = squeezed, $03 = cursor type, $04 = change color
draw_generic_cursor:
		PHX
		PHY
		
		LDA $02
		BEQ .not_squeezed
		LDA #$00
		BRA .merge_squeeze
	.not_squeezed
		LDA $13 ; frame counter
		AND #$10
		BEQ .frame_2
		LDA #$02
		BRA .merge_squeeze
	.frame_2:
		LDA #$01
	.merge_squeeze:
		STA $0F
		LDA #$02
		STA $07
		
		TXA
		SEC
		SBC $0F
		STA $0E
		TYA
		SEC
		SBC $0F
		TAY
		LDA !util_axlr_hold
		AND #%00100000
		BEQ .tl_not_red
		LDA #$3C
		BRA .merge_tl_color
	.tl_not_red:
		LDA $04
		BEQ .tl_its_white
		LDA #$3A
		BRA .merge_tl_color
	.tl_its_white:
		LDA #$36
	.merge_tl_color:
		STA $05
		LDA #$00
		STA $06
		LDA $03
		AND #$01
		TAX
		LDA cursor_tiles,X
		LDX $0E
		JSR draw_cursor_bit
		
		PLY
		PLX
		PHX
		PHY
		TXA
		CLC
		ADC $0F
		CLC
		ADC $00
		STA $0E
		TYA
		SEC
		SBC $0F
		TAY
		LDA !util_axlr_hold
		AND #%00010000
		BEQ .tr_not_red
		LDA #$3C
		BRA .merge_tr_color
	.tr_not_red:
		LDA $04
		BEQ .tr_its_white
		LDA #$3A
		BRA .merge_tr_color
	.tr_its_white:
		LDA #$36
	.merge_tr_color:
		ORA #$40
		STA $05
		LDA #$04
		STA $06
		LDA $03
		AND #$01
		TAX
		LDA cursor_tiles,X
		LDX $0E
		JSR draw_cursor_bit
		
		PLY
		PLX
		PHX
		PHY
		TXA
		SEC
		SBC $0F
		STA $0E
		TYA
		CLC
		ADC $0F
		CLC
		ADC $01
		TAY
		LDA $04
		BEQ .bl_its_white
		LDA #$3A
		BRA .merge_bl_color
	.bl_its_white:
		LDA #$36
	.merge_bl_color:
		ORA #$80
		STA $05
		LDA #$08
		STA $06
		LDA cursor_tiles
		LDX $0E
		JSR draw_cursor_bit
		
		PLY
		PLX
		PHX
		PHY
		TXA
		CLC
		ADC $0F
		CLC
		ADC $00
		STA $0E
		TYA
		CLC
		ADC $0F
		CLC
		ADC $01
		TAY
		LDA $04
		BEQ .br_its_white
		LDA #$3A
		BRA .merge_br_color
	.br_its_white:
		LDA #$36
	.merge_br_color:
		ORA #$C0
		STA $05
		LDA #$0C
		STA $06
		LDA $03
		AND #$02
		TAX
		LDA cursor_tiles,X
		LDX $0E
		JSR draw_cursor_bit
		
		PLY
		PLA
		CMP #$09
		BCC .set_msb
		LDA #$AA
		BRA .merge_msb
	.set_msb:
		LDA #$BB
	.merge_msb:
		STA $0400
		
		RTS

cursor_tiles:
		db $06,$08,$0A

; draw 1/4 of a cursor
; where x = x pos, Y = y pos, A = tile byte, $05 = property byte, $06 = pointer to oam
; if carry is clear, set high x position bit
draw_cursor_bit:
		PHY
		LDY #$02
		STA ($06),Y
		PLA
		DEY
		STA ($06),Y
		DEY
		TXA
		STA ($06),Y
		LDY #$03
		LDA $05
		STA ($06),Y
		RTS		
	
; check the saved options, and if any are out of bounds, set them to zero as a failsafe
failsafe_check_option_bounds:
		PHP
		PHB
		PHK
		PLB
		SEP #$30
		
		LDX #!number_of_options-1
	.loop:
		LDA.L !status_table,X
		DEC A
		CMP minimum_selection_extended,X
		BCC .not_oob
		LDA #$00
		STA.L !status_table,X
		
	.not_oob:
		DEX
		BPL .loop
		
		PLB
		PLP
		RTL