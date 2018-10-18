proc ci
;*** $Revision: 1.6 $
;*** $Date: 2018/09/08 22:07:12 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/ci.prc,v $
;*
;* Created by: EMM Operations Account, Del Sherman
;* Creation Date: 05/15/2018
;*
;*  FUNCTION: Tests commands in CI
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Tests: CINOOP, CICNTRESET, CIDEREG, CIREG, CIAUTH, CIDEAUTH, 
;*                  CIUPDATE, CILOGDS, CILOGEN. 
;*           Also tests CICHDS, CICHEN in sequences called by this script. 
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
;*  Needs to have loaded to FSW via CFDP: cich0test.bin or cich1test.bin (sequences)
;*  Sequence needs to be in /ram/seq (may need to make seq subdirectory in /ram)
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

write "@PW Starting procedure $RCSfile: ci.prc,v $"
write "@PW $Revision: 1.6 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $lng_wait = 00:01:00
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $chcmdacptd = 0.0dn
DECLARE VARIABLE $chcmdrjctd = 0.0dn
DECLARE VARIABLE $answer = spw spw,ground
DECLARE VARIABLE $bothchannels = n y,n
DECLARE VARIABLE $cdhcmdacptd = 0.0dn
DECLARE VARIABLE $cdhcmdrjctd = 0.0dn
DECLARE VARIABLE $seqcmdacptd = 0.0dn

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

ask $answer "Testing over SpW or Ground? (spw,ground)"

write "@PW "
write "@PW <C>Has sequence been loaded and moved to the right directory?"
write "@PW <C>If not, do this now manually."
wait;GO to continue

;cinoop

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
write "@PW "
write "@PW Expecting command accept: CINOOP"
CMD FSW CINOOP
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CINOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CINOOP accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

; cicntreset

write "@PW "
write "@PW Expecting command: CICNTRESET"
CMD FSW CICNTRESET
wait ((fsw cicmdacptcnt = 0.0dn) and (fsw cicmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CICNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CICNTRESET accepted as expected"
endif

if $answer = spw

	wait ((fsw ciradiopub = 0.0dn) and (fsw ciradiorjct = 0.0dn)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command CICNTRESET over spacewire unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command CICNTRESET over spacewire accepted as expected"
	endif

else; $answer = ground

	wait ((fsw cisnklpub = 0.0dn) and (fsw cisnklrjct = 0.0dn)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command CICNTRESET over ground channel unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command CICNTRESET over ground channel accepted as expected"
	endif

endif

; cireg

;dereg first so cireg always works

CMD FSW CIDEREG with MSGID x#1A50, CODE 0
wait 00:00:15

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIREG with MSGID x#1A50, CODE 0, STEP 1
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIREG unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIREG accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

let $cmdacptd = fsw emrcmdacptcnt
CMD FSW EMRNOOP
wait 00:00:15
if fsw emrcmdacptcnt = $cmdacptd
	write "@PW "
	write "@PW <G>EMRNOOP registered as two-step command as expected"
else
    write "@PW <R>Failed: EMRNOOP not registered as two-step command"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

; ciauth

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIAUTH with MSGID x#1A50, CODE 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIAUTH unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIAUTH accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIAUTH with MSGID x#1A50, CODE 0
wait ((fsw cicmdrjctcnt = $cmdrjctd + 1.0dn) and (fsw cicmdacptcnt = $cmdacptd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIAUTH sent twice"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIAUTH failed to send twice as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

let $cmdacptd = fsw emrcmdacptcnt
let $cmdrjctd = fsw emrcmdrjctcnt
CMD FSW EMRNOOP
wait ((fsw emrcmdacptcnt = $cmdacptd + 1.0dn) and (fsw emrcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: EMRNOOP not accepted as expected with two-step authorization"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>EMRNOOP accepted as expected with two-step authorization"
endif

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIAUTH with MSGID x#1A50, CODE 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIAUTH unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIAUTH accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

write "@PW Waiting for 21 seconds because CIAUTH should time out in 20 seconds"
wait 00:00:21

let $cmdacptd = fsw emrcmdacptcnt
CMD FSW EMRNOOP
wait 00:00:15
if fsw emrcmdacptcnt = $cmdacptd
	write "@PW "
	write "@PW <G>CIAUTH for EMRNOOP timed out as expected"
else
    write "@PW <R>Failed: CIAUTH for EMRNOOP did not time out"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

; cideauth

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIAUTH with MSGID x#1A50, CODE 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIAUTH unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIAUTH accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIDEAUTH with MSGID x#1A50, CODE 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIDEAUTH unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIDEAUTH accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIDEAUTH with MSGID x#1A50, CODE 0
wait ((fsw cicmdrjctcnt = $cmdrjctd + 1.0dn) and (fsw cicmdacptcnt = $cmdacptd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIDEAUTH sent twice"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIDEAUTH failed to send twice as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

let $cmdacptd = fsw emrcmdacptcnt
CMD FSW EMRNOOP
wait 00:00:15
if fsw emrcmdacptcnt = $cmdacptd
	write "@PW "
	write "@PW <G>CIDEAUTH for EMRNOOP worked as expected"
else
    write "@PW <R>Failed: CIDEAUTH for EMRNOOP did not work"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

wait 00:00:05;waiting for total at least 20 seconds since CIAUTH command

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIDEAUTH with MSGID x#1A50, CODE 0
wait ((fsw cicmdrjctcnt = $cmdrjctd + 1.0dn) and (fsw cicmdacptcnt = $cmdacptd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIDEAUTH sent when not right after CIAUTH"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIDEAUTH failed to send when not right after CIAUTH as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

; cidereg

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIDEREG with MSGID x#1A50, CODE 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIDEREG unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIDEREG accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

let $cmdacptd = fsw emrcmdacptcnt
let $cmdrjctd = fsw emrcmdrjctcnt
CMD FSW EMRNOOP
wait ((fsw emrcmdacptcnt = $cmdacptd + 1.0dn) and (fsw emrcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: EMRNOOP not deregistered as two-step command"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>EMRNOOP deregistered successfully"
endif

; cireg again

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIREG with MSGID x#1A50, CODE 0, STEP 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIREG unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIREG accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

let $cmdacptd = fsw emrcmdacptcnt
let $cmdrjctd = fsw emrcmdrjctcnt
CMD FSW EMRNOOP
wait ((fsw emrcmdacptcnt = $cmdacptd + 1.0dn) and (fsw emrcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: EMRNOOP not registered as non-two-step command"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>EMRNOOP registered as non-two-step command successfully"
endif

; ciupdate

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIUPDATE with MSGID x#1A50, CODE 0, STEP 1
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIUPDATE unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIUPDATE accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

let $cmdacptd = fsw emrcmdacptcnt
CMD FSW EMRNOOP
wait 00:00:15
if fsw emrcmdacptcnt = $cmdacptd
	write "@PW "
	write "@PW <G>CIUPDATE for EMRNOOP to two-step worked as expected"
else
    write "@PW <R>Failed: CIUPDATE for EMRNOOP to two-step did not work"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CIUPDATE with MSGID x#1A50, CODE 0, STEP 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CIUPDATE unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CIUPDATE accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command over ground channel accepted as expected"
	endif
endif

let $cmdacptd = fsw emrcmdacptcnt
let $cmdrjctd = fsw emrcmdrjctcnt
CMD FSW EMRNOOP
wait ((fsw emrcmdacptcnt = $cmdacptd + 1.0dn) and (fsw emrcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: CIUPDATE for EMRNOOP to non-two-step did not work"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>CIUPDATE for EMRNOOP to non-two-step worked as expected"
endif

; cilogds

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CILOGDS with CHID 1
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd) and (fsw ciradiologst = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CILOGDS with CHID 1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CILOGDS with CHID 1 accepted as expected"
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CILOGDS with CHID 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd) and (fsw cisnkllogst = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CILOGDS with CHID 0 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CILOGDS with CHID 0 accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 2.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Commands over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Commands over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 2.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Commands over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Commands over ground channel accepted as expected"
	endif
endif

; cilogen

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CILOGEN with CHID 1
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd) and (fsw ciradiologst = 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CILOGEN with CHID 1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CILOGEN with CHID 1 accepted as expected"
endif

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CILOGEN with CHID 0
wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd) and (fsw cisnkllogst = 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CILOGEN with CHID 0 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CILOGEN with CHID 0 accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 2.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Commands over spacewire not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Commands over spacewire accepted as expected"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 2.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Commands over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Commands over ground channel accepted as expected"
	endif
endif

; cichds/en

let $cdhcmdacptd = cdh cmdacptcnt
let $cdhcmdrjctd = cdh cmdrjctcnt

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt

if $answer = spw
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
else; $answer = ground
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
endif

if $answer = spw
	CMD FSW SEQSTART with NAME "cich1test", ENGINE 1
else; $answer = ground
	CMD FSW SEQSTART with NAME "cich0test", ENGINE 1
endif

wait (fsw seqengst01 = IDLE) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Sequence cich1test not finished in appropriate time"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Sequence cich1test completed"
endif

wait ((fsw cicmdacptcnt = $cmdacptd + 2.0dn) and (fsw cicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: CI Commands in Sequence not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>CI Commands in Sequence accepted"
endif

write "@PW "
write "@PW Expecting command accept: CDH NOOP"
CMD CDH NOOP
wait ((cdh cmdacptcnt = $cdhcmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cdhcmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Channel did not come back up: CDH NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Channel is back up: CDH NOOP accepted as expected"
endif

if $answer = spw
	wait ((fsw ciradiopub = $chcmdacptd + 2.0dn) and (fsw ciradiorjct = $chcmdrjctd)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Radio did not publish 2 commands to SB"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Radio published 2 commands to SB successfully"
	endif
else; $answer = ground
	wait ((fsw cisnklpub = $chcmdacptd + 2.0dn) and (fsw cisnklrjct = $chcmdrjctd)) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Failed: Snorkel did not publish 2 commands to SB"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Snorkel published 2 commands to SB successfully"
	endif
endif


; test other channel

if $answer = spw
	
	if ((fsw ciradiob > 0.0dn) and (fsw cisnklb = 0.0dn))
		write "@PW "
		write "@PW <G>Bytes are being received from the radio channel"
	else
	    write "@PW <R>Failed: Bytes are not being received from the radio channel"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	endif
	
	write "@PW "
	write "@PW <Y>Switch channel to ground on Hydra and then type GO or "
	write "@PW <Y> type GOTO FINISH to skip testing the other channel"
	wait;GO to test other channel
	
	let $bothchannels = y
	
	let $chcmdacptd = fsw cisnklpub
	let $chcmdrjctd = fsw cisnklrjct
	
	let $cmdacptd = fsw cicmdacptcnt
	let $cmdrjctd = fsw cicmdrjctcnt
	write "@PW "
	write "@PW Expecting command accept: CINOOP"
	CMD FSW CINOOP
	wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd) and (fsw cisnklpub = $chcmdacptd + 1.0dn) and (fsw cisnklrjct = $chcmdrjctd) and (fsw cisnklb > 0.0dn)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command CINOOP and CI tlm over ground channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command CINOOP and CI tlm over ground channel accepted as expected"
	endif
	
else; $answer = ground
	
	if ((fsw cisnklb > 0.0dn) and (fsw ciradiob = 0.0dn))
		write "@PW "
		write "@PW <G>Bytes are being received from the ground channel"
	else
	    write "@PW <R>Failed: Bytes are not being received from the ground channel"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	endif
	
	write "@PW "
	write "@PW <Y>Switch channel to spacewire on Hydra and then type GO or "
	write "@PW <Y> type GOTO FINISH to skip testing the other channel"
	wait;GO to test other channel
	
	let $bothchannels = y
	
	let $chcmdacptd = fsw ciradiopub
	let $chcmdrjctd = fsw ciradiorjct
	
	let $cmdacptd = fsw cicmdacptcnt
	let $cmdrjctd = fsw cicmdrjctcnt
	write "@PW "
	write "@PW Expecting command accept: CINOOP"
	CMD FSW CINOOP
	wait ((fsw cicmdacptcnt = $cmdacptd + 1.0dn) and (fsw cicmdrjctcnt = $cmdrjctd) and (fsw ciradiopub = $chcmdacptd + 1.0dn) and (fsw ciradiorjct = $chcmdrjctd) and (fsw ciradiob > 0.0dn)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command CINOOP and CI tlm over spacewire channel not accepted"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command CINOOP and CI tlm over spacewire channel accepted as expected"
	endif
	
endif




FINISH:

write "@PW "
write "@PW Finishing..."
write "@PW "

if $bothchannels = y
	write "@PW <C>Tested over both channels"
else; $bothchannels = n
	if $answer = spw
		write "@PW <C>Tested over SpaceWire only"
	else; $answer = ground
		write "@PW <C>Tested by Ground only"
	endif
endif

write "@PW "
write "@PW Completed testing of CI"
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

endproc; ci

