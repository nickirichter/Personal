proc eps
;*** $Revision: 1.21 $
;*** $Date: 2018/09/09 17:41:30 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/eps.prc,v $
;*
;* Created by: EMM Operations Account, Del Sherman
;* Creation Date: 10/10/2017
;*
;*  FUNCTION: Tests commands in EPS app with user needed to type GO
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Tests eps noop, eps cntreset, eps hdrms, eps peek, eps poke,
;*           eps battchrgtgt, eps chrgmonrst, eps chrgmonset, eps ccinit
;*           eps req_peakhold, eps req_hdrmhr
;*
;*           Aliased Commands: batchrg(hi/lo), chrgmon(a/b)_rst, chrgmon(a/b)_set
;*                             hdrms_(13/24/57/68)_(arm/en/fire)(p/r)
;*
;*  INVOKES:
;*  Procedures: init.prc
;*  Utilities: N/A
;*
;*  RETURNS: (return status(s) if any, ie. sets OASIS_PROC STATUS)
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

write "@PW Starting procedure $RCSfile: eps.prc,v $"
write "@PW $Revision: 1.21 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $lng_wait = 00:00:30
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $firetracker = 0.0ms
DECLARE VARIABLE $target_tlm = 0.0dn
DECLARE VARIABLE $answer = y y,n
DECLARE VARIABLE $pre_poke_eu = 0.0dn
DECLARE VARIABLE $pre_poke_real = 0.0
DECLARE VARIABLE $pre_poke_int = 0
DECLARE VARIABLE $srcseqcnt = 0.0dn

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

write "@PW "
write "@PW Testing noop"


;eps noop
let $cmdacptd = EPS CMDACPTCNT
let $cmdrjctd = EPS CMDRJCTCNT
CMD EPS NOOP
write "@PW "
write "@PW Expecting command accept: EPS NOOP"
wait ((EPS CMDACPTCNT = $cmdacptd + 1.0dn) and (EPS CMDRJCTCNT = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

;eps cntreset

write "@PW "
write "@PW Testing cntreset..."

;send faulty command syntax to increment errcnt??

CMD EPS CNTRESET
write "@PW "
write "@PW Expecting command: EPS CNTRESET"
wait ((EPS CMDACPTCNT = 0.0dn) and (EPS CMDRJCTCNT = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CNTRESET accepted as expected"
endif


;eps HDRMs

write "@PW "
write "@PW Testing HDRMs"

write "@PW HDRM is a protected command. Proceed?"
write "@PW Type 'GO' to proceed"
wait; GO to continue


;hdrms_1_3, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack04
write "@PW "
write "@PW Expecting command: EPS HDRMS 1_3 PRI"
CMD EPS HDRMS_ARM with HDRMS hdrms_1_3, TYPE pri
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_1_3, TYPE pri
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_1_3, TYPE pri
;wait (eps p1firecnt04 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 1_3 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 1_3 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack04 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 1_3 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 1_3 pri accepted as expected"
endif


;hdrms_5_7, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack05
write "@PW "
write "@PW Expecting command: EPS HDRMS 5_7 PRI"
CMD EPS HDRMS_ARM with HDRMS hdrms_5_7, TYPE pri
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_5_7, TYPE pri
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_5_7, TYPE pri
;wait (eps p1firecnt05 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 5_7 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 5_7 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack05 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 5_7 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 5_7 pri accepted as expected"
endif


;hdrms_2_4, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack10
write "@PW "
write "@PW Expecting command: EPS HDRMS 2_4 PRI"
CMD EPS HDRMS_ARM with HDRMS hdrms_2_4, TYPE pri
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_2_4, TYPE pri
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_2_4, TYPE pri
;wait (eps p1firecnt10 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 2_4 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 2_4 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack10 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 2_4 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 2_4 pri accepted as expected"
endif


;hdrms_6_8, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack11
write "@PW "
write "@PW Expecting command: EPS HDRMS 6_8 PRI"
CMD EPS HDRMS_ARM with HDRMS hdrms_6_8, TYPE pri
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_6_8, TYPE pri
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_6_8, TYPE pri
;wait (eps p1firecnt11 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 6_8 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 6_8 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack11 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 6_8 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 6_8 pri accepted as expected"
endif


;hdrms_1_3, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack04
write "@PW "
write "@PW Expecting command: EPS HDRMS 1_3 REDUNDANT"
CMD EPS HDRMS_ARM with HDRMS hdrms_1_3, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_1_3, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_1_3, TYPE rdnt
;wait (eps p2firecnt04 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 1_3 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 1_3 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack04 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 1_3 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 1_3 redundant accepted as expected"
endif


;hdrms_5_7, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack05
write "@PW "
write "@PW Expecting command: EPS HDRMS 5_7 REDUNDANT"
CMD EPS HDRMS_ARM with HDRMS hdrms_5_7, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_5_7, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_5_7, TYPE rdnt
;wait (eps p2firecnt05 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 5_7 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 5_7 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack05 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 5_7 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 5_7 redundant accepted as expected"
endif


;hdrms_2_4, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack10
write "@PW "
write "@PW Expecting command: EPS HDRMS 2_4 REDUNDANT"
CMD EPS HDRMS_ARM with HDRMS hdrms_2_4, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_2_4, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_2_4, TYPE rdnt
;wait (eps p2firecnt10 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 2_4 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 2_4 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack10 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 2_4 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 2_4 redundant accepted as expected"
endif


;hdrms_6_8, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack11
write "@PW "
write "@PW Expecting command: EPS HDRMS 6_8 REDUNDANT"
CMD EPS HDRMS_ARM with HDRMS hdrms_6_8, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_EN with HDRMS hdrms_6_8, TYPE rdnt
wait 00:00:02
CMD EPS HDRMS_FIRE with HDRMS hdrms_6_8, TYPE rdnt
;wait (eps p2firecnt11 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 6_8 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 6_8 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack11 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 6_8 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 6_8 redundant accepted as expected"
endif


;aliased hdrms commands

write "@PW "
write "@PW Testing aliased HDRMS commands"

;hdrms_1_3, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack04
write "@PW "
write "@PW Expecting command: EPS HDRMS 1_3 PRI"
CMD EPS HDRMS_13_ARMP
wait 00:00:02
CMD EPS HDRMS_13_ENP
wait 00:00:02
CMD EPS HDRMS_13_FIREP
;wait (eps p1firecnt04 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 1_3 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 1_3 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack04 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 1_3 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 1_3 pri accepted as expected"
endif


;hdrms_5_7, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack05
write "@PW "
write "@PW Expecting command: EPS HDRMS 5_7 PRI"
CMD EPS HDRMS_57_ARMP
wait 00:00:02
CMD EPS HDRMS_57_ENP
wait 00:00:02
CMD EPS HDRMS_57_FIREP
;wait (eps p1firecnt05 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 5_7 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 5_7 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack05 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 5_7 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 5_7 pri accepted as expected"
endif


;hdrms_2_4, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack10
write "@PW "
write "@PW Expecting command: EPS HDRMS 2_4 PRI"
CMD EPS HDRMS_24_ARMP
wait 00:00:02
CMD EPS HDRMS_24_ENP
wait 00:00:02
CMD EPS HDRMS_24_FIREP
;wait (eps p1firecnt10 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 2_4 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 2_4 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack10 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 2_4 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 2_4 pri accepted as expected"
endif


;hdrms_6_8, pri
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p1firetrack11
write "@PW "
write "@PW Expecting command: EPS HDRMS 6_8 PRI"
CMD EPS HDRMS_68_ARMP
wait 00:00:02
CMD EPS HDRMS_68_ENP
wait 00:00:02
CMD EPS HDRMS_68_FIREP
;wait (eps p1firecnt11 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 6_8 pri as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 6_8 pri as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1firetrack11 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 6_8 pri not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 6_8 pri accepted as expected"
endif


;hdrms_1_3, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack04
write "@PW "
write "@PW Expecting command: EPS HDRMS 1_3 REDUNDANT"
CMD EPS HDRMS_13_ARMR
wait 00:00:02
CMD EPS HDRMS_13_ENR
wait 00:00:02
CMD EPS HDRMS_13_FIRER
;wait (eps p2firecnt04 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 1_3 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 1_3 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack04 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 1_3 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 1_3 redundant accepted as expected"
endif


;hdrms_5_7, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack05
write "@PW "
write "@PW Expecting command: EPS HDRMS 5_7 REDUNDANT"
CMD EPS HDRMS_57_ARMR
wait 00:00:02
CMD EPS HDRMS_57_ENR
wait 00:00:02
CMD EPS HDRMS_57_FIRER
;wait (eps p2firecnt05 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 5_7 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 5_7 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack05 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 5_7 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 5_7 redundant accepted as expected"
endif


;hdrms_2_4, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack10
write "@PW "
write "@PW Expecting command: EPS HDRMS 2_4 REDUNDANT"
CMD EPS HDRMS_24_ARMR
wait 00:00:02
CMD EPS HDRMS_24_ENR
wait 00:00:02
CMD EPS HDRMS_24_FIRER
;wait (eps p2firecnt10 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 2_4 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 2_4 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack10 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 2_4 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 2_4 redundant accepted as expected"
endif


;hdrms_6_8, redundant
let $cmdacptd = EPS CMDACPTCNT
let $firetracker = eps p2firetrack11
write "@PW "
write "@PW Expecting command: EPS HDRMS 6_8 REDUNDANT"
CMD EPS HDRMS_68_ARMR
wait 00:00:02
CMD EPS HDRMS_68_ENR
wait 00:00:02
CMD EPS HDRMS_68_FIRER
;wait (eps p2firecnt11 > 0.0ms) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Firecounter not loaded for HDRM 6_8 redundant as expected"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Firecounter loaded for HDRM 6_8 redundant as expected"
;endif
wait (EPS CMDACPTCNT = $cmdacptd + 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2firetrack11 = $firetracker + 1000.0ms) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS HDRMS 6_8 redundant not sent"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS HDRMS 6_8 redundant accepted as expected"
endif



;;;;send bad hdrms commands

;chrgmonset and chrgmonrst

write "@PW "
write "@PW Testing EPS CHRGMONSET and EPS CHRGMONRST"

;reset charge monitors first
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONRST with bcm BCMA
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONRST with bcm BCMB
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif

;set bcm B to default to initialize correct dn readings on bcm A
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMB, state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif

;set bcm A to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMA, state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET A DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET A DEFAULT accepted as expected"
endif

;set bcm A to shunt
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMA, state SHUNT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 19.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET A SHUNT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET A SHUNT accepted as expected"
endif

;set bcm A to positive
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMA, state POS
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 1539.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET A POS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET A POS accepted as expected"
endif

;set bcm A to negative
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMA, state NEG
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 2307.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET A NEG unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET A NEG accepted as expected"
endif

;set bcm A to ground
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMA, state GND
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 1283.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET A GND unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET A GND accepted as expected"
endif

;test that chrgmonrst resets bcm but does not change batctrl
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONRST with bcm BCMA
wait ((raw eps batmona > 2147483600dn) or (raw eps batmona < -2147483600dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONRST A unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 1283.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONRST A unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONRST A accepted as expected"
endif

;clear bcm A back to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMA, state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET A DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET A DEFAULT accepted as expected"
endif

;set bcm B to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMB, state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET B DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET B DEFAULT accepted as expected"
endif

;set bcm B to shunt
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMB, state SHUNT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 4099.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET B SHUNT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET B SHUNT accepted as expected"
endif

;set bcm B to positive
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMB, state POS
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 393219.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET B POS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET B POS accepted as expected"
endif

;set bcm B to negative
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMB, state NEG
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 589827.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET B NEG unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET B NEG accepted as expected"
endif

;set bcm B to ground
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMB, state GND
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 327683.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET B GND unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET B GND accepted as expected"
endif

;test that chrgmonrst resets bcm but does not change batctrl
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONRST with bcm BCMB
wait ((raw eps batmonb > 2147483600dn) or (raw eps batmonb < -2147483600dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONRST unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 327683.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONRST B unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONRST B accepted as expected"
endif

;clear bcm B back to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONSET with bcm BCMB, state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONSET B DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONSET B DEFAULT accepted as expected"
endif

;ALIASED commands: chrgmonset and chrgmonrst

write "@PW "
write "@PW Testing ALIASED commands for EPS CHRGMONSET and EPS CHRGMONRST"

;reset charge monitors first
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_RST
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif

let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_RST
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif


;set bcm B to default to initialize correct dn readings on bcm A
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_SET with state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif

;set bcm A to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_SET with state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_SET DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONA_SET DEFAULT accepted as expected"
endif

;set bcm A to shunt
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_SET with state SHUNT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 19.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_SET SHUNT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONA_SET SHUNT accepted as expected"
endif

;set bcm A to positive
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_SET with state POS
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 1539.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_SET POS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONA_SET POS accepted as expected"
endif

;set bcm A to negative
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_SET with state NEG
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 2307.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_SET NEG unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONA_SET NEG accepted as expected"
endif

;set bcm A to ground
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_SET with state GND
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 1283.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_SET GND unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONA_SET GND accepted as expected"
endif

;test that chrgmonrst resets bcm but does not change batctrl
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_RST
wait ((raw eps batmona > 2147483600 dn) or (raw eps batmona < -2147483600 dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_RST unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 1283.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_RST unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONA_RST accepted as expected"
endif

;clear bcm A back to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONA_SET with state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONA_SET DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONA_SET DEFAULT accepted as expected"
endif

;set bcm B to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_SET with state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_SET DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONB_SET DEFAULT accepted as expected"
endif

;set bcm B to shunt
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_SET with state SHUNT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 4099.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_SET SHUNT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONB_SET SHUNT accepted as expected"
endif

;set bcm B to positive
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_SET with state POS
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 393219.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_SET POS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONB_SET POS accepted as expected"
endif

;set bcm B to negative
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_SET with state NEG
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 589827.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_SET NEG unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONB_SET NEG accepted as expected"
endif

;set bcm B to ground
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_SET with state GND
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 327683.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_SET GND unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONB_SET GND accepted as expected"
endif

;test that chrgmonrst resets bcm but does not change batctrl
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_RST
wait ((raw eps batmonb > 2147483600dn) or (raw eps batmonb < -2147483600dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_RST unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 327683.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_RST unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONB_RST accepted as expected"
endif

;clear bcm B back to default
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CHRGMONB_SET with state DEFAULT
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CHRGMONB_SET DEFAULT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CHRGMONB_SET DEFAULT accepted as expected"
endif


;; bad chrgmonset and chrgmonrst commands?

;battchrgtgt

write "@PW "
write "@PW Testing EPS BATTCHRGTGT"


let $cmdacptd = EPS CMDACPTCNT
CMD EPS BATTCHRGTGT with target HIGH
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif

wait 00:00:05


let $target_tlm = eps hwctrl





;set BATTCHRGTGT with target LOW (82%)
let $cmdacptd = EPS CMDACPTCNT
CMD EPS BATTCHRGTGT with target LOW
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps hwctrl = $target_tlm + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS BATTCHRGTGT with target LOW unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS BATTCHRGTGT with target LOW accepted as expected"
endif

wait 00:00:05

let $target_tlm = eps hwctrl


;set BATTCHRGTGT with target HIGH (100%)
let $cmdacptd = EPS CMDACPTCNT
CMD EPS BATTCHRGTGT with target HIGH
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps hwctrl = $target_tlm - 1.0dn) or for $tm_wait
if $$error = time_out
    write "@;PW <R>Failed: Command EPS BATTCHRGTGT with target HIGH unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS BATTCHRGTGT with target HIGH accepted as expected"
endif

;; bad battchrgtgt commands? 

wait 00:00:05

;ALIASED commands batchrghi and batchrglo

let $cmdacptd = EPS CMDACPTCNT
CMD EPS BATCHRGHI
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif


wait 00:00:05


let $target_tlm = eps hwctrl

;set BATCHRGLO (82%)
let $cmdacptd = EPS CMDACPTCNT
CMD EPS BATCHRGLO
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps hwctrl = $target_tlm + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS BATCHRGLO unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS BATCHRGLO accepted as expected"
endif


wait 00:00:05


let $target_tlm = eps hwctrl



;set BATCHRGHI (100%)
let $cmdacptd = EPS CMDACPTCNT
CMD EPS BATCHRGHI
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps hwctrl = $target_tlm - 1.0dn) or for $tm_wait
if $$error = time_out
    write "@;PW <R>Failed: Command EPS BATCHRGHI unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS BATCHRGHI accepted as expected"
endif



;ccinit

write "@PW "
write "@PW Testing EPS CCINIT"

write "@PW "
write "@PW Expecting command: EPS CCINIT with INITTYPE CC2HM"
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CCINIT with INITTYPE CC2HM
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (((raw eps pwmctrl = x#8200 dn) or (raw eps pwmctrl = x#18200 dn)) and ((raw eps bpctrla = x#0060 dn) or (raw eps bpctrla = x#10060 dn)) and ((raw eps bpctrlb = x#FDD8 dn) or (raw eps bpctrlb = x#1FDD8 dn))) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CCINIT with INITTYPE CC2HM not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CCINIT with INITTYPE CC2HM accepted as expected"
endif

write "@PW "
write "@PW Expecting command: EPS CCINIT with INITTYPE CC1HM"
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CCINIT with INITTYPE CC1HM
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (((raw eps pwmctrl = x#8180 dn) or (raw eps pwmctrl = x#18180 dn)) and ((raw eps bpctrla = x#FEE0 dn) or (raw eps bpctrla = x#1FEE0 dn)) and ((raw eps bpctrlb = x#40 dn) or (raw eps bpctrlb = x#10040 dn))) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CCINIT with INITTYPE CC1HM not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CCINIT with INITTYPE CC1HM accepted as expected"
endif

write "@PW "
write "@PW Expecting command: EPS CCINIT with INITTYPE CC2FM"
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CCINIT with INITTYPE CC2FM
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (((raw eps pwmctrl = x#7DA0 dn) or (raw eps pwmctrl = x#17DA0 dn)) and ((raw eps bpctrla = x#FDA0 dn) or (raw eps bpctrla = x#1FDA0 dn)) and ((raw eps bpctrlb = x#EFA0 dn) or (raw eps bpctrlb = x#1EFA0 dn))) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CCINIT with INITTYPE CC2FM not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CCINIT with INITTYPE CC2FM accepted as expected"
endif

write "@PW "
write "@PW Expecting command: EPS CCINIT with INITTYPE CC1FM"
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CCINIT with INITTYPE CC1FM
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (((raw eps pwmctrl = x#7C80 dn) or (raw eps pwmctrl = x#17C80 dn)) and ((raw eps bpctrla = x#FD60 dn) or (raw eps bpctrla = x#1FD60 dn)) and ((raw eps bpctrlb = x#FDB0 dn) or (raw eps bpctrlb = x#1FDB0 dn))) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CCINIT with INITTYPE CC1FM not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CCINIT with INITTYPE CC1FM accepted as expected"
endif

write "@PW "
write "@PW Expecting command: EPS CCINIT with INITTYPE CC2EM"
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CCINIT with INITTYPE CC2EM
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (((raw eps pwmctrl = x#8300 dn) or (raw eps pwmctrl = x#18300 dn)) and ((raw eps bpctrla = x#FCC0 dn) or (raw eps bpctrla = x#1FCC0 dn)) and ((raw eps bpctrlb = x#FEC0 dn) or (raw eps bpctrlb = x#1FEC0 dn))) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CCINIT with INITTYPE CC2EM not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CCINIT with INITTYPE CC2EM accepted as expected"
endif

write "@PW "
write "@PW Expecting command: EPS CCINIT with INITTYPE CC1EM"
write "@PW <Y>Setting to correct configuration for FlatSat"
let $cmdacptd = EPS CMDACPTCNT
CMD EPS CCINIT with INITTYPE CC1EM
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (((raw eps pwmctrl = x#80B0 dn) or (raw eps pwmctrl = x#180B0 dn)) and ((raw eps bpctrla = x#FDA0 dn) or (raw eps bpctrla = x#1FDA0 dn)) and ((raw eps bpctrlb = x#FE50 dn) or (raw eps bpctrlb = x#1FE50 dn))) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CCINIT with INITTYPE CC1EM not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command EPS CCINIT with INITTYPE CC1EM accepted as expected"
endif



;eps peek and poke

write "@PW "
write "@PW Testing Peek & Poke"


;CC
write "@PW "
write "@PW Testing Controller Card..."

write "@PW "
write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message"
write "@PW <Y>'CC register 0x3018 has value ???????'"
write "@PW Type 'GO' to send PEEK command"
wait;GO to continue
let $cmdacptd = EPS CMDACPTCNT
CMD EPS PEEK with CARDID 16, MASK 990995, REGISTERADDRESS 12312
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
ask $answer "Did the event message display correctly? (y,n)"
if $answer = y
	write "@PW "
	write "@PW <G>Event message displayed correctly"
else
	write "@PW <R>Event message not displayed correctly"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $cmdacptd = EPS CMDACPTCNT
let $pre_poke_eu = eps batctrl
let $pre_poke_real = $pre_poke_eu
let $pre_poke_int = $pre_poke_real

write "@PW "
write "@PW <Y>Need to poke to three before poking to anything else on CC"
CMD EPS POKE with CARDID 16, MASK 990995, VALUE 3, REGISTERADDRESS 12312
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to CC was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "	
	write "@PW <G>Poke to CC successful"
endif

let $cmdacptd = EPS CMDACPTCNT

if ($pre_poke_eu = 393235.0dn)
	CMD EPS POKE with CARDID 16, MASK 990995, VALUE 6403, REGISTERADDRESS 12312
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps batctrl = 6403.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to CC was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Poke to CC successful"
	endif
else
	CMD EPS POKE with CARDID 16, MASK 990995, VALUE 393235, REGISTERADDRESS 12312
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps batctrl = 393235.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to CC was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to CC successful"
	endif
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Poking to three before poke back to original value"

CMD EPS POKE with CARDID 16, MASK 990995, VALUE 3, REGISTERADDRESS 12312
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = 3.0dn) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to CC was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to CC successful"
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Sending poke command to send value back to original value"

CMD EPS POKE with CARDID 16, MASK 990995, VALUE $pre_poke_int, REGISTERADDRESS 12312
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps batctrl = $pre_poke_eu) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to CC was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to CC successful"
endif

;SC1
write "@PW "
write "@PW Testing Switch Card 1..."

write "@PW "
write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message"
write "@PW <Y>'SC1 register 0x0040 has value ???????'"
write "@PW Type 'GO' to send PEEK command"
wait;GO to continue
let $cmdacptd = EPS CMDACPTCNT
CMD EPS PEEK with CARDID 83, MASK 8388607, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
ask $answer "Did the event message display correctly? (y,n)"
if $answer = y
	write "@PW "
	write "@PW <G>Event message displayed correctly"
else
	write "@PW <R>Event message not displayed correctly"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $cmdacptd = EPS CMDACPTCNT
let $pre_poke_eu = eps s1adcctrl
let $pre_poke_real = $pre_poke_eu
let $pre_poke_int = $pre_poke_real
if ($pre_poke_eu = 7895040.0dn)
	
	CMD EPS POKE with CARDID 83, MASK 8388607, VALUE 491583, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s1adcctrl = 491583.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC1 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC1 successful"
	endif
else
	
	CMD EPS POKE with CARDID 83, MASK 8388607, VALUE 7895040, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s1adcctrl = 7895040.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC1 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC1 successful"
	endif
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Sending poke command to send value back to original value"

CMD EPS POKE with CARDID 83, MASK 8388607, VALUE $pre_poke_int, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps s1adcctrl = $pre_poke_eu) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to SC1 was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to SC1 successful"
endif


;SC2
write "@PW "
write "@PW Testing Switch Card 2..."

write "@PW "
write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message"
write "@PW <Y>'SC2 register 0x0040 has value ???????'"
write "@PW Type 'GO' to send PEEK command"
wait;GO to continue
let $cmdacptd = EPS CMDACPTCNT
CMD EPS PEEK with CARDID 84, MASK 8388607, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
ask $answer "Did the event message display correctly? (y,n)"
if $answer = y
	write "@PW "
	write "@PW <G>Event message displayed correctly"
else
	write "@PW <R>Event message not displayed correctly"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $cmdacptd = EPS CMDACPTCNT
let $pre_poke_eu = eps s2adcctrl
let $pre_poke_real = $pre_poke_eu
let $pre_poke_int = $pre_poke_real
if ($pre_poke_eu = 7895040.0dn)
	
	CMD EPS POKE with CARDID 84, MASK 8388607, VALUE 491583, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s2adcctrl = 491583.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC2 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC2 successful"
	endif
else
	
	CMD EPS POKE with CARDID 84, MASK 8388607, VALUE 7895040, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s2adcctrl = 7895040.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC2 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC2 successful"
	endif
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Sending poke command to send value back to original value"

CMD EPS POKE with CARDID 84, MASK 8388607, VALUE $pre_poke_int, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps s2adcctrl = $pre_poke_eu) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to SC2 was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to SC2 successful"
endif


;SC3
write "@PW "
write "@PW Testing Switch Card 3..."

write "@PW "
write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message"
write "@PW <Y>'SC3 register 0x0040 has value ???????'"
write "@PW Type 'GO' to send PEEK command"
wait;GO to continue
let $cmdacptd = EPS CMDACPTCNT
CMD EPS PEEK with CARDID 85, MASK 8388607, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
ask $answer "Did the event message display correctly? (y,n)"
if $answer = y
	write "@PW "
	write "@PW <G>Event message displayed correctly"
else
	write "@PW <R>Event message not displayed correctly"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $cmdacptd = EPS CMDACPTCNT
let $pre_poke_eu = eps s3adcctrl
let $pre_poke_real = $pre_poke_eu
let $pre_poke_int = $pre_poke_real
if ($pre_poke_eu = 7895040.0dn)
	
	CMD EPS POKE with CARDID 85, MASK 8388607, VALUE 491583, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s3adcctrl = 491583.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC3 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC3 successful"
	endif
else
	
	CMD EPS POKE with CARDID 85, MASK 8388607, VALUE 7895040, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s3adcctrl = 7895040.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC3 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC3 successful"
	endif
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Sending poke command to send value back to original value"

CMD EPS POKE with CARDID 85, MASK 8388607, VALUE $pre_poke_int, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps s3adcctrl = $pre_poke_eu) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to SC3 was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to SC3 successful"
endif


;SC4
write "@PW "
write "@PW Testing Switch Card 4..."

write "@PW "
write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message"
write "@PW <Y>'SC4 register 0x0040 has value ???????'"
write "@PW Type 'GO' to send PEEK command"
wait;GO to continue
let $cmdacptd = EPS CMDACPTCNT
CMD EPS PEEK with CARDID 86, MASK 8388607, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
ask $answer "Did the event message display correctly? (y,n)"
if $answer = y
	write "@PW "
	write "@PW <G>Event message displayed correctly"
else
	write "@PW <R>Event message not displayed correctly"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $cmdacptd = EPS CMDACPTCNT
let $pre_poke_eu = eps s4adcctrl
let $pre_poke_real = $pre_poke_eu
let $pre_poke_int = $pre_poke_real
if ($pre_poke_eu = 7895040.0dn)
	
	CMD EPS POKE with CARDID 86, MASK 8388607, VALUE 491583, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s4adcctrl = 491583.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC4 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC4 successful"
	endif
else
	
	CMD EPS POKE with CARDID 86, MASK 8388607, VALUE 7895040, REGISTERADDRESS 64
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps s4adcctrl = 7895040.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to SC4 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to SC4 successful"
	endif
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Sending poke command to send value back to original value"

CMD EPS POKE with CARDID 86, MASK 8388607, VALUE $pre_poke_int, REGISTERADDRESS 64
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps s4adcctrl = $pre_poke_eu) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to SC4 was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to SC4 successful"
endif


;PC1
write "@PW "
write "@PW Testing Prop Card 1..."

write "@PW "
write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message"
write "@PW <Y>'PRC1 register 0x0038 has value ???????'"
write "@PW Type 'GO' to send PEEK command"
wait;GO to continue
let $cmdacptd = EPS CMDACPTCNT
CMD EPS PEEK with CARDID 48, MASK x#FFFFFFFF, REGISTERADDRESS 56
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
ask $answer "Did the event message display correctly? (y,n)"
if $answer = y
	write "@PW "
	write "@PW <G>Event message displayed correctly"
else
	write "@PW <R>Event message not displayed correctly"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $cmdacptd = EPS CMDACPTCNT
let $pre_poke_eu = eps p1adcctrl
let $pre_poke_real = $pre_poke_eu
let $pre_poke_int = $pre_poke_real
if ($pre_poke_eu = 252641280.0dn)
	
	CMD EPS POKE with CARDID 48, MASK x#FFFFFFFF, VALUE 15728759, REGISTERADDRESS 56
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1adcctrl = 15728759.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to PC1 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to PC1 successful"
	endif
else
	
	CMD EPS POKE with CARDID 48, MASK x#FFFFFFFF, VALUE 252641280, REGISTERADDRESS 56
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p1adcctrl = 252641280.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to PC1 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to PC1 successful"
	endif
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Sending poke command to send value back to original value"

CMD EPS POKE with CARDID 48, MASK x#FFFFFFFF, VALUE $pre_poke_int, REGISTERADDRESS 56
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p1adcctrl = $pre_poke_eu) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to PC1 was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to PC1 successful"
endif


;PC2
write "@PW "
write "@PW Testing Prop Card 2..."

write "@PW "
write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message"
write "@PW <Y>'PRC2 register 0x0038 has value ???????'"
write "@PW Type 'GO' to send PEEK command"
wait;GO to continue
let $cmdacptd = EPS CMDACPTCNT
CMD EPS PEEK with CARDID 49, MASK x#FFFFFFFF, REGISTERADDRESS 56
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
ask $answer "Did the event message display correctly? (y,n)"
if $answer = y
	write "@PW "
	write "@PW <G>Event message displayed correctly"
else
	write "@PW <R>Event message not displayed correctly"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $cmdacptd = EPS CMDACPTCNT
let $pre_poke_eu = eps p2adcctrl
let $pre_poke_real = $pre_poke_eu
let $pre_poke_int = $pre_poke_real
if ($pre_poke_eu = 252641280.0dn)
	
	CMD EPS POKE with CARDID 49, MASK x#FFFFFFFF, VALUE 15728759, REGISTERADDRESS 56
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2adcctrl = 15728759.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to PC2 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to PC2 successful"
	endif
else
	
	CMD EPS POKE with CARDID 49, MASK x#FFFFFFFF, VALUE 252641280, REGISTERADDRESS 56
	wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command counter unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'
	else
		write "@PW "
		write "@PW <G>Command counter successful"
	endif
	wait (eps p2adcctrl = 252641280.0dn) or for $lng_wait
	if $$error = time_out
		write "@PW <R>Poke to PC2 was unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;wait for documentation, then type 'GO'	
	else
		write "@PW "
		write "@PW <G>Poke to PC2 successful"
	endif
endif

let $cmdacptd = EPS CMDACPTCNT
write "@PW "
write "@PW Sending poke command to send value back to original value"

CMD EPS POKE with CARDID 49, MASK x#FFFFFFFF, VALUE $pre_poke_int, REGISTERADDRESS 56
wait (EPS CMDACPTCNT = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command counter unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command counter successful"
endif
wait (eps p2adcctrl = $pre_poke_eu) or for $lng_wait
if $$error = time_out
	write "@PW <R>Poke to PC2 was unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'	
else
	write "@PW "	
	write "@PW <G>Poke to PC2 successful"
endif


;req_peakhold

let $cmdacptd = EPS CMDACPTCNT
let $srcseqcnt = PKT_APID_0641 SRC_SEQ_CTR
CMD EPS REQ_PEAKHOLD
wait ((PKT_APID_0641 SRC_SEQ_CTR = $srcseqcnt + 1.0dn) and (EPS CMDACPTCNT = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command REQ_PEAKHOLD unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command REQ_PEAKHOLD successful"
endif

;req_hdrmhr

let $cmdacptd = EPS CMDACPTCNT
let $srcseqcnt = PKT_APID_0649 SRC_SEQ_CTR
CMD EPS REQ_HDRMHR
wait ((PKT_APID_0649 SRC_SEQ_CTR = $srcseqcnt + 1.0dn) and (EPS CMDACPTCNT = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command REQ_HDRMHR unsuccessful"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command REQ_HDRMHR successful"
endif




;
;write "@PW "
;write "@PW Now testing Controller Card..."
;
;
;;cardid 0x10, register 0x3018
;CMD EPS POKE with CARDID 16, MASK 990995, VALUE 4115, REGISTERADDRESS 12312
;wait (eps batctrl = 4115.0dn) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Poke was unsuccessful"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;	wait;GO to continue
;else
;	write "@PW "
;	write "@PW <G>Command accepted as expected"
;endif
;
;write "@PW "
;write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message:"
;write "@PW 'CC register 0x3018 has value 0x00001013'"
;write "@PW Type 'GO' to send PEEK command"
;wait;GO to continue
;CMD EPS PEEK with CARDID 16, MASK 990995, REGISTERADDRESS 12312
;write "@PW "
;write "@PW Type 'GO' to acknowledge message receipt and continue"
;wait;GO to continue
;write "@PW <G>Command accepted as expected"
;
;write "@PW "
;write "@PW Now testing Switch Cards..."
;write "@PW SC1: Card ID 0x53, 83"
;write "@PW SC2: Card ID 0x54, 84"
;write "@PW SC3: Card ID 0x55, 85"
;write "@PW SC4: Card ID 0x56, 86"


;;cardid 0x53, register 0x0024
;CMD EPS POKE with CARDID 83, MASK 2130706431, VALUE 2130706431, REGISTERADDRESS 36
;wait (eps s1swctrlsc = 2130706431.0dn) or for $lng_wait
;if $$error = time_out
;    write "@PW <R>Poke was unsuccessful"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;	wait;GO to continue
;else
;	write "@PW "
;	write "@PW <G>Command accepted as expected"
;endif
;
;write "@PW "
;write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message:"
;write "@PW 'SC1 register 0x0024 has value 0x7effffff'"
;write "@PW Type 'GO' to send PEEK command"
;wait;GO to continue
;CMD EPS PEEK with CARDID 83, MASK 2130706431, REGISTERADDRESS 36
;write "@PW "
;write "@PW Type 'GO' to acknowledge message receipt and continue"
;wait;GO to continue
;write "@PW <G>Command accepted as expected"



;cardid 0x54, register 0x0024
;CMD EPS POKE with CARDID 84, MASK 2130706431, VALUE 2130706431, REGISTERADDRESS 36
;wait (eps s2swctrlsc = 2130706431.0dn) or for $lng_wait
;if $$error = time_out
;    write "@PW <R>Poke was unsuccessful"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;	wait;GO to continue
;else
;	write "@PW "
;	write "@PW <G>Command accepted as expected"
;endif
;
;write "@PW "
;write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message:"
;write "@PW 'SC2 register 0x0024 has value 0x7effffff'"
;write "@PW Type 'GO' to send PEEK command"
;wait;GO to continue
;CMD EPS PEEK with CARDID 84, MASK 2130706431, REGISTERADDRESS 36
;write "@PW "
;write "@PW Type 'GO' to acknowledge message receipt and continue"
;wait;GO to continue
;write "@PW <G>Command accepted as expected"



;cardid 0x;55, register 0x0024
;CMD EPS POKE with CARDID 85, MASK 2130706431, VALUE 2130706431, REGISTERADDRESS 36
;wait (eps s3swctrlsc = 2130706431.0dn) or for $lng_wait
;if $$error = time_out
;    write "@PW <R>Poke was unsuccessful"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;	wait;GO to continue
;else
;	write "@PW "
;	write "@PW <G>Command accepted as expected"
;endif
;
;write "@PW "
;write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message:"
;write "@PW 'SC3 register 0x0024 has value 0x7effffff'"
;write "@PW Type 'GO' to send PEEK command"
;wait;GO to continue
;CMD EPS PEEK with CARDID 85, MASK 2130706431, REGISTERADDRESS 36
;write "@PW "
;write "@PW Type 'GO' to acknowledge message receipt and continue"
;wait;GO to continue
;write "@PW <G>Command accepted as expected"



;;cardid 0x56, register 0x0044
;CMD EPS POKE with CARDID 86, MASK 3238002687, VALUE 3238002687, REGISTERADDRESS 0x0044
;wait (eps s4syncctrlsc = 3238002687.0dn) or for $lng_wait
;if $$error = time_out
;    write "@PW <R>Poke was unsuccessful"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;endif
;
;write "@PW "
;write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message:"
;write "@PW 'SC4 register 0x0044 has value 0xc0ffffff'"
;write "@PW Type 'GO' to send PEEK command"
;wait;GO to continue
;CMD EPS PEEK with CARDID 86, MASK 3238002687, REGISTERADDRESS 0x0044
;write "@PW "
;write "@PW Type 'GO' to acknowledge message receipt and continue"
;wait;GO to continue



;write "@PW "
;write "@PW Now testing Prop Cards..."
;write "@PW PC1: Card ID 0x30, 48"
;write "@PW PC2: Card ID 0x31, 49"

;cardid 0x30, register 0x000C
;CMD EPS POKE with CARDID 48, MASK 16777215, VALUE 255, REGISTERADDRESS 12
;wait (eps p1testmuxpc = 255.0dn) or for $lng_wait
;if $$error = time_out
;    write "@PW <R>Poke was unsuccessful"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;	wait;GO to continue
;else
;	write "@PW "
;	write "@PW <G>Command accepted as expected"
;endif
;
;write "@PW "
;write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message:"
;write "@PW 'PRC1 register 0x000c has value 0x000000ff'"
;write "@PW Type 'GO' to send PEEK command"
;wait;GO to continue
;CMD EPS PEEK with CARDID 48, MASK 16777215, REGISTERADDRESS 12
;write "@PW "
;write "@PW Type 'GO' to acknowledge message receipt and continue"
;wait;GO to continue
;write "@PW <G>Command accepted as expected"
;
;
;
;;cardid 0x31, register 0x000C
;CMD EPS POKE with CARDID 49, MASK 16777215, VALUE 255, REGISTERADDRESS 12
;wait (eps p2testmuxpc = 255.0dn) or for $lng_wait
;if $$error = time_out
;    write "@PW <R>Poke was unsuccessful"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;	wait;GO to continue
;else
;	write "@PW "
;	write "@PW <G>Command accepted as expected"
;endif
;
;write "@PW "
;write "@PW Check SC_FSW_0008 packet (evsmsgstr) for Peek message:"
;write "@PW 'PRC2 register 0x000c has value 0x000000ff'"
;write "@PW Type 'GO' to send PEEK command"
;wait;GO to continue
;CMD EPS PEEK with CARDID 49, MASK 16777215, REGISTERADDRESS 12
;write "@PW "
;write "@PW Type 'GO' to acknowledge message receipt and continue"
;wait;GO to continue
;write "@PW <G>Command accepted as expected"




;write "@PW "
;write "@PW Type 'GO' to test failing commands"
;wait; GO to test failing commands
;
;write "@PW "
;write "@PW Testing failing HDRM commands"
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error"
;CMD EPS HDRMS with HDRMS hdrms13, TYPE pri
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
;write "@PW Type 'GO' through expected error"
;CMD EPS HDRMS with HDRMS hdrms_1_3, TYPE 2
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
;write "@PW Testing failing CHRGMONSET and CHRGMONRST commands"
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error"
;CMD EPS CHRGMONSET with bcm BCM, state DEFAULT
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
;write "@PW Type 'GO' through expected error"
;CMD EPS CHRGMONSET with bcm BCMA, state 5
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
;write "@PW Type 'GO' through expected error"
;CMD EPS CHRGMONRST with bcm BCM
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
;write "@PW Testing failing battchrgtgt commands"
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error"
;CMD EPS BATTCHRGTGT with TARGET 2
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
;write "@PW Testing failing poke and peek commands"
;
;write "@PW "
;write "@PW Expecting command to fail"
;write "@PW Type 'GO' through expected error"
;CMD EPS POKE with CARDID 16, MASK 990995, VALUE 4115, REGISTERADDRESS 12312123
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
;write "@PW Type 'GO' through expected error"
;CMD EPS PEEK with CARDID 16, MASK 990995, VALUE 4115, REGISTERADDRESS 12312
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

if eps cmdrjctcnt > 0.0dn
    write "@PW <R>Failed: There were rejected commands during this test"
    write "@PW <R>Number of rejected commands:", eps cmdrjctcnt
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>No commands rejected during this test"
endif

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

endproc; eps

