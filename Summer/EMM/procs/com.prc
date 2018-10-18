proc com
;*** $Revision: 1.16 $
;*** $Date: 2018/09/08 22:31:08 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/com.prc,v $
;*
;* Created by: EMM Operations Account, Del Sherman
;* Creation Date: 11/29/2017
;*
;*  FUNCTION: Tests commands in COM app
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Tests NOOP, CNTRESET, COAX_POS, 
;*           RADIO_POR, WGS(1/2)POS_(ARM/EN/FIRE), TWTASERV, 
;*           TWTAHV_(ARM/EN/FIRE), TWTAHV_OFF, MISSMODE, MISSMODE_B
;*
;*           Aliased: TWTASERV_ON(P/R), TWTASERV_OFF, TWTAHV_(ARM/EN/FIRE)(P/R),
;*                    RADIO_POR(P/R), WGS1(H/L)GA_(ARM/EN/FIRE)(P/R),
;*                    WGS2LGA(1/23)_(ARM/EN/FIRE)(P/R), COAXPW_(H/L)GA(P/R),
;*                    TWTAHV_OFF(P/R)
;*
;*           Has sections for Microswitch or NO Microswitch version of test
;*
;*           Has sections for Radio and NO Radio version of test
;*
;*  INVOKES:
;*  Procedures: init.prc
;*  Utilities: N/A
;*
;*  RETURNS: N/A
;*
;*  CALLED BY: N/A
;*
;*  REVISION HISTORY: (most recent change first)
;*  MM/DD/YY WHO  WHAT
;*
;*  CONSTRAINTS, ASSUMPTIONS and NOTES: 
;*
;*  NOTICE:
;*  This document may be subject to U.S. export control laws and 
;*  regulations. It is furnished with the understanding that it will not
;*  be exported to a foreign person or released into the public domain 
;*  without a suitable export license.
;**************************************************************************
BEGIN:

;---------------------
;for regression test documentation

if (clp_2 procedure_name = "FSW_AUTO_SWITCH_LOGS")
	write "@PW <C>Using correct log switching file for FSW"
else
	new_proc init
	start init
endif

start manage_files xfer, switch

wait 00:00:10;for log switching to complete

2goto RESTART;comes out of loop and starts over

if (clp_2 status = "EXECUTING")
	write "@PW "
else
	2go;if clp 2 is waiting after 2goto RESTART, it needs 2go
endif
;---------------------

write "@PW Starting procedure $RCSfile: com.prc,v $"
write "@PW $Revision: 1.16 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $firetracker = 0.0ms
DECLARE VARIABLE $answer = n y,n
DECLARE VARIABLE $radioanswer = n y,n
DECLARE VARIABLE $rcmdsentcnt = 0.0dn
DECLARE VARIABLE $dspcmdacptcnt = 0.0dn
DECLARE VARIABLE $dspcmdrjctcnt = 0.0dn

; main body of script

;CDH noop for versions
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH NOOP
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CDHNOOP accepted as expected"
endif

ask $radioanswer "Do you want to test the radio? (y,n)"

;com noop

let $cmdacptd = com cmdacptcnt
let $cmdrjctd = com cmdrjctcnt
write "@PW "
write "@PW Expecting command accept: COM NOOP"
CMD COM NOOP
wait ((com cmdacptcnt = $cmdacptd + 1.0dn) and (com cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command COM NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command COM NOOP accepted as expected"
endif

; com cntreset

;cmdcnt = 1, errcnt = 0

write "@PW "
write "@PW Expecting command: COM CNTRESET"
CMD COM CNTRESET
wait ((com cmdacptcnt = 0.0dn) and (com cmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command COM CNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command COM CNTRESET accepted as expected"
endif

;determine which path to run, checking for microswitch behavior or not
ask $answer "Are microswitches present? (y,n)"

if $answer = y
	
	;Coax: COAX_POS
	;Aliased: COAXPW_(H/L)GA(P/R)
	
	write "@PW "
	write "@PW <G>Testing Coax"
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(LGA,PRIMARY)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack14
	CMD COM COAX_POS with position LGA, source PRI
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (LGA,PRIMARY) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (LGA,PRIMARY) accepted as expected"
	endif
	wait (com wxswpsw = LGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAX_POS (LGA,PRIMARY) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAX_POS (LGA,PRIMARY) accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(HGA,PRIMARY)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack15
	CMD COM COAX_POS with position HGA, source PRI
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (HGA,PRIMARY) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (HGA,PRIMARY) accepted as expected"
	endif
	wait (com wxswpsw = HGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAX_POS (HGA,PRIMARY) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAX_POS (HGA,PRIMARY) accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(LGA,REDUNDANT)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack14
	CMD COM COAX_POS with position LGA, source RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (LGA,REDUNDANT) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (LGA,REDUNDANT) accepted as expected"
	endif
	wait (com wxswpsw = LGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAX_POS (LGA,REDUNDANT) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAX_POS (LGA,REDUNDANT) accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(HGA,REDUNDANT)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack15
	CMD COM COAX_POS with position HGA, source RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (HGA,REDUNDANT) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (HGA,REDUNDANT) accepted as expected"
	endif
	wait (com wxswpsw = HGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAX_POS (HGA,REDUNDANT) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAX_POS (HGA,REDUNDANT) accepted as expected"
	endif
	
	;aliased COAX commands
	write "@PW "
	write "@PW Expecting command: COM COAXPW_LGAP"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack14
	CMD COM COAXPW_LGAP
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_LGAP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_LGAP accepted as expected"
	endif
	wait (com wxswpsw = LGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAXPW_LGAP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAXPW_LGAP accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAXPW_HGAP"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack15
	CMD COM COAXPW_HGAP
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_HGAP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_HGAP accepted as expected"
	endif
	wait (com wxswpsw = HGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAXPW_HGAP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAXPW_HGAP accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAXPW_LGAR"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack14
	CMD COM COAXPW_LGAR
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_LGAR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_LGAR accepted as expected"
	endif
	wait (com wxswpsw = LGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAXPW_LGAR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAXPW_LGAR accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAXPW_HGAR"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack15
	CMD COM COAXPW_HGAR
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_HGAR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_HGAR accepted as expected"
	endif
	wait (com wxswpsw = HGA) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM COAXPW_HGAR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM COAXPW_HGAR accepted as expected"
	endif
	
	
	;Radio: radio_por
	;Aliased: radio_por(p/r)
	
	write "@PW "
	write "@PW <G>Testing Radio"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_POR with source PRIMARY"
	CMD COM RADIO_POR with source PRI
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_POR with source PRIMARY not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_POR with source PRIMARY accepted as expected"
	endif
	wait (eps p1firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_POR withsource PRIMARY unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_POR with source PRIMARY accepted as expected"
	endif
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_POR with source REDUNDANT"
	CMD COM RADIO_POR with source RDNT
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_POR with source REDUNDANT not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_POR with source REDUNDANT accepted as expected"
	endif
	wait (eps p2firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_POR with source REDUNDANT unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_POR with source REDUNDANT accepted as expected"
	endif
	
	;testing aliased RADIO_POR command
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_PORP"
	CMD COM RADIO_PORP
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_PORP not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_PORP accepted as expected"
	endif
	wait (eps p1firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_PORP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_PORP accepted as expected"
	endif	
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_PORR"
	CMD COM RADIO_PORR
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_PORR not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_PORR accepted as expected"
	endif
	wait (eps p2firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_PORR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_PORR accepted as expected"
	endif

	
	WAVEGUIDES:
	;Waveguides: WGS(1/2)POS_(ARM/EN/FIRE)
	;Aliased: WGS1(H/L)GA_(ARM/EN/FIRE)(P/R), WGS2LGA(1/23)_(ARM/EN/FIRE)(P/R)
	
	write "@PW "
	write "@PW <G>Testing Wave Guides"
	
	write "@PW Wave Guides are protected commands. Proceed?"
	write "@PW Type 'GO' to proceed"
	wait; GO to continue
	
	if (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT);twta is powered off
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p1firetrack02
		CMD COM WGS1POS_ARM with POSITION HGA, SOURCE PRI;turn on hga
		wait 00:00:01
		CMD COM WGS1POS_EN with POSITION HGA, SOURCE PRI
		wait 00:00:01
		CMD COM WGS1POS_FIRE with POSITION HGA, SOURCE PRI
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter for switch waveguide to hga (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter for switch waveguide to hga (primary source) successful"
		endif
		wait (eps p1firetrack02 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to hga (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to hga (primary source) accepted as expected"
		endif
		wait (com wgsw1psw = HGA) or for $tm_wait;verify tlm=hga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to hga (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to hga (primary source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p2firetrack03
		CMD COM WGS1POS_ARM with POSITION LGA, SOURCE RDNT;turn on lga
		wait 00:00:01
		CMD COM WGS1POS_EN with POSITION LGA, SOURCE RDNT
		wait 00:00:01
		CMD COM WGS1POS_FIRE with POSITION LGA, SOURCE RDNT
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter for command switch waveguide to lga (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter for command switch waveguide to lga (redundant source) successful"
		endif
		wait (eps p2firetrack03 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga (redundant source) accepted as expected"
		endif
		wait (com wgsw1psw = LGA) or for $tm_wait;verify tlm=lga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga (redundant source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p1firetrack08
		CMD COM WGS2POS_ARM with POSITION LGA1, SOURCE PRI;turn on lga1
		wait 00:00:01
		CMD COM WGS2POS_EN with POSITION LGA1, SOURCE PRI
		wait 00:00:01
		CMD COM WGS2POS_FIRE with POSITION LGA1, SOURCE PRI
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p1firetrack08 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga1 (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga1 (primary source) accepted as expected"
		endif
		wait (com wgsw2psw = LGA1) or for $tm_wait;verify tlm=lga1
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga1 (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga1 (primary source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p2firetrack09
		CMD COM WGS2POS_ARM with POSITION LGA2_3, SOURCE RDNT;turn on lga2_3
		wait 00:00:01
		CMD COM WGS2POS_EN with POSITION LGA2_3, SOURCE RDNT
		wait 00:00:01
		CMD COM WGS2POS_FIRE with POSITION LGA2_3, SOURCE RDNT
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p2firetrack09 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga23 (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga23 (redundant source) accepted as expected"
		endif
		wait (com wgsw2psw = LGA23) or for $tm_wait;verify tlm=lga2_3
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga2_3 (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga2_3 (redundant source) accepted as expected"
		endif
		
		;Aliased commands
		
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p1firetrack02
		CMD COM WGS1HGA_ARMP;turn on hgapri
		wait 00:00:01
		CMD COM WGS1HGA_ENP
		wait 00:00:01
		CMD COM WGS1HGA_FIREP
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p1firetrack02 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to hga (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to hga (primary source) accepted as expected"
		endif
		wait (com wgsw1psw = HGA) or for $tm_wait;verify tlm=hga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to hga (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to hga (primary source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p1firetrack08
		CMD COM WGS2LGA1_ARMP;turn on lga1pri
		wait 00:00:01
		CMD COM WGS2LGA1_ENP
		wait 00:00:01
		CMD COM WGS2LGA1_FIREP
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p1firetrack08 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga1 (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga1 (primary source) accepted as expected"
		endif
		wait (com wgsw1psw = HGA) or for $tm_wait;verify tlm=hga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga1 (primary source) should not have affected switch 1"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga1 (primary source) did not affect switch 1 as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p1firetrack09
		CMD COM WGS2LGA23_ARMP;turn on lga23pri
		wait 00:00:01
		CMD COM WGS2LGA23_ENP
		wait 00:00:01
		CMD COM WGS2LGA23_FIREP
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p1firetrack09 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga23 (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga23 (primary source) accepted as expected"
		endif
		wait (com wgsw1psw = HGA) or for $tm_wait;verify tlm=hga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga23 (primary source) should not have affected switch 1"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga23 (primary source) did not affect switch 1 as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p1firetrack03
		CMD COM WGS1LGA_ARMP;turn on lgapri
		wait 00:00:01
		CMD COM WGS1LGA_ENP
		wait 00:00:01
		CMD COM WGS1LGA_FIREP
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p1firetrack03 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga (primary source) accepted as expected"
		endif
		wait (com wgsw1psw = LGA) or for $tm_wait;verify tlm=lga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga (primary source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga (primary source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p2firetrack08
		CMD COM WGS2LGA1_ARMR;turn on lga1red
		wait 00:00:01
		CMD COM WGS2LGA1_ENR
		wait 00:00:01
		CMD COM WGS2LGA1_FIRER
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p2firetrack08 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga1 (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga1 (redundant source) accepted as expected"
		endif
		wait (com wgsw2psw = LGA1) or for $tm_wait;verify tlm=lga1
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga1 (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga1 (redundant source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p2firetrack09
		CMD COM WGS2LGA23_ARMR;turn on lga23red
		wait 00:00:01
		CMD COM WGS2LGA23_ENR
		wait 00:00:01
		CMD COM WGS2LGA23_FIRER
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p2firetrack09 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga23 (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga23 (redundant source) accepted as expected"
		endif
		wait (com wgsw2psw = LGA23) or for $tm_wait;verify tlm=lga2_3
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga23 (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga23 (redundant source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p2firetrack02
		CMD COM WGS1HGA_ARMR;turn on hgared
		wait 00:00:01
		CMD COM WGS1HGA_ENR
		wait 00:00:01
		CMD COM WGS1HGA_FIRER
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p2firetrack02 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to hga (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to hga (redundant source) accepted as expected"
		endif
		wait (com wgsw1psw = HGA) or for $tm_wait;verify tlm=hga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to hga (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to hga (redundant source) accepted as expected"
		endif
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p2firetrack03
		CMD COM WGS1LGA_ARMR;turn on lgared
		wait 00:00:01
		CMD COM WGS1LGA_ENR
		wait 00:00:01
		CMD COM WGS1LGA_FIRER
		wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter successful"
		endif
		wait (eps p2firetrack03 = $firetracker + 750.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command switch waveguide to lga (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command switch waveguide to lga (redundant source) accepted as expected"
		endif
		wait (com wgsw1psw = LGA) or for $tm_wait;verify tlm=lga
		if $$error = time_out
			write "@PW <R>Failed: Command switch waveguide to lga (redundant source) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command switch waveguide to lga (redundant source) accepted as expected"
		endif
	else
		write "@PW "
		write "@PW Must power off TWTA before commanding waveguides"
		let $cmdacptd = com cmdacptcnt
		let $firetracker = eps p1firetrack17
		CMD COM TWTAHV_OFF with SOURCE PRI
		wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Command counter for command TWTAHV off (primary) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command counter for command TWTAHV off (primary) successful"
		endif
		wait (eps p1firetrack17 = $firetracker + 70.0ms) or for $tm_wait
		if $$error = time_out
			write "@PW <R>Failed: Firetracker for command TWTAHV off (primary) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Firetracker for command TWTAHV off (primary) accepted as expected"
		endif
		wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
		if $$error = time_out
			write "@PW <R>Failed: Command TWTAHV off (primary) unsuccessful"
			write "@PW Document the failure, then type 'GO' to continue"
			let $test_err = $test_err + 1
			wait;wait for documentation, then type 'GO'
		else
			write "@PW "
			write "@PW <G>Command TWTAHV off (primary) accepted as expected"
		endif
		goto WAVEGUIDES
	endif
	
	
	;TWTA: TWTASERV,  TWTAHV_(ARM/EN/FIRE), TWTAHV_OFF
	;Aliased: TWTASERV_(ON/OFF)(P/R), TWTAHV_(ARM/EN/FIRE)(P/R),
	
	write "@PW "
	write "@PW <G>Testing TWTA"
	
	;make sure TWTA Service Power is off
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE OFF, MASK 255
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE OFF, MASK 255) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV (STATE OFF, MASK 255) accepted as expected"
	endif
	
	write "@PW TWTAHV_(ARM/EN/FIRE) is a protected command. Proceed?"
	write "@PW Type 'GO' to proceed"
	wait; GO to continue
	
	;make sure TWTA can't turn on when TWTA Service Power is off
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack16
	CMD COM TWTAHV_ARM with SOURCE PRI
	wait 00:00:01
	CMD COM TWTAHV_EN with SOURCE PRI
	wait 00:00:01
	CMD COM TWTAHV_FIRE with SOURCE PRI
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (primary) accepted as expected"
	endif
	wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV on with TWTASERV off unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV on with TWTASERV off accepted as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack17
	CMD COM TWTAHV_OFF with SOURCE PRI
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (primary) accepted as expected"
	endif
	wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV off with TWTASERV off unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV off with TWTASERV off accepted as expected"
	endif
	
	;turn twta serv on
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE ON, MASK 248
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = ON) and (eps twta_r1c = ON) and (eps twta_r2c = ON) and (eps twta_r3c = ON) and (eps twta_r4c = ON)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE ON, MASK 248) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV (STATE ON, MASK 248) accepted as expected"
	endif
	wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
	if $$error = time_out
		write "@PW <R>Failed: TWTA was on when it should not have been"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>TWTA was off as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack16
	CMD COM TWTAHV_ARM with source RDNT
	wait 00:00:01
	CMD COM TWTAHV_EN with source RDNT
	wait 00:00:01
	CMD COM TWTAHV_FIRE with source RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (redundant) accepted as expected"
	endif
	wait (com twtapsw = TWTAON_NOAREVT) or (com twtapsw = TWTAON_AREVENT) or for $tm_wait;twta power = on?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV ON REDUNDANT unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV ON REDUNDANT accepted as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack17
	CMD COM TWTAHV_OFF with SOURCE RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (redundant) accepted as expected"
	endif
	wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV OFF REDUNDANT unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV OFF REDUNDANT accepted as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE OFF, MASK 248
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE OFF, MASK 248) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV (STATE OFF, MASK 248) accepted as expected"
	endif
	
	;Aliased
	
	;same commands with different service power bits applied and using aliasing on twtahv
	;turn twta serv on
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE ON, MASK 15
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = ON) and (eps twta_p2c = ON) and (eps twta_p3c = ON) and (eps twta_p4c = ON) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE ON, MASK 15) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV ON with mask 15 accepted as expected"
	endif
	wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
	if $$error = time_out
		write "@PW <R>Failed: TWTA was on when it should not have been"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>TWTA was off as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack16
	CMD COM TWTAHV_ARMP
	wait 00:00:01
	CMD COM TWTAHV_ENP
	wait 00:00:01
	CMD COM TWTAHV_FIREP
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (primary) accepted as expected"
	endif
	wait (com twtapsw = TWTAON_NOAREVT) or (com twtapsw = TWTAON_AREVENT) or for $tm_wait;twta power = on?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV ON PRIMARY unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV ON PRIMARY accepted as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV_OFF;leave TWTAHV on but TWTASERV off
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV_OFF unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV_OFF accepted as expected"
	endif
	
	;same commands with different service power bits applied and using aliasing on twtahv
	;turn twta serv on
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE ON, MASK 240
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = ON) and (eps twta_r2c = ON) and (eps twta_r3c = ON) and (eps twta_r4c = ON)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE ON, MASK 240) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV ON with mask 240 accepted as expected"
	endif
	wait (com twtapsw = TWTAON_NOAREVT) or (com twtapsw = TWTAON_AREVENT) or for $tm_wait;twta power = on?
	if $$error = time_out
		write "@PW <R>Failed: TWTA was not on when it should have been"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>TWTA was still on as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack17
	CMD COM TWTAHV_OFFR
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (redundant) accepted as expected"
	endif
	wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV OFF REDUNDANT unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV OFF REDUNDANT accepted as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack16
	CMD COM TWTAHV_ARMR
	wait 00:00:01
	CMD COM TWTAHV_ENR
	wait 00:00:01
	CMD COM TWTAHV_FIRER
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (redundant) accepted as expected"
	endif
	wait (com twtapsw = TWTAON_NOAREVT) or (com twtapsw = TWTAON_AREVENT) or for $tm_wait;twta power = on?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV ON REDUNDANT unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV ON REDUNDANT accepted as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack17
	CMD COM TWTAHV_OFFP
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (primary) accepted as expected"
	endif
	wait (com twtapsw = TWTAOFF_NOAREVT) or (com twtapsw = TWTAOFF_AREVENT) or for $tm_wait;twta power = off?
	if $$error = time_out
		write "@PW <R>Failed: Command TWTAHV OFF PRIMARY unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTAHV OFF PRIMARY accepted as expected"
	endif
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV_OFF
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV_OFF) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV_OFF accepted as expected"
	endif
	
else ;no microswitches
	
	
	;Coax: COAX_POS
	;Aliased: COAXPW_(H/L)GA(P/R)
	
	write "@PW "
	write "@PW <G>Testing Coax"
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(LGA,PRIMARY)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack14
	CMD COM COAX_POS with position LGA, source PRI
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (LGA,PRIMARY) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (LGA,PRIMARY) accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(HGA,PRIMARY)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack15
	CMD COM COAX_POS with position HGA, source PRI
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (HGA,PRIMARY) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (HGA,PRIMARY) accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(LGA,REDUNDANT)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack14
	CMD COM COAX_POS with position LGA, source RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (LGA,REDUNDANT) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (LGA,REDUNDANT) accepted as expected"
	endif
	
	write "@PW "
	write "@PW Expecting command: COM COAX_POS(HGA,REDUNDANT)"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack15
	CMD COM COAX_POS with position HGA, source RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAX_POS (HGA,REDUNDANT) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAX_POS (HGA,REDUNDANT) accepted as expected"
	endif
	
	;aliased COAX commands
	write "@PW "
	write "@PW Expecting command: COM COAXPW_LGAP"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack14
	CMD COM COAXPW_LGAP
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_LGAP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_LGAP accepted as expected"
	endif
	
	
	write "@PW "
	write "@PW Expecting command: COM COAXPW_HGAP"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack15
	CMD COM COAXPW_HGAP
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_HGAP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_HGAP accepted as expected"
	endif
	
	
	write "@PW "
	write "@PW Expecting command: COM COAXPW_LGAR"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack14
	CMD COM COAXPW_LGAR
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack14 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_LGAR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_LGAR accepted as expected"
	endif
	
	
	write "@PW "
	write "@PW Expecting command: COM COAXPW_HGAR"
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack15
	CMD COM COAXPW_HGAR
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack15 = $firetracker + 50.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM COAXPW_HGAR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM COAXPW_HGAR accepted as expected"
	endif
	
	
	
	;Radio: radio_por
	;Aliased: radio_por(p/r)
	
	write "@PW "
	write "@PW <G>Testing Radio"
	
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_POR with source PRIMARY"
	CMD COM RADIO_POR with source PRI
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_POR with source PRIMARY not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_POR with source PRIMARY accepted as expected"
	endif
	wait (eps p1firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_POR with source PRIMARY unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_POR with source PRIMARY accepted as expected"
	endif
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_POR with source REDUNDANT"
	CMD COM RADIO_POR with source RDNT
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_POR with source REDUNDANT not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_POR with source REDUNDANT accepted as expected"
	endif
	wait (eps p2firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_POR with source REDUNDANT unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_POR with source REDUNDANT accepted as expected"
	endif
	
	;testing aliased RADIO_POR command
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_PORP"
	CMD COM RADIO_PORP
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_PORP not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_PORP accepted as expected"
	endif
	wait (eps p1firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_PORP unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_PORP accepted as expected"
	endif
	
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack23
	write "@PW "
	write "@PW Expecting command: COM RADIO_PORR"
	CMD COM RADIO_PORR
	wait (com cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command COM RADIO_PORR not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command COM RADIO_PORR accepted as expected"
	endif
	wait (eps p2firetrack23 = $firetracker + 2000.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command COM RADIO_PORR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command COM RADIO_PORR accepted as expected"
	endif
		

	;Waveguides: WGS(1/2)POS_(ARM/EN/FIRE)
	;Aliased: WGS1(H/L)GA_(ARM/EN/FIRE)(P/R), WGS2LGA(1/23)_(ARM/EN/FIRE)(P/R)

	write "@PW "
	write "@PW <G>Testing Wave Guides"


	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack02
	CMD COM WGS1POS_ARM with POSITION HGA, SOURCE PRI;turn on hga
	wait 00:00:01
	CMD COM WGS1POS_EN with POSITION HGA, SOURCE PRI
	wait 00:00:01
	CMD COM WGS1POS_FIRE with POSITION HGA, SOURCE PRI
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack02 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to hga (primary source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to hga (primary source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack03
	CMD COM WGS1POS_ARM with POSITION LGA, SOURCE RDNT;turn on lga
	wait 00:00:01
	CMD COM WGS1POS_EN with POSITION LGA, SOURCE RDNT
	wait 00:00:01
	CMD COM WGS1POS_FIRE with POSITION LGA, SOURCE RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack03 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga (redundant source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga (redundant source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack08
	CMD COM WGS2POS_ARM with POSITION LGA1, SOURCE PRI;turn on lga1
	wait 00:00:01
	CMD COM WGS2POS_EN with POSITION LGA1, SOURCE PRI
	wait 00:00:01
	CMD COM WGS2POS_FIRE with POSITION LGA1, SOURCE PRI
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack08 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga1 (primary source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga1 (primary source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack09
	CMD COM WGS2POS_ARM with POSITION LGA2_3, SOURCE RDNT;turn on lga2_3
	wait 00:00:01
	CMD COM WGS2POS_EN with POSITION LGA2_3, SOURCE RDNT
	wait 00:00:01
	CMD COM WGS2POS_FIRE with POSITION LGA2_3, SOURCE RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack09 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga23 (redundant source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga23 (redundant source) accepted as expected"
	endif


	;Aliased commands

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack02
	CMD COM WGS1HGA_ARMP;turn on hgapri
	wait 00:00:01
	CMD COM WGS1HGA_ENP
	wait 00:00:01
	CMD COM WGS1HGA_FIREP
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack02 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to hga (primary source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to hga (primary source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack08
	CMD COM WGS2LGA1_ARMP;turn on lga1pri
	wait 00:00:01
	CMD COM WGS2LGA1_ENP
	wait 00:00:01
	CMD COM WGS2LGA1_FIREP
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack08 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga1 (primary source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga1 (primary source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack09
	CMD COM WGS2LGA23_ARMP;turn on lga23pri
	wait 00:00:01
	CMD COM WGS2LGA23_ENP
	wait 00:00:01
	CMD COM WGS2LGA23_FIREP
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack09 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga23 (primary source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga23 (primary source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack03
	CMD COM WGS1LGA_ARMP;turn on lgapri
	wait 00:00:01
	CMD COM WGS1LGA_ENP
	wait 00:00:01
	CMD COM WGS1LGA_FIREP
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack03 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga (primary source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga (primary source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack08
	CMD COM WGS2LGA1_ARMR;turn on lga1red
	wait 00:00:01
	CMD COM WGS2LGA1_ENR
	wait 00:00:01
	CMD COM WGS2LGA1_FIRER
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack08 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga1 (redundant source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga1 (redundant source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack09
	CMD COM WGS2LGA23_ARMR;turn on lga23red
	wait 00:00:01
	CMD COM WGS2LGA23_ENR
	wait 00:00:01
	CMD COM WGS2LGA23_FIRER
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack09 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga23 (redundant source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga23 (redundant source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack02
	CMD COM WGS1HGA_ARMR;turn on hgared
	wait 00:00:01
	CMD COM WGS1HGA_ENR
	wait 00:00:01
	CMD COM WGS1HGA_FIRER
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack02 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to hga (redundant source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to hga (redundant source) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack03
	CMD COM WGS1LGA_ARMR;turn on lgared
	wait 00:00:01
	CMD COM WGS1LGA_ENR
	wait 00:00:01
	CMD COM WGS1LGA_FIRER
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack03 = $firetracker + 750.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command switch waveguide to lga (redundant source) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command switch waveguide to lga (redundant source) accepted as expected"
	endif




	;TWTA: TWTASERV,  TWTAHV_(ARM/EN/FIRE), TWTAHV_OFF
	;Aliased: TWTASERV_(ON/OFF)(P/R), TWTAHV_(ARM/EN/FIRE)(P/R),

	write "@PW "
	write "@PW <G>Testing TWTA"


	;make sure TWTA Service Power is off
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE OFF, MASK 255
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE OFF, MASK 255) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV (STATE OFF, MASK 255) accepted as expected"
	endif


	;make sure TWTA can't turn on when TWTA Service Power is off
	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack16
	CMD COM TWTAHV_ARM with SOURCE PRI
	wait 00:00:01
	CMD COM TWTAHV_EN with SOURCE PRI
	wait 00:00:01
	CMD COM TWTAHV_FIRE with SOURCE PRI
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (primary) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack17
	CMD COM TWTAHV_OFF with SOURCE PRI
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (primary) accepted as expected"
	endif


	;turn twta serv on
	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE ON, MASK 248
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = ON) and (eps twta_r1c = ON) and (eps twta_r2c = ON) and (eps twta_r3c = ON) and (eps twta_r4c = ON)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE ON, MASK 248) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV (STATE ON, MASK 248) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack16
	CMD COM TWTAHV_ARM with source RDNT
	wait 00:00:01
	CMD COM TWTAHV_EN with source RDNT
	wait 00:00:01
	CMD COM TWTAHV_FIRE with source RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (redundant) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack17
	CMD COM TWTAHV_OFF with SOURCE RDNT
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (redundant) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE OFF, MASK 248
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE OFF, MASK 248) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV (STATE OFF, MASK 248) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV with STATE ON, MASK 15
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = ON) and (eps twta_p2c = ON) and (eps twta_p3c = ON) and (eps twta_p4c = ON) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV (STATE ON, MASK 15) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV ON with mask 15 accepted as expected"
	endif

	;Aliased

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack16
	CMD COM TWTAHV_ARMP
	wait 00:00:01
	CMD COM TWTAHV_ENP
	wait 00:00:01
	CMD COM TWTAHV_FIREP
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (primary) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV_OFF;leave TWTAHV on but TWTASERV off
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV_OFF unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV_OFF accepted as expected"
	endif


	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack17
	CMD COM TWTAHV_OFFR
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (redundant) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p2firetrack16
	CMD COM TWTAHV_ARMR
	wait 00:00:01
	CMD COM TWTAHV_ENR
	wait 00:00:01
	CMD COM TWTAHV_FIRER
	wait (COM CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2firetrack16 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV on (redundant) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV on (redundant) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	let $firetracker = eps p1firetrack17
	CMD COM TWTAHV_OFFP
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1firetrack17 = $firetracker + 70.0ms) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Firetracker for command TWTAHV off (primary) unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Firetracker for command TWTAHV off (primary) accepted as expected"
	endif

	let $cmdacptd = com cmdacptcnt
	CMD COM TWTASERV_OFF
	wait (COM CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait ((eps twta_p1c = OFF) and (eps twta_p2c = OFF) and (eps twta_p3c = OFF) and (eps twta_p4c = OFF) and (eps twta_r1c = OFF) and (eps twta_r2c = OFF) and (eps twta_r3c = OFF) and (eps twta_r4c = OFF)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command TWTASERV_OFF unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW <R>eps twta_p1c:", eps twta_p1c
		write "@PW <R>eps twta_p2c:", eps twta_p2c
		write "@PW <R>eps twta_p3c:", eps twta_p3c
		write "@PW <R>eps twta_p4c:", eps twta_p4c
		write "@PW <R>eps twta_r1c:", eps twta_r1c
		write "@PW <R>eps twta_r2c:", eps twta_r2c
		write "@PW <R>eps twta_r3c:", eps twta_r3c
		write "@PW <R>eps twta_r4c:", eps twta_r4c
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command TWTASERV_OFF accepted as expected"
	endif

endif

if $radioanswer = n
	write "@PW "
	write "@PW Testing EMM Mission Mode command sent..."

	let $rcmdsentcnt = com rcmdsentcnt
	CMD COM MISSMODE with VALUE 1
	wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command Mission Mode 1 not sent"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command Mission Mode 1 sent"
	endif

	write "@PW "
	write "@PW Testing EMM backup Mission Mode command sent..."

	let $rcmdsentcnt = com rcmdsentcnt
	CMD COM MISSMODE_B with VALUE 1
	wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command Mission Mode 1 not sent"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command Mission Mode 1 sent"
	endif

	goto FINISH
endif

;Radio testing....

write "@PW "
write "@PW Testing COM Radio..."

if $answer = y
	if com radiopsw = ON
		write "@PW "
		write "@PW Radio is ON"
	else
		write "@PW <R>Failed: Radio is OFF"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	endif
endif

if (com spwradioaddr /= X25)
	CMD COM SPWRADIOADDR with ADDR X25
	wait 00:00:01
endif

write "@PW "
write "@PW Testing EMM Mission Modes..."

if com missmode /= 1.0dn
	;missmode 1
	let $rcmdsentcnt = com rcmdsentcnt
	let $dspcmdacptcnt = com dspcmdacptcnt
	let $dspcmdrjctcnt = com dspcmdrjctcnt
	CMD COM MISSMODE with VALUE 1
	wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command Mission Mode 1 not sent"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command Mission Mode 1 sent"
	endif
	wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt) and (com missmode = 1.0dn)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counters for Mission Mode 1 unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
		write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counters for Mission Mode 1 successful"
		write "@PW "
		write "@PW <G>Passthrough to radio successful!"
	endif
else
	;missmode 33
	let $rcmdsentcnt = com rcmdsentcnt
	let $dspcmdacptcnt = com dspcmdacptcnt
	let $dspcmdrjctcnt = com dspcmdrjctcnt
	CMD COM MISSMODE with VALUE 33
	wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command Mission Mode 33 not sent"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command Mission Mode 33 sent"
	endif
	wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt) and (com missmode = 33.0dn)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counters for Mission Mode 33 unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
		write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counters for Mission Mode 33 successful"
		write "@PW "
		write "@PW <G>Passthrough to radio successful!"
	endif
endif
;if ((com xbst = DS) and (com rxrate = BPS7_8125) and (com modcrange = DS))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 1 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 1 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	wait;wait for documentation, then type 'GO'
;endif

;;missmode 3
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 3
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 3 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 3 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 3 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 3 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS7_8125) and (com modcrange = DS) and (com rxcoherency = EN))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 3 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 3 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 10
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 10
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 10 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 10 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 10 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 10 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 100000.0dn) and (com modcindex = 1.23dn) and (com modcgain = 0.305dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920.0dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 10 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 10 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 13
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 13
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 13 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 13 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 13 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 13 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS7_8125) and (com modcrange = DS) and (com rxcoherency = EN))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 13 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 13 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 20
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 20
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 20 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 20 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 20 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 20 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS7_8125) and (com modcrange = DS) and (com modcrate = 40.1dn) and (com modcindex = 0.92dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 20 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 20 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 21
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 21
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 21 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 21 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 21 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 21 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 101.6dn) and (com modcindex = 1.24dn) and (com modcgain = 0.31dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 21 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 21 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 22
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 22
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 22 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 22 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 22 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 22 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 260.4dn) and (com modcindex = 1.24dn) and (com modcgain = 0.31dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 22 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 22 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 23
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 23
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 23 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 23 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 23 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 23 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 520.8dn) and (com modcindex = 1.29dn) and (com modcgain = 0.31dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 23 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 23 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 24
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 24
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 24 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 24 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 24 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 24 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 2000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 24 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 24 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 25
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 25
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 25 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 25 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 25 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 25 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = EN) and (com modcrate = 2000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 25 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 25 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 26
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 26
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 26 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 26 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 26 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 26 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 10000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 26 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 26 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 27
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 27
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 27 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 27 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 27 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 27 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 20000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 27 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 27 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 28
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 28
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 28 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 28 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 28 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 28 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 50000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 28 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 28 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 29
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 29
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 29 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 29 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 29 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 29 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 178571.4dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 29 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 29 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 30
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 30
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 30 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 30 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 30 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 30 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 192307.7dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 30 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 30 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 31
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 31
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 31 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 31 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 31 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 31 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 208333.3dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 31 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 31 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 32
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 32
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 32 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 32 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 32 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 32 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 227272.7dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 32 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 32 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 33
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 33
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 33 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 33 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 33 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 33 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 241935.5dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 33 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 33 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 34
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 34
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 34 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 34 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 34 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 34 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 258620.7dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 34 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 34 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 35
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 35
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 35 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 35 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 35 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW FSW CIRADIOPUB: ", fsw ciradiopub
;	write "@PW FSW CIRADIORJCT: ", fsw ciradiorjct
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 35 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 267857.1dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 35 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 35 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 36
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 36
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 36 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 36 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 36 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 36 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 288461.5dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 36 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 36 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 37
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 37
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 37 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 37 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 37 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 37 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 300000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 37 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 37 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 38
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 38
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 38 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 38 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 38 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 38 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 357142.9dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 38 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 38 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 39
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 39
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 39 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 39 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 39 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 39 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 39 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 39 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode 40
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE with VALUE 40
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command Mission Mode 40 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command Mission Mode 40 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for Mission Mode 40 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for Mission Mode 40 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 600000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 40 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 40 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;
;;missmode_b 1
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 1
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 1 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 1 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 1 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 1 successful"
;endif
;if ((com xbst = DS) and (com rxrate = BPS7_8125) and (com modcrange = DS))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 1 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 1 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 3
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 3
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 3 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 3 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 3 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 3 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS7_8125) and (com modcrange = DS) and (com rxcoherency = EN))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 3 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 3 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 10
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 10
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 10 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 10 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 10 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 10 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 100000dn) and (com modcindex = 1.23dn) and (com modcgain = 0.305dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 10 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 10 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 13
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 13
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 13 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 13 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 13 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 13 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS7_8125) and (com modcrange = DS) and (com rxcoherency = EN))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 13 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 13 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 20
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 20
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 20 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 20 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 20 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 20 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS7_8125) and (com modcrange = DS) and (com modcrate = 40.1dn) and (com modcindex = 0.92dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 20 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 20 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 21
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 21
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 21 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 21 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 21 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 21 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 101.6dn) and (com modcindex = 1.24dn) and (com modcgain = 0.31dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 21 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 21 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 22
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 22
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 22 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 22 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 22 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 22 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 260.4dn) and (com modcindex = 1.24dn) and (com modcgain = 0.31dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 22 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 22 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 23
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 23
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 23 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 23 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 23 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 23 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 520.8dn) and (com modcindex = 1.29dn) and (com modcgain = 0.31dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 23 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 23 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 24
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 24
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 24 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 24 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 24 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 24 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = DS) and (com modcrate = 2000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 24 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 24 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 25
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 25
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 25 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 25 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 25 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 25 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS125) and (com modcrange = EN) and (com modcrate = 2000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 1784dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 25 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 25 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 26
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 26
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 26 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 26 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 26 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 26 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 10000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 26 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 26 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 27
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 27
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 27 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 27 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 27 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 27 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 20000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 27 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 27 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 28
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 28
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 28 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 28 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 28 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 28 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 50000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO16) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 28 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 28 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 29
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 29
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 29 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 29 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 29 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 29 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 178571.4dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 29 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 29 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 30
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 30
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 30 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 30 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 30 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 30 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 192307.7dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 30 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 30 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 31
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 31
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 31 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 31 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 31 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 31 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 208333.3dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 31 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 31 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 32
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 32
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 32 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 32 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 32 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 32 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 227272.7dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 32 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 32 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 33
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 33
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 33 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 33 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 33 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 33 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = EN) and (com modcrate = 241935.5dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 33 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 33 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 34
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 34
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 34 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 34 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 34 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 34 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 258620.7dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 34 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 34 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 35
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 35
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 35 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 35 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 35 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 35 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 267857.1dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 35 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 35 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 36
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 36
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 36 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 36 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 36 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 36 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 288461.5dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 36 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 36 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 37
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 37
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 37 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 37 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 37 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 37 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 300000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 37 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 37 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 38
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 38
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 38 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 38 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 38 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 38 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 357142.9dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 38 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 38 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 39
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 39
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 39 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 39 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 39 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 39 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 39 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 39 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;
;;missmode_b 40
;let $rcmdsentcnt = com rcmdsentcnt
;let $dspcmdacptcnt = com dspcmdacptcnt
;let $dspcmdrjctcnt = com dspcmdrjctcnt
;CMD COM MISSMODE_B with VALUE 40
;wait (com rcmdsentcnt = $rcmdsentcnt + 1.0dn) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command backup Mission Mode 40 not sent"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command backup Mission Mode 40 sent"
;endif
;wait ((com dspcmdacptcnt = $dspcmdacptcnt + 1.0dn) and (com dspcmdrjctcnt = $dspcmdrjctcnt)) or for $tm_wait
;if $$error = time_out
;	write "@PW <R>Failed: Command counters for backup Mission Mode 40 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW COM DSPCMDACPTCNT: ", com dspcmdacptcnt
;	write "@PW COM DSPCMDRJCTCNT: ", com dspcmdrjctcnt
;	wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command counters for backup Mission Mode 40 successful"
;endif
;if ((com xbst = EN) and (com rxrate = BPS2000) and (com modcrange = DS) and (com modcrate = 600000.0dn) and (com modcindex = 1.29dn) and (com modcgain = 0.61dn) and (com enccencode = TURBO12) and (com rxcoherency = EN) and (com enccflen = 8920dn))
;	write "@PW "
;	write "@PW <G>Command Mission Mode 40 successful"
;else
;	write "@PW <R>Failed: Command Mission Mode 40 unsuccessful"
;	write "@PW Document the failure, then type 'GO' to continue"
;	let $test_err = $test_err + 1
;	write "@PW <R>COM XBST:", com xbst
;	write "@PW <R>COM RXRATE:", com rxrate
;	write "@PW <R>COM MODCRANGE:", com modcrange
;	write "@PW <R>COM MODCRATE:", com modcrate
;	write "@PW <R>COM MODCINDEX:", com modcindex
;	write "@PW <R>COM MODCGAIN:", com modcgain
;	write "@PW <R>COM ENCCENCODE:", com enccencode
;	write "@PW <R>COM RXCOHERENCY: ", com rxcoherency
;	write "@PW <R>COM ENCCFLEN:", com enccflen
;	wait;wait for documentation, then type 'GO'
;endif
;


















FINISH:
	
write "@PW "
write "@PW Checking command reject counter..."
	
if com cmdrjctcnt > 0.0dn
	write "@PW <R>Failed: There were rejected commands during this test"
	write "@PW <R>Number of rejected commands:", com cmdrjctcnt
	write "@PW Document the failure, then type 'GO' to continue"
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>No commands rejected during this test"
endif

write "@PW "
write "@PW Completed testing of COM"

write "@PW <Y>Tested with microswitches?", $answer
write "@PW <Y>Tested with radio?", $radioanswer	

if $test_err = 0
	write "@PW <G>Total number of errors: ", $test_err
else
	write "@PW <R>Total number of errors: ", $test_err
endif

;---------------------
;for regression test documentation

start manage_files xfer, switch

wait 00:00:10;for log switching to complete

2goto RESTART;comes out of loop and starts over

if (clp_2 status = "EXECUTING")
	write "@PW "
else
	2go;if clp 2 is waiting after 2goto RESTART, it needs 2go
endif
;---------------------

endproc; com

