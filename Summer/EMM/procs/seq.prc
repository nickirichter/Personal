proc seq
;*** $Revision: 1.9 $
;*** $Date: 2018/08/24 16:58:19 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/seq.prc,v $
;*
;* Created by: EMM Operations Account
;* Creation Date: 12/06/2017
;*
;*  FUNCTION: (concise synopsis of what this procedure does)
;*
;*  PARAMETERS: (calling arguments, and what they are used for)
;*
;*  HAZARDS: (config. requirements, or any issues people should be aware of)
;*
;*  OUTLINE: (procedure flow, what it does, what it checks, etc.)
;*
;*  INVOKES:
;*  Procedures: init.prc
;*  Utilities: (any UNIX utilities spawned by this procedure)
;*
;*  RETURNS: (return status(s) if any, ie. sets OASIS_PROC STATUS)
;*
;*  CALLED BY: (if part of a test or sequence, what procs call this one)
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

write "@PW Starting procedure $RCSfile: seq.prc,v $"
write "@PW $Revision: 1.9 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:15
DECLARE VARIABLE $shortwait = 00:00:03
DECLARE VARIABLE $foreverwait = 01:20:00
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $answer = y y,n

;; main body of script

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

wait $shortwait

let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQNOOP
write "@PW "
write "@PW Expecting command accept: SEQNOOP"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQNOOP rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


CMD FSW SEQCNTRESET
write "@PW "
write "@PW Expecting command: FSW SEQCNTRESET"
wait ((fsw seqcmdacptcnt = 0.0dn) and (fsw seqcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQCNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $shortwait


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQSTART with NAME "seqnoops", engine 1
write "@PW "
write "@PW Expecting command accept: SEQSTART"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQSTART not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQSTART rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQPAUSE with ENGINE 1
write "@PW "
write "@PW Expecting command accept: SEQPAUSE"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQPAUSE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQPAUSE rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQRESUME with ENGINE 1
write "@PW "
write "@PW Expecting command accept: SEQRESUME"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQRESUME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQRESUME rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQSTART with NAME "seqprpnoop2", ENGINE 4
write "@PW "
write "@PW Expecting command accept: SEQSTART"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQSTART not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQSTART rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait 00:00:10


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt

CMD FSW SEQHALTNAME with NAME "seqprpnoop2"
write "@PW "
write "@PW Expecting command accept: SEQHALT"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQHALT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQHALT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQHALTENG with ENGINE 1; NUM
write "@PW "
write "@PW Expecting command accept: SEQHALT"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQHALT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQHALT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQSTART with NAME "seqnoops", ENGINE 9
write "@PW "
write "@PW Expecting command accept: SEQSTART"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQSTART not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQSTART rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait 00:01:00


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt

CMD FSW SEQHALTCAT with CATEGORY 1
write "@PW "
write "@PW Expecting command accept: SEQHALT"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQHALT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQHALT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait

let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQSTATE with STATE 3
;disable SEQ
write "@PW "
write "@PW Expecting command accept: SEQSTATE"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQSTATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQSTATE rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif
wait $shortwait


;let $cmdacptd = fsw seqcmdacptcnt
;let $cmdrjctd = fsw seqcmdrjctcnt
;CMD FSW SEQNOOP
;;noop should fail?
;write "@PW "
;write "@PW Expecting command accept: SEQNOOP"
;wait (fsw seqcmdrjctcnt = $cmdrjctd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command SEQNOOP didn't fail"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw seqcmdacptcnt = $cmdacptd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command SEQSTATE rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif
;
;wait $shortwait


let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQSTATE with STATE 1
;should start SEQ
write "@PW "
write "@PW Expecting command accept: SEQSTATE"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQSTATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQSTATE rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait

let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQGVSET with INDEX 0, VALUE 5
;then run a sequence that depends on the values above (first GV set to 5)
; only partially tested right now.
write "@PW "
write "@PW Expecting command accept: SEQGVSET"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQGVSET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQGVSET rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif
wait $shortwait

let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQGVSEND
;EVENT MSG? or does a packet get populated?
write "@PW "
write "@PW Expecting command accept: SEQGVSEND"
wait (fsw seqcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQGVSEND not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw seqcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command SEQGVSEND rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait


;ask $answer "Do you want to kick off the THM sequence? It runs for ~1hr - this script will occupy CLP5. (y,n)"
;
;if $answer = y
;
;5start seqTHM
;
;
;else
;    GOTO FINISH
;endif



wait $shortwait


;let $cmdacptd = fsw seqcmdacptcnt
;let $cmdrjctd = fsw seqcmdrjctcnt
;CMD FSW SEQSTARTARGS WITH NAME XXX, ENGINE 5, ARG01 5, ARG02 7
;;start a sequence with the args predefined, but on the fly

;seqgvsetstr with index xxx, value xxx

;seqlogset engine, state



FINISH:

if $test_err = 0
	write "@PW <G>Total number of errors: ", $test_err
else
	write "@PW <R>Total number of errors: ", $test_err
endif

    write "@PW "
    write "@PW <Y>Expected number of commands rejected: 0"

if $cmdrjctd = 1.0dn
    write "@PW <G>Total number of commands rejected: 0"
else
    write "@PW <R>Total number of commands rejected: ", $cmdrjctd
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

endproc; seq

