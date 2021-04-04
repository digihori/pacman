# internal RAM registers
REGI	equ	$0
REGJ	equ	$1
REGA	equ	$2
REGB	equ	$3
REGXL	equ	$4
REGXH	equ	$5
REGYL	equ	$6
REGYH	equ	$7
REGK	equ	$8
REGL	equ	$9
REGM	equ	$a
REGN	equ	$b
REGIA	equ	$5c
REGIB	equ	$5d
REGFO	equ	$5e
REGCTL	equ	$5f

REG_U1	equ	$10
REG_U2	equ	$11
REG_U3	equ	$12
REG_U4	equ	$13
REG_UU	equ	$20


DSPON	equ	$04b1
INKEY	equ	$0436
CLS_V1	equ	$d90c
CLS_V2	equ	$dba8

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
	lidp $fff0	# ROM Verチェック
	ldd
	cpia $03
	jrzp V2
	call CLS_V1
	jp L1
V2:
	call CLS_V2
L1:
	cal DSPON

	lip REG_U1
	lia $9c
	lii 2-1
	film		# REG_U1,REG_U2 初期値
	lip REG_U3
	clra
	lii 2-1
	film		# REG_U3,REG_U4 0 初期値

	lidp VV_S0	# VVRAMクリア
	clra
	lii $ff
	fild
	lidp VV_S0+$100
	fild
	lidp VV_S0+$200
	fild

init:
	call INKEY	# キーが何も押されていない
	jrcm init

mainloop1:
pacman:
	call pac_disp
	lip REG_U1
	cpim 0
	jrzp monster
	sbim 2
monster:
	call mon_disp
	lip REG_U1
	cpim $6a
	jrncp L2
	lip REG_U2
	cpim 3
	jrcp second
	sbim 2
	tsim $02
	jrzp L2
	sbim 1
L2:
	call vvtrans
loop1:
	call wait
	cal INKEY
	jrncm mainloop1

second:
	clra
	lip REG_U1
	lii 4-1
	film		# REG_U1/REG_U2/REG_U3/REG_U4 0クリア

mainloop2:

monster2:
	call mon_disp2
	lip REG_U2
	cpim $9c
	jrzp bpacman
	adim 2

bpacman:
	lip REG_U2
	cpim $42
	jrcp L4
	call bpac_disp
	lip REG_U1
	cpim $9c
	jrncp L4
	adim 2
	tsim $02
	jrzp L4
	adim 1

L4:
	call vvtrans

	call wait
	cal INKEY
	jrncm mainloop2
	lij 1
	rtn

wait:
	push
	lia $ff
wait0:
	nopt
	nopt
	deca
	cpia 0
	jrnzm wait0
	pop
	rtn

pac_disp:
	lp REGYL
	lia (MON_S-1)&$ff
	exam
	incp
	lia (MON_S-1)>>8
	exam
	lip REG_U1
	ldm
	lib 0		# REG_U1 -> BA
	lp REGYL
	adb		# REGYL/YH + BA


	lp REGXL
	lia (pacman00-1)&$ff
	exam
	incp
	lia (pacman00-1)>>8
	exam

	lip REG_U3
	ldm
	cpia $60
	jrnzp L5
	lia $20
L5:
	lib 0
	lp REGXL
	adb		# REGX <- REGX + REG_U3
	
	lii 16
	call trans0
	clra
	iys
	iys
# pacman 上段の表示はここまで

	lp REGYL
	lia (MON_S+$c0-1)&$ff
	exam
	incp
	lia (MON_S+$c0-1)>>8
	exam
	lip REG_U1
	ldm
	lib 0		# REG_U1 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	lii 16
	call trans0
	clra
	iys
	iys

# pacman 下段の表示はここまで

	lip REG_U3
	adim $20
	anim $60	# REG_U3 の更新

	rtn

bpac_disp:
	lp REGYL
	lia (MON_P-1)&$ff
	exam
	incp
	lia (MON_P-1)>>8
	exam
	lip REG_U1
	ldm
	lib 0		# REG_U1 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	lp REGXL
	lia (pacman10-1)&$ff
	exam
	incp
	lia (pacman10-1)>>8
	exam

	lip REG_U3
	ldm
	cpia $c0
	jrnzp L6
	lia $40
L6:
	lib 0
	rc
	sl
	jrncp L7
	lib 1
L7:
	lp REGXL
	adb		# REGX <- REGX + REG_U3

	clra
	iys
	iys
	iys
	lii 32
	call trans0
# bpacman 上段の表示はここまで

	lp REGYL
	lia (MON_P+$c0-1)&$ff
	exam
	incp
	lia (MON_P+$c0-1)>>8
	exam
	lip REG_U1
	ldm
	lib 0		# REG_U1 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	iys
	lii 32
	call trans0

	lp REGYL
	lia (MON_P+$c0+$c0-1)&$ff
	exam
	incp
	lia (MON_P+$c0+$c0-1)>>8
	exam
	lip REG_U1
	ldm
	lib 0		# REG_U1 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	iys
	lii 32
	call trans0

	lp REGYL
	lia (MON_P+$c0+$c0+$c0-1)&$ff
	exam
	incp
	lia (MON_P+$c0+$c0+$c0-1)>>8
	exam
	lip REG_U1
	ldm
	lib 0		# REG_U1 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	iys
	lii 32
	call trans0

# bpacman 下段の表示はここまで
	lip REG_U3
	adim $40
	anim $c0	# REG_U3 の更新

	rtn

mon_disp:
	lp REGYL
	lia (MON_S-1)&$ff
	exam
	incp
	lia (MON_S-1)>>8
	exam
	lip REG_U2
	ldm
	lib 0		# REG_U2 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	lp REGXL
	lia (monster00-1)&$ff
	exam
	incp
	lia (monster00-1)>>8
	exam

	lip REG_U4
	ldm
	lib 0
	lp REGXL
	adb		# REGX <- REGX + REG_U4
	
	lii 16
	call trans0
	clra
	iys
	iys
	iys
# Monster 上段の表示はここまで

	lp REGYL
	lia (MON_S+$c0-1)&$ff
	exam
	incp
	lia (MON_S+$c0-1)>>8
	exam
	lip REG_U2
	ldm
	lib 0		# REG_U2 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	lii 16
	call trans0
	clra
	iys
	iys
	iys

# Monster 下段の表示はここまで

	lip REG_U4
	adim $20
	anim $20	# REG_U4 の更新

	rtn
	
mon_disp2:
	lp REGYL
	lia (MON_S-1)&$ff
	exam
	incp
	lia (MON_S-1)>>8
	exam
	lip REG_U2
	ldm
	lib 0		# REG_U2 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	lp REGXL
	lia (monster10-1)&$ff
	exam
	incp
	lia (monster10-1)>>8
	exam

	lip REG_U4
	ldm
	lib 0
	lp REGXL
	adb		# REGX <- REGX + REG_U4
	
	clra
	iys
	iys
	lii 16
	call trans0
# Monster 上段の表示はここまで

	lp REGYL
	lia (MON_S+$c0-1)&$ff
	exam
	incp
	lia (MON_S+$c0-1)>>8
	exam
	lip REG_U2
	ldm
	lib 0		# REG_U2 -> BA
	lp REGYL
	adb		# REGYL/YH + BA

	clra
	iys
	iys
	lii 16
	call trans0

# Monster 下段の表示はここまで

	lip REG_U4
	adim $20
	anim $20	# REG_U4 の更新

	rtn


vvtrans:
	lii 30-1
	lij 18-1
# VRAM00
	lidp VV_S0+6*5
	lip REG_UU
	mvbd
	lip REG_UU
	lidp VRAM00+6*2
	exbd
# VRAM10
	lidp VV_S1+6*5
	lip REG_UU
	mvbd
	lip REG_UU
	lidp VRAM10+6*2
	exbd
# VRAM20
	lidp VV_S2+6*5
	lip REG_UU
	mvbd
	lip REG_UU
	lidp VRAM20+6*2
	exbd
# VRAM30
	lidp VV_S3+6*5
	lip REG_UU
	mvbd
	lip REG_UU
	lidp VRAM30+6*2
	exbd
# VRAM01
	lidp VV_S0+6*(3+5)
	lip REG_UU
	#lii 30-1
	mvwd
	lidp VRAM01
	lip REG_UU
	exwd
# VRAM11
	lidp VV_S1+6*(3+5)
	lip REG_UU
	mvwd
	lidp VRAM11
	lip REG_UU
	exwd
# VRAM21
	lidp VV_S2+6*(3+5)
	lip REG_UU
	mvwd
	lidp VRAM21
	lip REG_UU
	exwd
# VRAM31
	lidp VV_S3+6*(3+5)
	lip REG_UU
	mvwd
	lidp VRAM31
	lip REG_UU
	exwd
# VRAM02
	lidp VV_S0+6*(3+5+5)
	lip REG_UU
	mvwd
	lidp VRAM02
	lip REG_UU
	exwd
# VRAM12
	lidp VV_S1+6*(3+5+5)
	lip REG_UU
	mvwd
	lidp VRAM12
	lip REG_UU
	exwd
# VRAM22
	lidp VV_S2+6*(3+5+5)
	lip REG_UU
	mvwd
	lidp VRAM22
	lip REG_UU
	exwd
# VRAM32
	lidp VV_S3+6*(3+5+5)
	lip REG_UU
	mvwd
	lidp VRAM32
	lip REG_UU
	exwd
# VRAM03
	lidp VV_S0+6*(3+5+5+5)
	lip REG_UU
	mvwd
	lidp VRAM03
	lip REG_UU
	exwd
# VRAM13
	lidp VV_S1+6*(3+5+5+5)
	lip REG_UU
	mvwd
	lidp VRAM13
	lip REG_UU
	exwd
# VRAM23
	lidp VV_S2+6*(3+5+5+5)
	lip REG_UU
	mvwd
	lidp VRAM23
	lip REG_UU
	exwd
# VRAM33
	lidp VV_S3+6*(3+5+5+5)
	lip REG_UU
	mvwd
	lidp VRAM33
	lip REG_UU
	exwd
# VRAM04
	lidp VV_S0+6*(3+5+5+5+5)
	lip REG_UU
	mvbd
	lidp VRAM04
	lip REG_UU
	exbd
# VRAM14
	lidp VV_S1+6*(3+5+5+5+5)
	lip REG_UU
	mvbd
	lidp VRAM14
	lip REG_UU
	exbd
# VRAM24
	lidp VV_S2+6*(3+5+5+5+5)
	lip REG_UU
	mvbd
	lidp VRAM24
	lip REG_UU
	exbd
# VRAM34
	lidp VV_S3+6*(3+5+5+5+5)
	lip REG_UU
	mvbd
	lidp VRAM34
	lip REG_UU
	exbd

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
