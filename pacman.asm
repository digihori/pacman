# internal RAM registers
REGI	equ	$0
REGJ	equ	$1
REGA	equ	$2
REGB	equ	$3
REGXL	equ	$4
REGXH	equ	$5
REGYL	equ	$6
REGYH	equ	$7
REGK	equ	$10
REGL	equ	$11
REGM	equ	$12
REGN	equ	$13


DSPON	equ	$04b1
INKEY	equ	$0436
#CLS	equ	$d90c

VRAM00	equ	$7000
VRAM01	equ	$7200
VRAM02	equ	$7400
VRAM03	equ	$7600
VRAM04	equ	$7800
VRAM10	equ	$7040
VRAM11	equ	$7240
VRAM12	equ	$7440
VRAM13	equ	$7640
VRAM14	equ	$7840
VRAM20	equ	$701e
VRAM21	equ	$721e
VRAM22	equ	$741e
VRAM23	equ	$761e
VRAM24	equ	$781e
VRAM30	equ	$705e
VRAM31	equ	$725e
VRAM32	equ	$745e
VRAM33	equ	$765e
VRAM34	equ	$785e

VV_S0	equ	$6900
VV_S1	equ	$69c0
VV_S2	equ	$6a80
VV_S3	equ	$6b40

MON_S	equ	$69c0
MON_P	equ	$6900

org $6100

begin:
	cal DSPON

	lia $9c
	lip REGK
	exam		# REGK 初期値
	lia $e8
	lip REGL
	exam		# REGL 初期値
	lip REGM
	clra
	exam		# REGM 0 初期値
	lip REGN
	clra
	exam		# REGN 0 初期値
	lidp VV_S0
	clra
	lii $c0-1
	fild		# VVRAMクリア
	lidp VV_S1
	fild		# VVRAMクリア
	lidp VV_S2
	fild		# VVRAMクリア
	lidp VV_S3
	fild		# VVRAMクリア

init:
	call INKEY	# キーが何も押されていない
	jrcm init

	#call CLS

	#jp second
mainloop1:
pacman:
	lip REGK
	cpim 0
	jrzp monster
	call pac_disp
	lip REGK
	sbim 2
monster:
	lip REGL
	cpim 0
	jrzp second
	cpim $9c
	jrncp next1
	call mon_disp
next1:
	lip REGL
	sbim 2
	tsim $02
	jrzp next
	sbim 1
next:
	call vvtrans
loop1:
	#call wait
	cal INKEY
	jrncm mainloop1

second:
	clra
	lip REGK
	exam		# REGK 初期値
	clra
	lip REGL
	exam		# REGL 初期値
	lip REGM
	clra
	exam		# REGM 0 初期値
	lip REGN
	clra
	exam		# REGN 0 初期値

mainloop2:

monster2:
	lip REGL
	cpim $9c
	jrzp bpacman
	cpim $0a
	jrcp next3
	call mon_disp2
next3:
	lip REGL
	adim 2

bpacman:
	lip REGL
	cpim $42
	jrcp next4
	lip REGK
	cpim $9c
	jrcp next8
	jp next4
next8:
	call bpac_disp
	lip REGK
	adim 2
	tsim $02
	jrzp next7
	adim 1
next7:

next4:
	call vvtrans

	cal INKEY
	jrncm mainloop2
	rtn

wait:
	push
	lia $ff
wait0:
	nopw
	deca
	cpia 0
	jrnzm wait0
	pop
	rtn


pac_disp:
	lip REGYH
	lia (MON_S-1)>>8
	exam
	decp
	lia (MON_S-1)&$ff
	exam
	lip REGK
	ldm
	lib 0		# REGK -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	lip REGXH
	lia (pacman00-1)>>8
	exam
	decp
	lia (pacman00-1)&$ff
	exam

	lip REGM
	ldm
	cpia $60
	jrnzp next2
	lia $20
next2:
	lib 0
	lip REGXL
	adb		# REGX <- REGX + REGM
	
	lii 16
	call trans0
	clra
	iys
	iys
# pacman 上段の表示はここまで

	lip REGYH
	lia (MON_S+$c0-1)>>8
	exam
	decp
	lia (MON_S+$c0-1)&$ff
	exam
	lip REGK
	ldm
	lib 0		# REGK -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	lii 16
	call trans0
	clra
	iys
	iys

# pacman 下段の表示はここまで

	lip REGM
	adim $20
	anim $60	# REGM の更新

	rtn

bpac_disp:
	lip REGYH
	lia (MON_P-1)>>8
	exam
	decp
	lia (MON_P-1)&$ff
	exam
	lip REGK
	ldm
	lib 0		# REGK -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	lip REGXH
	lia (pacman10-1)>>8
	exam
	decp
	lia (pacman10-1)&$ff
	exam

	lip REGM
	ldm
	cpia $c0
	jrnzp next5
	lia $40
next5:
	lib 0
	rc
	sl
	jrncp next6
	lib 1
next6:
	lip REGXL
	adb		# REGX <- REGX + REGM

	clra
	iys
	iys
	iys
	lii 32
	call trans0
# bpacman 上段の表示はここまで

	lip REGYH
	lia (MON_P+$c0-1)>>8
	exam
	decp
	lia (MON_P+$c0-1)&$ff
	exam
	lip REGK
	ldm
	lib 0		# REGK -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	iys
	lii 32
	call trans0

	lip REGYH
	lia (MON_P+$c0+$c0-1)>>8
	exam
	decp
	lia (MON_P+$c0+$c0-1)&$ff
	exam
	lip REGK
	ldm
	lib 0		# REGK -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	iys
	lii 32
	call trans0

	lip REGYH
	lia (MON_P+$c0+$c0+$c0-1)>>8
	exam
	decp
	lia (MON_P+$c0+$c0+$c0-1)&$ff
	exam
	lip REGK
	ldm
	lib 0		# REGK -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	iys
	lii 32
	call trans0

# bpacman 下段の表示はここまで
	lip REGM
	adim $40
	anim $c0	# REGM の更新

	rtn

mon_disp:
	lip REGYH
	lia (MON_S-1)>>8
	exam
	decp
	lia (MON_S-1)&$ff
	exam
	lip REGL
	ldm
	lib 0		# REGL -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	lip REGXH
	lia (monster00-1)>>8
	exam
	decp
	lia (monster00-1)&$ff
	exam

	lip REGN
	ldm
	lib 0
	lip REGXL
	adb		# REGX <- REGX + REGN
	
	lii 16
	call trans0
	clra
	iys
	iys
	iys
# Monster 上段の表示はここまで

	lip REGYH
	lia (MON_S+$c0-1)>>8
	exam
	decp
	lia (MON_S+$c0-1)&$ff
	exam
	lip REGL
	ldm
	lib 0		# REGL -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	lii 16
	call trans0
	clra
	iys
	iys
	iys

# Monster 下段の表示はここまで

	lip REGN
	adim $20
	anim $20	# REGN の更新

	rtn
	
mon_disp2:
	lip REGYH
	lia (MON_S-1)>>8
	exam
	decp
	lia (MON_S-1)&$ff
	exam
	lip REGL
	ldm
	lib 0		# REGL -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	lip REGXH
	lia (monster10-1)>>8
	exam
	decp
	lia (monster10-1)&$ff
	exam

	lip REGN
	ldm
	lib 0
	lip REGXL
	adb		# REGX <- REGX + REGN
	
	clra
	iys
	iys
	lii 16
	call trans0
# Monster 上段の表示はここまで

	lip REGYH
	lia (MON_S+$c0-1)>>8
	exam
	decp
	lia (MON_S+$c0-1)&$ff
	exam
	lip REGL
	ldm
	lib 0		# REGL -> BA
	lip REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	lii 16
	call trans0

# Monster 下段の表示はここまで

	lip REGN
	adim $20
	anim $20	# REGN の更新

	rtn
vvtrans:
# VRAM00
	lip REGXL
	lia (VV_S0+6*5-1)&$ff
	exam
	lip REGXH
	lia (VV_S0+6*5-1)>>8
	exam
	lip REGYL
	lia (VRAM00+6*2-1)&$ff
	exam
	lip REGYH
	lia (VRAM00+6*2-1)>>8
	exam
	lii 18
	call trans0
# VRAM10
	lip REGXL
	lia (VV_S1+6*5-1)&$ff
	exam
	lip REGXH
	lia (VV_S1+6*5-1)>>8
	exam
	lip REGYL
	lia (VRAM10+6*2-1)&$ff
	exam
	lip REGYH
	lia (VRAM10+6*2-1)>>8
	exam
	lii 18
	call trans0
# VRAM20
	lip REGXL
	lia (VV_S2+6*5-1)&$ff
	exam
	lip REGXH
	lia (VV_S2+6*5-1)>>8
	exam
	lip REGYL
	lia (VRAM20+6*2-1)&$ff
	exam
	lip REGYH
	lia (VRAM20+6*2-1)>>8
	exam
	lii 18
	call trans0
# VRAM30
	lip REGXL
	lia (VV_S3+6*5-1)&$ff
	exam
	lip REGXH
	lia (VV_S3+6*5-1)>>8
	exam
	lip REGYL
	lia (VRAM30+6*2-1)&$ff
	exam
	lip REGYH
	lia (VRAM30+6*2-1)>>8
	exam
	lii 18
	call trans0

# VRAM01
	lip REGXL
	lia (VV_S0+6*(3+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S0+6*(3+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM01-1)&$ff
	exam
	lip REGYH
	lia (VRAM01-1)>>8
	exam
	lii 30
	call trans0
# VRAM11
	lip REGXL
	lia (VV_S1+6*(3+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S1+6*(3+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM11-1)&$ff
	exam
	lip REGYH
	lia (VRAM11-1)>>8
	exam
	lii 30
	call trans0
# VRAM21
	lip REGXL
	lia (VV_S2+6*(3+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S2+6*(3+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM21-1)&$ff
	exam
	lip REGYH
	lia (VRAM21-1)>>8
	exam
	lii 30
	call trans0
# VRAM31
	lip REGXL
	lia (VV_S3+6*(3+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S3+6*(3+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM31-1)&$ff
	exam
	lip REGYH
	lia (VRAM31-1)>>8
	exam
	lii 30
	call trans0

# VRAM02
	lip REGXL
	lia (VV_S0+6*(3+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S0+6*(3+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM02-1)&$ff
	exam
	lip REGYH
	lia (VRAM02-1)>>8
	exam
	lii 30
	call trans0
# VRAM12
	lip REGXL
	lia (VV_S1+6*(3+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S1+6*(3+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM12-1)&$ff
	exam
	lip REGYH
	lia (VRAM12-1)>>8
	exam
	lii 30
	call trans0
# VRAM22
	lip REGXL
	lia (VV_S2+6*(3+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S2+6*(3+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM22-1)&$ff
	exam
	lip REGYH
	lia (VRAM22-1)>>8
	exam
	lii 30
	call trans0
# VRAM32
	lip REGXL
	lia (VV_S3+6*(3+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S3+6*(3+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM32-1)&$ff
	exam
	lip REGYH
	lia (VRAM32-1)>>8
	exam
	lii 30
	call trans0

# VRAM03
	lip REGXL
	lia (VV_S0+6*(3+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S0+6*(3+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM03-1)&$ff
	exam
	lip REGYH
	lia (VRAM03-1)>>8
	exam
	lii 30
	call trans0
# VRAM13
	lip REGXL
	lia (VV_S1+6*(3+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S1+6*(3+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM13-1)&$ff
	exam
	lip REGYH
	lia (VRAM13-1)>>8
	exam
	lii 30
	call trans0
# VRAM23
	lip REGXL
	lia (VV_S2+6*(3+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S2+6*(3+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM23-1)&$ff
	exam
	lip REGYH
	lia (VRAM23-1)>>8
	exam
	lii 30
	call trans0
# VRAM33
	lip REGXL
	lia (VV_S3+6*(3+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S3+6*(3+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM33-1)&$ff
	exam
	lip REGYH
	lia (VRAM33-1)>>8
	exam
	lii 30
	call trans0

# VRAM04
	lip REGXL
	lia (VV_S0+6*(3+5+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S0+6*(3+5+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM04-1)&$ff
	exam
	lip REGYH
	lia (VRAM04-1)>>8
	exam
	lii 18
	call trans0
# VRAM14
	lip REGXL
	lia (VV_S1+6*(3+5+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S1+6*(3+5+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM14-1)&$ff
	exam
	lip REGYH
	lia (VRAM14-1)>>8
	exam
	lii 18
	call trans0
# VRAM24
	lip REGXL
	lia (VV_S2+6*(3+5+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S2+6*(3+5+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM24-1)&$ff
	exam
	lip REGYH
	lia (VRAM24-1)>>8
	exam
	lii 18
	call trans0
# VRAM34
	lip REGXL
	lia (VV_S3+6*(3+5+5+5+5)-1)&$ff
	exam
	lip REGXH
	lia (VV_S3+6*(3+5+5+5+5)-1)>>8
	exam
	lip REGYL
	lia (VRAM34-1)&$ff
	exam
	lip REGYH
	lia (VRAM34-1)>>8
	exam
	lii 18
	call trans0

	rtn

trans0:
	ixl
	iys
	deci
	jrnzm trans0
	rtn
# VVRAM 転送処理はここまで




pacman00:
	db	$f0,$fc,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$fe,$fc,$f0
	db	$0f,$3f,$7f,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$7f,$7f,$3f,$0f
pacman01:
	db	$10,$1c,$1e,$3e,$3f,$3f,$3f,$7f,$7f,$7f,$ff,$ff,$fe,$fe,$fc,$f0
	db	$08,$38,$78,$7c,$fc,$fc,$fc,$fe,$fe,$fe,$ff,$ff,$7f,$7f,$3f,$0f
pacman02:
	db	$00,$00,$00,$02,$03,$07,$07,$1f,$1f,$7f,$ff,$ff,$fe,$fe,$fc,$f0
	db	$00,$00,$00,$40,$c0,$e0,$e0,$f8,$f8,$fe,$ff,$ff,$7f,$7f,$3f,$0f

monster00:
	db	$f0,$cc,$e6,$e6,$c7,$07,$0f,$ff,$cf,$e7,$e7,$c7,$06,$0e,$fc,$f0
	db	$7f,$fe,$fd,$7d,$3c,$3c,$7e,$ff,$fe,$7d,$3d,$3c,$7c,$fe,$ff,$7f
monster01:
	db	$f0,$cc,$e6,$e6,$c7,$07,$0f,$ff,$cf,$e7,$e7,$c7,$06,$0e,$fc,$f0
	db	$7f,$3e,$3d,$7d,$fc,$fc,$7e,$3f,$3e,$7d,$fd,$fc,$7c,$3e,$3f,$7f
monster10:
	db	$f0,$fc,$fe,$fe,$9f,$9f,$ff,$ff,$ff,$ff,$9f,$9f,$fe,$fe,$fc,$f0
	db	$7f,$f7,$f7,$7b,$3b,$37,$77,$fb,$fb,$77,$37,$3b,$7b,$f7,$f7,$7f
monster11:
	db	$f0,$fc,$fe,$fe,$9f,$9f,$ff,$ff,$ff,$ff,$9f,$9f,$fe,$fe,$fc,$f0
	db	$7f,$37,$37,$7b,$fb,$f7,$77,$3b,$3b,$77,$f7,$fb,$7b,$37,$37,$7f

pacman10:
	db	$00,$00,$00,$c0,$e0,$f0,$f8,$f8,$fc,$fe,$fe,$fe,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fc,$f8,$f8,$f0,$e0,$c0,$00,$00,$00
	db	$f0,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$f0
	db	$0f,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$7f,$0f
	db	$00,$00,$00,$03,$07,$0f,$1f,$1f,$3f,$7f,$7f,$7f,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$7f,$7f,$7f,$3f,$1f,$1f,$0f,$07,$03,$00,$00,$00
pacman11:
	db	$00,$00,$00,$c0,$e0,$f0,$f8,$f8,$fc,$fe,$fe,$fe,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fc,$f8,$f8,$f0,$e0,$c0,$00,$00,$00
	db	$f0,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$7f,$7f,$3f,$3f,$3f,$1f,$1f,$1f,$0f,$0f,$07,$07,$03,$03,$00,$00
	db	$0f,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$fe,$fe,$fc,$fc,$fc,$f8,$f8,$f8,$f0,$f0,$e0,$e0,$c0,$c0,$00,$00
	db	$00,$00,$00,$03,$07,$0f,$1f,$1f,$3f,$7f,$7f,$7f,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$7f,$7f,$7f,$3f,$1f,$1f,$0f,$07,$03,$00,$00,$00
pacman12:
	db	$00,$00,$00,$c0,$e0,$f0,$f8,$f8,$fc,$fe,$fe,$fe,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$7e,$1e,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db	$f0,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$7f,$1f,$07,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db	$0f,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$fe,$f8,$e0,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$03,$07,$0f,$1f,$1f,$3f,$7f,$7f,$7f,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$7e,$78,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00
#pacman10:
#	db	$00,$00,$00,$c0,$e0,$f0,$f8,$f8,$fc,$fe,$fe,$fe,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fc,$f8,$f8,$f0,$e0,$c0,$00,$00,$00
#	db	$f0,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$f0
#	db	$0f,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$7f,$0f
#	db	$00,$00,$00,$03,$07,$0f,$1f,$1f,$3f,$7f,$7f,$7f,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$7f,$7f,$7f,$3f,$1f,$1f,$0f,$07,$03,$00,$00,$00
#pacman11:
#	db	$00,$00,$00,$c0,$e0,$f0,$f8,$f8,$fc,$fe,$fe,$fe,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fc,$f8,$f8,$f0,$e0,$c0,$00,$00,$00
#	db	$f0,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
#	db	$7f,$7f,$3f,$3f,$3f,$1f,$1f,$1f,$0f,$0f,$07,$07,$03,$03,$00,$00
#	db	$0f,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
#	db	$fe,$fe,$fc,$fc,$fc,$f8,$f8,$f8,$f0,$f0,$e0,$e0,$c0,$c0,$00,$00
#	db	$00,$00,$00,$03,$07,$0f,$1f,$1f,$3f,$7f,$7f,$7f,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$7f,$7f,$7f,$3f,$1f,$1f,$0f,$07,$03,$00,$00,$00
#pacman12:
#	db	$00,$00,$00,$c0,$e0,$f0,$f8,$f8,$fc,$fe,$fe,$fe,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$7e,$1e,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00
#	db	$f0,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
#	db	$7f,$1f,$07,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
#	db	$0f,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
#	db	$fe,$f8,$e0,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
#	db	$00,$00,$00,$03,$07,$0f,$1f,$1f,$3f,$7f,$7f,$7f,$ff,$ff,$ff,$ff
#	db	$ff,$ff,$ff,$ff,$7e,$78,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00
