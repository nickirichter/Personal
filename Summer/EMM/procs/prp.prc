proc prp
;*** $Revision: 1.14 $
;*** $Date: 2018/08/24 16:58:19 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/prp.prc,v $
;*
;* Created by: EMM Operations Account, Del Sherman
;* Creation Date: 11/06/2017
;*
;*  FUNCTION: Tests commands in PRP app
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Tests prp noop, prp cntreset, dvcathtr, pdx, rcscathtr,
;*           lv_(arm/en/fire), lv_rdnt(arm/en/fire), hb_ds, 
;*           hb_rdntds
;* 
;*           Aliased commands: pdx(off/on)_(p/r), dvcathtr(off/on)_(p/r),
;*                             rcscathtr(off/on)_(p/r),
;*                             lv(1/2/3/4/5/6)(op/cl)_(arm/en/fire),
;*                             lv(1/2/5/6)altop_(arm/en/fire)
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

write "@PW Starting procedure $RCSfile: prp.prc,v $"
write "@PW $Revision: 1.14 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $answer = y y,n
DECLARE VARIABLE $firetracker = 0.0ms

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

;prpnoop

let $cmdacptd = PRP CMDACPTCNT
let $cmdrjctd = PRP CMDRJCTCNT
write "@PW "
write "@PW Expecting command accept: PRP NOOP"
CMD PRP NOOP
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRP NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	wait (PRP CMDRJCTCNT = $cmdrjctd) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command PRP NOOP rejected"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command accepted as expected"
	endif
endif

; prpcntreset

;cmdcnt = 1, errcnt = 0

write "@PW "
write "@PW Expecting command: PRP CNTRESET"
CMD PRP CNTRESET
wait (PRP CMDACPTCNT = 0.0dn) or for $tm_wait
wait (PRP CMDRJCTCNT = 0.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRP CNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

;dvcathtr

write "@PW "
write "@PW Expecting command: set dvcathtr pri on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTR with switch on, side pri
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_pc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side PRI switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side PRI switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set dvcathtr red on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTR with switch on, side rdnt
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_rc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side RED switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side RED switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set dvcathtr pri off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTR with switch off, side pri
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_pc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side PRI switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side PRI switch OFF accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set dvcathtr red off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTR with switch off, side rdnt
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_rc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side RED switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side RED switch OFF accepted as expected"
endif

;dvcathtr: aliased commands

write "@PW "
write "@PW Expecting command: set dvcathtr pri on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTRON_P
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_pc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side PRI switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side PRI switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set dvcathtr red on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTRON_R
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_rc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side RED switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side RED switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set dvcathtr pri off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTROFF_P
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_pc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side PRI switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side PRI switch OFF accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set dvcathtr red off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP DVCATHTROFF_R
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps dvcathtr_rc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command dvcathtr side RED switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command dvcathtr side RED switch OFF accepted as expected"
endif

;pdx

write "@PW "
write "@PW Expecting command: set pdx pri on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDX with switch on, side pri
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_pc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side PRI switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side PRI switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set pdx red on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDX with switch on, side rdnt
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_rc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side RED switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side RED switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set pdx pri off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDX with switch off, side pri
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_pc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side PRI switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side PRI switch OFF accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set pdx red off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDX with switch off, side rdnt
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_rc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side RED switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side RED switch OFF accepted as expected"
endif

;pdx: aliased commands

write "@PW "
write "@PW Expecting command: set pdx pri on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDXON_P
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_pc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side PRI switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side PRI switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set pdx red on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDXON_R
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_rc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side RED switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side RED switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set pdx pri off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDXOFF_P
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_pc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side PRI switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side PRI switch OFF accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set pdx red off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP PDXOFF_R
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps pdx_rc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command pdx side RED switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command pdx side RED switch OFF accepted as expected"
endif


;rcscathtr

write "@PW "
write "@PW Expecting command: set rcscathtr pri on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTR with switch on, side pri
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_pc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side PRI switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side PRI switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set rcscathtr red on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTR with switch on, side rdnt
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_rc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side RED switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side RED switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set rcscathtr pri off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTR with switch off, side pri
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_pc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side PRI switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side PRI switch OFF accepted as expected"
endif
write "@PW "
write "@PW Expecting command: set rcscathtr red off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTR with switch off, side rdnt
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_rc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side RED switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side RED switch OFF accepted as expected"
endif

;rcscathtr: aliased commands

write "@PW "
write "@PW Expecting command: set rcscathtr pri on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTRON_P
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_pc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side PRI switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side PRI switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set rcscathtr red on"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTRON_R
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_rc = ON) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side RED switch ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side RED switch ON accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set rcscathtr pri off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTROFF_P
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_pc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side PRI switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side PRI switch OFF accepted as expected"
endif

write "@PW "
write "@PW Expecting command: set rcscathtr red off"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP RCSCATHTROFF_R
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps rcscathtr_rc = OFF) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command rcscathtr side RED switch OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command rcscathtr side RED switch OFF accepted as expected"
endif


;LV

write "@PW <Y>Latch Valves are protected commands. Proceed?"
write "@PW Type 'GO' to proceed"
wait; GO to continue

;closing LV switches

;insert LV close command checks when 1, 2, 5, and 6 have a telemetry response to close command
write "@PW "
write "@PW <Y>There is no telemetry to check LV1, 2, 5, and 6 close at this time."

write "@PW "
write "@PW Expecting command: close latch valve 1"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_ARM with switch close, valve lv1
wait 00:00:02
CMD PRP LV_EN with switch close, valve lv1
wait 00:00:02
CMD PRP LV_FIRE with switch close, valve lv1
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 1 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 1 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 2"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_ARM with switch close, valve lv2
wait 00:00:02
CMD PRP LV_EN with switch close, valve lv2
wait 00:00:02
CMD PRP LV_FIRE with switch close, valve lv2
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 2 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 2 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 3"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack21
wait 00:00:02
CMD PRP LV_ARM with switch close, valve lv3
wait 00:00:02
CMD PRP LV_EN with switch close, valve lv3
wait 00:00:02
CMD PRP LV_FIRE with switch close, valve lv3
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack21 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 3 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 3 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 4"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack21
wait 00:00:02
CMD PRP LV_ARM with switch close, valve lv4
wait 00:00:02
CMD PRP LV_EN with switch close, valve lv4
wait 00:00:02
CMD PRP LV_FIRE with switch close, valve lv4
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack21 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 4 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 4 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 5"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_ARM with switch close, valve lv5
wait 00:00:02
CMD PRP LV_EN with switch close, valve lv5
wait 00:00:02
CMD PRP LV_FIRE with switch close, valve lv5
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 5 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 5 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 6"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_ARM with switch close, valve lv6
wait 00:00:02
CMD PRP LV_EN with switch close, valve lv6
wait 00:00:02
CMD PRP LV_FIRE with switch close, valve lv6
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 6 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 6 accepted as expected"
endif

;LV_RDNT


write "@PW <Y>Redundant Latch Valves are protected commands. Proceed?"
write "@PW Type 'GO' to proceed"
wait; GO to continue

write "@PW "
write "@PW Expecting command: redundant latch valve 1"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_RDNTARM with hbridge lv1
wait 00:00:02
CMD PRP LV_RDNTEN with hbridge lv1
wait 00:00:02
CMD PRP LV_RDNTFIRE with hbridge lv1
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 1 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 1 accepted as expected"
endif
 
write "@PW "
write "@PW Expecting command: redundant latch valve 2"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_RDNTARM with hbridge lv2
wait 00:00:02
CMD PRP LV_RDNTEN with hbridge lv2
wait 00:00:02
CMD PRP LV_RDNTFIRE with hbridge lv2
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 2 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 2 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: redundant latch valve 5"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_RDNTARM with hbridge lv5
wait 00:00:02
CMD PRP LV_RDNTEN with hbridge lv5
wait 00:00:02
CMD PRP LV_RDNTFIRE with hbridge lv5
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 5 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 5 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: redundant latch valve 6"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV_RDNTARM with hbridge lv6
wait 00:00:02
CMD PRP LV_RDNTEN with hbridge lv6
wait 00:00:02
CMD PRP LV_RDNTFIRE with hbridge lv6
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 6 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 6 accepted as expected"
endif

;open LV switches

write "@PW "
write "@PW Expecting command: open latch valve 1"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack18
wait 00:00:02
CMD PRP LV_ARM with switch open, valve lv1
wait 00:00:02
CMD PRP LV_EN with switch open, valve lv1
wait 00:00:02
CMD PRP LV_FIRE with switch open, valve lv1
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack18 = $firetracker + 100.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 1 accepted as expected"
endif


write "@PW "
write "@PW Expecting command: open latch valve 2"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack18
wait 00:00:02
CMD PRP LV_ARM with switch open, valve lv2
wait 00:00:02
CMD PRP LV_EN with switch open, valve lv2
wait 00:00:02
CMD PRP LV_FIRE with switch open, valve lv2
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack18 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 2 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 2 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 3"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack20
wait 00:00:02
CMD PRP LV_ARM with switch open, valve lv3
wait 00:00:02
CMD PRP LV_EN with switch open, valve lv3
wait 00:00:02
CMD PRP LV_FIRE with switch open, valve lv3
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack20 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 3 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 3 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 4"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack20
wait 00:00:02
CMD PRP LV_ARM with switch open, valve lv4
wait 00:00:02
CMD PRP LV_EN with switch open, valve lv4
wait 00:00:02
CMD PRP LV_FIRE with switch open, valve lv4
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack20 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 4 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 4 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 5"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack22
wait 00:00:02
CMD PRP LV_ARM with switch open, valve lv5
wait 00:00:02
CMD PRP LV_EN with switch open, valve lv5
wait 00:00:02
CMD PRP LV_FIRE with switch open, valve lv5
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack22 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 5 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 5 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 6"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack22
wait 00:00:02
CMD PRP LV_ARM with switch open, valve lv6
wait 00:00:02
CMD PRP LV_EN with switch open, valve lv6
wait 00:00:02
CMD PRP LV_FIRE with switch open, valve lv6
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack22 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 6 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 6 accepted as expected"
endif


;aliased commands: LV(1/2/3/4/5/6)(OP/CL)_(ARM/EN/FIRE); LV(1/2/5/6)ALTOP_(ARM/EN/FIRE)

;LV

write "@PW "
write "@PW Testing aliased Latch Valve Commands"

write "@PW <Y>Latch Valves are protected commands. Proceed?"
write "@PW Type 'GO' to proceed"
wait; GO to continue

;closing LV switches

;insert LV close command checks when 1, 2, 5, and 6 have a telemetry response to close command
write "@PW "
write "@PW <Y>There is no telemetry to check LV1, 2, 5, and 6 close at this time."

write "@PW "
write "@PW Expecting command: close latch valve 1"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV1CL_ARM
wait 00:00:02
CMD PRP LV1CL_EN
wait 00:00:02
CMD PRP LV1CL_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 1 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 1 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 2"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV2CL_ARM
wait 00:00:02
CMD PRP LV2CL_EN
wait 00:00:02
CMD PRP LV2CL_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 2 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 2 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 3"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack21
wait 00:00:02
CMD PRP LV3CL_ARM
wait 00:00:02
CMD PRP LV3CL_EN
wait 00:00:02
CMD PRP LV3CL_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack21 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 3 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 3 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 4"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack21
wait 00:00:02
CMD PRP LV4CL_ARM
wait 00:00:02
CMD PRP LV4CL_EN
wait 00:00:02
CMD PRP LV4CL_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack21 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 4 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 4 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 5"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV5CL_ARM
wait 00:00:02
CMD PRP LV5CL_EN
wait 00:00:02
CMD PRP LV5CL_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 5 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 5 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: close latch valve 6"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV6CL_ARM
wait 00:00:02
CMD PRP LV6CL_EN
wait 00:00:02
CMD PRP LV6CL_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command close Latch Valve 6 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command close Latch Valve 6 accepted as expected"
endif

;LV_RDNT

write "@PW "
write "@PW Testing aliased Redundant Latch Valve Commands"

write "@PW <Y>Redundant Latch Valves are protected commands. Proceed?"
write "@PW Type 'GO' to proceed"
wait; GO to continue

write "@PW "
write "@PW Expecting command: redundant latch valve 1"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV1ALTOP_ARM
wait 00:00:02
CMD PRP LV1ALTOP_EN
wait 00:00:02
CMD PRP LV1ALTOP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 1 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 1 accepted as expected"
endif
 
write "@PW "
write "@PW Expecting command: redundant latch valve 2"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV2ALTOP_ARM
wait 00:00:02
CMD PRP LV2ALTOP_EN
wait 00:00:02
CMD PRP LV2ALTOP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 2 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 2 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: redundant latch valve 5"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV5ALTOP_ARM
wait 00:00:02
CMD PRP LV5ALTOP_EN
wait 00:00:02
CMD PRP LV5ALTOP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 5 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 5 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: redundant latch valve 6"
let $cmdacptd = PRP CMDACPTCNT
wait 00:00:02
CMD PRP LV6ALTOP_ARM
wait 00:00:02
CMD PRP LV6ALTOP_EN
wait 00:00:02
CMD PRP LV6ALTOP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command redundant Latch Valve 6 not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command redundant Latch Valve 6 accepted as expected"
endif

;open LV switches

write "@PW "
write "@PW Expecting command: open latch valve 1"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack18
wait 00:00:02
CMD PRP LV1OP_ARM
wait 00:00:02
CMD PRP LV1OP_EN
wait 00:00:02
CMD PRP LV1OP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack18 = $firetracker + 100.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 1 accepted as expected"
endif


write "@PW "
write "@PW Expecting command: open latch valve 2"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack18
wait 00:00:02
CMD PRP LV2OP_ARM
wait 00:00:02
CMD PRP LV2OP_EN
wait 00:00:02
CMD PRP LV2OP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack18 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 2 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 2 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 3"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack20
wait 00:00:02
CMD PRP LV3OP_ARM
wait 00:00:02
CMD PRP LV3OP_EN
wait 00:00:02
CMD PRP LV3OP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack20 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 3 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 3 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 4"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack20
wait 00:00:02
CMD PRP LV4OP_ARM
wait 00:00:02
CMD PRP LV4OP_EN
wait 00:00:02
CMD PRP LV4OP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack20 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 4 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 4 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 5"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p1firetrack22
wait 00:00:02
CMD PRP LV5OP_ARM
wait 00:00:02
CMD PRP LV5OP_EN
wait 00:00:02
CMD PRP LV5OP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack22 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 5 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 5 accepted as expected"
endif

write "@PW "
write "@PW Expecting command: open latch valve 6"
let $cmdacptd = PRP CMDACPTCNT
let $firetracker = eps p2firetrack22
wait 00:00:02
CMD PRP LV6OP_ARM
wait 00:00:02
CMD PRP LV6OP_EN
wait 00:00:02
CMD PRP LV6OP_FIRE
wait (PRP CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack22 = $firetracker + 50.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command open Latch Valve 6 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command open Latch Valve 6 accepted as expected"
endif


;hb_ds
write "@PW "
write "@PW Expecting command: disable H-bridge high side switch on LV1"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_DS with HBRIDGE LV1
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_DS with LV1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_DS with LV1 successful"
endif

write "@PW "
write "@PW Expecting command: disable H-bridge high side switch on LV2"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_DS with HBRIDGE LV2
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_DS with LV2 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_DS with LV2 successful"
endif

write "@PW "
write "@PW Expecting command: disable H-bridge high side switch on LV5"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_DS with HBRIDGE LV5
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_DS with LV5 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_DS with LV5 successful"
endif

write "@PW "
write "@PW Expecting command: disable H-bridge high side switch on LV6"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_DS with HBRIDGE LV6
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_DS with LV6 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_DS with LV6 successful"
endif


;hb_rdntds
write "@PW "
write "@PW Expecting command: disable redundant H-bridge high side switch on LV1"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_RDNTDS with HBRIDGE LV1
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_RDNTDS with LV1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_RDNTDS with LV1 successful"
endif

write "@PW "
write "@PW Expecting command: disable redundant H-bridge high side switch on LV2"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_RDNTDS with HBRIDGE LV2
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_RDNTDS with LV2 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_RDNTDS with LV2 successful"
endif

write "@PW "
write "@PW Expecting command: disable redundant H-bridge high side switch on LV5"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_RDNTDS with HBRIDGE LV5
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_RDNTDS with LV5 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_RDNTDS with LV5 successful"
endif

write "@PW "
write "@PW Expecting command: disable redundant H-bridge high side switch on LV6"
let $cmdacptd = PRP CMDACPTCNT
CMD PRP HB_RDNTDS with HBRIDGE LV6
wait (PRP CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for HB_RDNTDS with LV6 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter for HB_RDNTDS with LV6 successful"
endif



;;testing bad commands
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error if necessary."
;CMD PRP DVCATHTR with switch 2, SIDE 1
;ask $answer "Did command fail?"
;if $answer = y
;	write "@PW "
;	write "@PW <G>Command failed as expected"
;else
;	write "@PW <R>Command did not fail as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;endif
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error if necessary."
;CMD PRP DVCATHTR with switch on, SIDE 2
;ask $answer "Did command fail?"
;if $answer = y
;	write "@PW "
;	write "@PW <G>Command failed as expected"
;else
;	write "@PW <R>Command did not fail as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;endif
;
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error if necessary."
;CMD PRP PDX with switch 2, SIDE 1
;ask $answer "Did command fail?"
;if $answer = y
;	write "@PW "
;	write "@PW <G>Command failed as expected"
;else
;	write "@PW <R>Command did not fail as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;endif
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error if necessary."
;CMD PRP PDX with switch on, SIDE 2
;ask $answer "Did command fail?"
;if $answer = y
;	write "@PW "
;	write "@PW <G>Command failed as expected"
;else
;	write "@PW <R>Command did not fail as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;endif
;
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error if necessary."
;CMD PRP RCSCATHTR with switch 2, SIDE 1
;ask $answer "Did command fail?"
;if $answer = y
;	write "@PW "
;	write "@PW <G>Command failed as expected"
;else
;	write "@PW <R>Command did not fail as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;endif
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error if necessary."
;CMD PRP RCSCATHTR with switch on, SIDE 2
;ask $answer "Did command fail?"
;if $answer = y
;	write "@PW "
;	write "@PW <G>Command failed as expected"
;else
;	write "@PW <R>Command did not fail as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;endif


FINISH:

write "@PW "
write "@PW Checking command reject counter..."

if prp cmdrjctcnt > 0.0dn
    write "@PW <R>Failed: There were rejected commands during this test"
    write "@PW <R>Number of rejected commands:", prp cmdrjctcnt
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>No commands rejected during this test"
endif

write "@PW "
write "@PW Completed testing of PRP"
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

endproc; prp

