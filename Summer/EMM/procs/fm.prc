proc fm
;*** $Revision: 1.7 $
;*** $Date: 2018/09/09 19:23:56 $
goto BEGIN
;***************************************************************************
;* PROJECT:EMM
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/fm.prc,v $
;*
;* Created by: EMM Operations Account
;* Creation Date: 04/12/2018
;*
;*  FUNCTION: Tests the FM application
;*
;*  PARAMETERS: (calling arguments, and what they are used for)
;*
;*  HAZARDS: (config. requirements, or any issues people should be aware of)
;*
;*  OUTLINE: 
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
;*  04/12/18, S. DeVogel, Created script
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

write "@PW Starting procedure $RCSfile: fm.prc,v $"
write "@PW $Revision: 1.7 $"


; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:15
DECLARE VARIABLE $shortwait = 00:00:03
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $answer = y y,n


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

    write "@PW <Y>Open APID panels 122, 123, and 124 before proceeding" 
    write "@PW <Y>Then type 'GO' to continue"
wait; 
   

CMD FSW FMCNTRESET

wait $tm_wait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt

wait $shortwait

CMD FSW FMNOOP
write "@PW "
write "@PW Expecting command accept: FMNOOP"
wait ((fsw fmcmdacptcnt = $cmdacptd + 1.0dn) and (fsw fmcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMNOOP rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMCNTRESET
write "@PW "
write "@PW Expecting command: FSW FMCNTRESET"
wait ((fsw fmcmdacptcnt = 0.0dn) and (fsw fmcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMCNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;load files along with the fsw build
;first, check for available free space
CMD FSW FMFREE
write "@PW "
write "@PW Expecting command accept: FMFREE"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;somehow check to make sure free space is > some ammount
if $$error = time_out
    write "@PW <R>Failed: Command FMFREE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMFREE rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


;let $cmdacptd = fsw fmcmdacptcnt
;let $cmdrjctd = fsw fmcmdrjctcnt
;;then mkdir "/ram/seq" for example
;CMD FSW FMMKDIR with DIR "/ram/seq"
;write "@PW "
;write "@PW Expecting command accept: FMMKDIR"
;wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command FMMKDIR not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command FMMKDIR rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif
;
;
;wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/seq", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then FMCP ~2 files to /ram/seq from /ram/uplink
CMD FSW FMCP with OVR 0, SRC "/ram/uplink/seqadcnoop.bin", TARGET "/ram/seq/seqadcnoop.bin"
write "@PW "
write "@PW Expecting command accept: FMCP"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMCP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMCP rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMCP with OVR 0, SRC "/ram/uplink/seqepsnoop2.bin", TARGET "/ram/seq/seqepsnoop2.bin"
write "@PW "
write "@PW Expecting command accept: FMCP"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMCP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMCP rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait



let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMCP with OVR 0, SRC "/ram/uplink/seqprpnoop2.bin", TARGET "/ram/seq/seqprpnoop2.bin"
write "@PW "
write "@PW Expecting command accept: FMCP"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMCP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMCP rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then FMMV ~ 3 files to /ram/seq from /ram/uplink
CMD FSW FMMV with OVR 0, SRC "/ram/uplink/seqnoops.bin", TARGET "/ram/seq/seqnoops.bin"
write "@PW "
write "@PW Expecting command accept: FMMV"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMMV not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMMV rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMMV with OVR 0, SRC "/ram/uplink/lcDelEPS.bin", TARGET "/ram/seq/lcDelEPS.bin"
write "@PW "
write "@PW Expecting command accept: FMMV"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMMV not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMMV rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait



let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMMV with OVR 0, SRC "/ram/uplink/lcDelTHM.bin", TARGET "/ram/seq/lcDelTHM.bin"
write "@PW "
write "@PW Expecting command accept: FMMV"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMMV not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMMV rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait



let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/seq", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


;wait $shortwait
;
;let $cmdacptd = fsw fmcmdacptcnt
;let $cmdrjctd = fsw fmcmdrjctcnt
;CMD FSW FMMV with OVR 0, SRC "/rom/seq/initial_on.rts.bin", TARGET "/ram/seq/initial_on.rts.bin"
;write "@PW "
;write "@PW Expecting command accept: FMMV"
;wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command FMMV not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command FMMV rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif


;wait $shortwait
;
;let $cmdacptd = fsw fmcmdacptcnt
;let $cmdrjctd = fsw fmcmdrjctcnt
;CMD FSW FMMV with OVR 0, SRC "/rom/seq/initial_on.blk.bin", TARGET "/ram/seq/initial_on.blk.bin"
;write "@PW "
;write "@PW Expecting command accept: FMMV"
;wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command FMMV not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command FMMV rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif


;wait $shortwait
;
;let $cmdacptd = fsw fmcmdacptcnt
;let $cmdrjctd = fsw fmcmdrjctcnt
;CMD FSW FMMV with OVR 0, SRC "/rom/seq/sa_deploy.blk.bin", TARGET "/ram/seq/sa_deploy.blk.bin"
;write "@PW "
;write "@PW Expecting command accept: FMMV"
;wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command FMMV not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command FMMV rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif


;wait $shortwait
;
;let $cmdacptd = fsw fmcmdacptcnt
;let $cmdrjctd = fsw fmcmdrjctcnt
;CMD FSW FMMV with OVR 0, SRC "/rom/seq/heater_on.blk.bin", TARGET "/ram/seq/heater_on.blk.bin"
;write "@PW "
;write "@PW Expecting command accept: FMMV"
;wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command FMMV not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command FMMV rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif


;wait $shortwait



;let $cmdacptd = fsw fmcmdacptcnt
;let $cmdrjctd = fsw fmcmdrjctcnt
;CMD FSW FMMV with OVR 0, SRC "/rom/seq/mx_wing_dpl.blk.bin", TARGET "/ram/seq/mx_wing_dpl.blk.bin"
;write "@PW "
;write "@PW Expecting command accept: FMMV"
;wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command FMMV not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command FMMV rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif


;wait $shortwait

;let $cmdacptd = fsw fmcmdacptcnt
;let $cmdrjctd = fsw fmcmdrjctcnt
;CMD FSW FMMV with OVR 0, SRC "/rom/seq/px_wing_dpl.blk.bin", TARGET "/ram/seq/px_wing_dpl.blk.bin"
;write "@PW "
;write "@PW Expecting command accept: FMMV"
;wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command FMMV not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command FMMV rejected"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;wait for documentation, then type 'GO'
;	else
;		write "@PW "
;		write "@PW <G>Command accepted as expected"
;	endif
;endif


wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/seq", OFFSET 10, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait




let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then FMRENAME something to something
CMD FSW FMRENAME with SRC "/ram/uplink/seqadcnoop.bin", TARGET "/ram/uplink/deadadcnoop.bin"
write "@PW "
write "@PW Expecting command accept: FMRENAME"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRENAME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMRENAME rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/uplink", OFFSET 0, MODE 1
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then get info on that file
CMD FSW FMLSFILE with DIR "/ram/uplink", FILE "deadadcnoop.bin", MODE 1
write "@PW "
write "@PW Expecting command accept: FMLSFILE"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSFILE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSFILE rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/uplink", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then make another directory - perhaps within /ram/seq
;maybe name it kill_me
CMD FSW FMMKDIR with DIR "/ram/seq/kill_me"
write "@PW "
write "@PW Expecting command accept: FMMKDIR"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMMKDIR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMMKDIR rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/seq", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then FMMV the renamed file into that directory
CMD FSW FMMV with OVR 0, SRC "/ram/uplink/deadadcnoop.bin", TARGET "/ram/seq/kill_me/deadadcnoop.bin"
write "@PW "
write "@PW Expecting command accept: FMMV"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMMV not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMMV rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/seq/kill_me", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait


;wait; Do you want to remove all file from /ram/uplink?
ask $answer "Are you cool with deleting everything leftover in /ram/uplink? (y,n)"

if $answer = y 

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then FMRM the first ~3 files from /ram/uplink
CMD FSW FMRMALL with DIR "/ram/uplink"
write "@PW "
write "@PW Expecting command accept: FMRMALL"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMMV not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMMV rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif



wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/uplink", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif
;
;wait $shortwait

endif; from the 'ask' of RMALL


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then blast that file away
CMD FSW FMRM with NAME "/ram/seq/kill_me/deadadcnoop.bin"
write "@PW "
write "@PW Expecting command accept: FMRM"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMRM rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait

let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/seq/kill_me", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif


wait $shortwait


let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
;then blast that directory away
CMD FSW FMRMDIR with DIR "/ram/seq/kill_me"
write "@PW "
write "@PW Expecting command accept: FMRMDIR"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRMDIR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMRMDIR rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

wait $shortwait



let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMLSPKT with DIR "/ram/seq", OFFSET 0, MODE 0
write "@PW "
write "@PW Expecting command accept: FMLSPKT"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (fsw fmcmdrjctcnt = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command FMLSPKT rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif



;----------------------------------------
;test these commands next

;CMD FSW FMOPEN

;CMD FSW FMDECOMP, SRC, TARGET

;CMD FSW FMCAT, SRC1, SRC2, TARGET

;CMD FSW FMINFO, NAME, CRC (tested in seq_blks.prc)

;CMD FSW FMTBLSET, INDEX, STATE

;CMD FSW FMRMINT, NAME


FINISH:

if $test_err = 0
	write "@PW <G>Total number of errors: ", $test_err
else
	write "@PW <R>Total number of errors: ", $test_err
endif

    write "@PW "
    write "@PW <Y>Expected number of commands rejected: 0"

if $cmdrjctd = 0.0dn
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

endproc; fm

