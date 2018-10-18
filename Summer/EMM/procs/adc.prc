proc adc
;*** $Revision: 1.7 $
;*** $Date: 2018/09/09 18:35:36 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/adc.prc,v $
;*
;* Created by: EMM Operations Account
;* Creation Date: 10/19/2017
;*
;*  FUNCTION: Tests commands in ADC app
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Tests adcnoop, adc cntreset, DPU Select, ADC Power, needs RWTRQ cmds
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

write "@PW Starting procedure $RCSfile: adc.prc,v $"
write "@PW $Revision: 1.7 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:15
DECLARE VARIABLE $shortwait = 00:00:03
DECLARE VARIABLE $longwait = 00:00:10
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $plsacptd = 0.0dn
DECLARE VARIABLE $plsrjctd = 0.0dn
DECLARE VARIABLE $answer = y y,n
DECLARE VARIABLE $lastvtc_eu = 0.0dn
DECLARE VARIABLE $lastvtc_real = 0.0
DECLARE VARIABLE $lastvtc_int = 0

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

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt

wait; time to open panels if you haven't already
   write "@PW <Y>Open APID panels 704 and 705 before proceeding"
   Write "@PW <Y>Then type 'GO' to continue"

;think about incrementing $cmdacptd for count reset
CMD ADC CNTRESET
write "@PW "
write "@PW Expecting command: ADC CNTRESET"
wait ((ADC CMDACPTCNT = 0.0dn) and (ADC CMDRJCTCNT = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC CNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


NOOP:

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC NOOP
write "@PW "
write "@PW Expecting command accept: ADC NOOP"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


;CNTRESET
;same here - increment $cmdacptd
CMD ADC CNTRESET
write "@PW "
write "@PW Expecting command: ADC CNTRESET"
wait ((ADC CMDACPTCNT = 0.0dn) and (ADC CMDRJCTCNT = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC CNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




DPUSELECT:


;adc dpuselect DPU1
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUPRIME with SIDE DPU1
write "@PW "
write "@PW Expecting command: select DPU1"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = OFF)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPU Select DPU1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPU Select DPU1 accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUNOOP with SIDE DPU1
write "@PW "
write "@PW Expecting command accept: ADC DPUNOOP"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



;adc dpuselect DPU2
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUPRIME with SIDE DPU2
write "@PW "
write "@PW Expecting command: select DPU2"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = ON)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPU Select DPU2 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPU Select DPU2 accepted as expected"
endif


Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUNOOP with SIDE DPU2
write "@PW "
write "@PW Expecting command accept: ADC DPUNOOP"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif



Wait $shortwait


;need more info on how this command works
;adc dpuselect DPU_FAIL
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUPRIME with SIDE DPU_FAIL
write "@PW "
write "@PW Expecting command: select DPU FAIL"
wait ((ADC CMDACPTCNT = $cmdacptd + 0.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 1.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = ON)) or for $tm_wait
;reject counter = 2
if $$error = time_out
    write "@PW <R>Failed: Command DPU Select DPU FAIL unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPU Select DPU FAIL accepted as expected"
endif


Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUNOOP with SIDE DPU_FAIL
write "@PW "
write "@PW Expecting command accept: ADC DPUNOOP"
wait ((ADC CMDACPTCNT = $cmdacptd + 0.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject = 1
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif



Wait $shortwait


;testing power commands for DPU1
;adc dpuselect DPU1
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUPRIME with SIDE DPU1
write "@PW "
write "@PW Expecting command: select DPU1"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = ON)) or for $tm_wait; is this true?
if $$error = time_out
    write "@PW <R>Failed: Command DPU Select DPU1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPU Select DPU1 accepted as expected"
endif

Wait $shortwait


;adc dpusecpwr ADC_OFF
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU_SECPW with STATE ADC_OFF
write "@PW "
write "@PW Expecting command: select DPUSECPWR ADC OFF"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = OFF)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPUSECPWR ADC_OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPUSECPWR ADC_OFF accepted as expected"
endif


Wait $shortwait



;adc dpusecpwr ADC_ON
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU_SECPW with STATE ADC_ON
write "@PW "
write "@PW Expecting command: select DPUSECPWR ADC ON"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = ON)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPUSECPWR ADC_ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPUSECPWR ADC ON accepted as expected"
endif

Wait $shortwait



;adc dpusecpwr ADC_FAIL
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU_SECPW with STATE ADC_PWR_FAIL
write "@PW "
write "@PW Expecting command: select DPUSECPWR ADC PWR FAIL"
wait ((ADC CMDACPTCNT = $cmdacptd + 0.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 1.0dn) and (adc dpu2_switch_st = ON) and (adc dpu1_switch_st = ON)) or for $tm_wait
;reject counter = 3
if $$error = time_out
    write "@PW <R>Failed: Command DPUSECPWR ADC PWR FAIL unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPUSECPWR ADC PWR FAIL accepted as expected"
endif


Wait $shortwait



;testing power commands for DPU2
;adc dpuselect DPU2
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUPRIME with SIDE DPU2
write "@PW "
write "@PW Expecting command: select DPU2"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = ON)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPU Select DPU2 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPU Select DPU2 accepted as expected"
endif


Wait $shortwait



;adc dpusecpwr ADC_OFF
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU_SECPW with STATE ADC_OFF
write "@PW "
write "@PW Expecting command: select DPUSECPWR ADC OFF"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = OFF) and (adc dpu2_switch_st = ON)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPUSECPWR ADC_OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPUSECPWR ADC_OFF accepted as expected"
endif


Wait $shortwait



;adc dpusecpwr ADC_ON
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU_SECPW with STATE ADC_ON
write "@PW "
write "@PW Expecting command: select DPUSECPWR ADC ON"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = ON)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPUSECPWR ADC_ON unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPUSECPWR ADC ON accepted as expected"
endif


Wait $shortwait



;adc dpusecpwr ADC_FAIL
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU_SECPW with STATE ADC_PWR_FAIL
write "@PW "
write "@PW Expecting command: select DPUSECPWR ADC PWR FAIL"
wait ((ADC CMDACPTCNT = $cmdacptd + 0.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 1.0dn) and (adc dpu1_switch_st = ON) and (adc dpu2_switch_st = ON)) or for $tm_wait
;reject counter = 4
if $$error = time_out
    write "@PW <R>Failed: Command DPUSECPWR ADC PWR FAIL unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPUSECPWR ADC PWR FAIL accepted as expected"
endif

Wait $shortwait


;adc dpusecpwr ADC_OFF - this should power off DPU1
;leaving the DPU in a safe config when only one is present
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU_SECPW with STATE ADC_OFF
write "@PW "
write "@PW Expecting command: select DPUSECPWR ADC OFF"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc dpu1_switch_st = OFF) and (adc dpu2_switch_st = ON)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DPUSECPWR ADC_OFF unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command DPUSECPWR ADC_OFF accepted as expected"
endif


Wait $shortwait





PRPSYS:

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPSYS with ARMENABLE ARM, STATE ADC_ON
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPSYS"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPARMST = ARMED)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPSYS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPSYS accepted as expected"
endif
Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPSYS with ARMENABLE EN, STATE ADC_ON
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPSYS"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPENST = EN)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPSYS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPSYS accepted as expected"
endif
Wait $shortwait


STATES:

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT SAFE_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait (ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = SAFE_STATE) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT MONITOR_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = MONITOR_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT DESAT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = DESAT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT EARTH_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = EARTH_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT IDLE_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = IDLE_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else

	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT INERTL_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = INERTL_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT MARS_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = MARS_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT STANDBY_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = STANDBY_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT SUN_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = SUN_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




RWPW:

;Reaction Wheel Testing
let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW1, STATE ADC_ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn) and (adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
   write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW1, STATE ADC_OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn) and (adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW1, STATE ADC_PWR_FAIL
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 0.0dn) and (adc cmdrjctcnt = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject counter = 5
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW2, STATE ADC_ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW2, STATE ADC_OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW2, STATE ADC_PWR_FAIL
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 0.0dn) and (adc cmdrjctcnt = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject counter = 6
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW3, STATE ADC_ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



;Make all the other RW commands like this one, esp success
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
CMD ADC RWPW with WHEEL RW3, STATE ADC_OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


;Make all the other RW commands like this one, esp Fail
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
CMD ADC RWPW with WHEEL RW3, STATE ADC_PWR_FAIL
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 0.0dn) and (adc cmdrjctcnt = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject counter = 7
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW4, STATE ADC_ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW4, STATE ADC_OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW4, STATE ADC_PWR_FAIL
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 0.0dn) and (adc cmdrjctcnt = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject counter = 8
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW_FAIL, STATE ADC_ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 0.0dn) and (adc cmdrjctcnt = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject counter = 9
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW_FAIL, STATE ADC_OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 0.0dn) and (adc cmdrjctcnt = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject counter = 10
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWPW with WHEEL RW_FAIL, STATE ADC_PWR_FAIL
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 0.0dn) and (adc cmdrjctcnt = $cmdrjctd + 1.0dn)) or for $tm_wait
;reject counter = 11
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




RWSERVICE:

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 0, MASK 3, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait (adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 0, MASK 12, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 0, MASK 15, STATE 0
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 1, MASK 3, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 1, MASK 12, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 1, MASK 15, STATE 0
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 2, MASK 3, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 2, MASK 12, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 2, MASK 15, STATE 0
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 3, MASK 3, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 3, MASK 12, STATE 1
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RWSERVICE with WHEEL 3, MASK 15, STATE 0
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 0.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn) and (adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



ALIASES:

ALIASDPU:

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUSECON
write "@PW "
write "@PW Expecting command accept: ADC DPUSECON"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;Should be DPU1 power on
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUSECON not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU1NOOP
write "@PW "
write "@PW Expecting command accept: ADC DPUNOOP"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU2NOOP
write "@PW "
write "@PW Expecting command accept: ADC DPUNOOP"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU1PRIME
write "@PW "
write "@PW Expecting command accept: ADC DPU1PRIME"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPU1PRIME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU2PRIME
write "@PW "
write "@PW Expecting command accept: ADC DPU2PRIME"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPU2PRIME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUSECOFF
write "@PW "
write "@PW Expecting command accept: ADC DPUSECOFF"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait

;should be DPU1 power off, leaving flatsat in safe config
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUSECOFF not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




ALIASRW:


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW1ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW1OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW2ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW2OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW3ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW3OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW4ON
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW4OFF
write "@PW "
write "@PW Expecting command accept: ADC RWPW"
wait ((adc rw_pls_acpt_cnt = $plsacptd + 2.0dn) and (adc rw_pls_rjct_cnt = $plsrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWPW not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW1SERVON_P
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW1SERVON_R
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW1SERVOFF
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW2SERVON_P
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW2SERVON_R
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW2SERVOFF
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW3SERVON_P
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW3SERVON_R
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW3SERVOFF
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW4SERVON_P
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW4SERVON_R
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $plsacptd = adc rw_pls_acpt_cnt
let $plsrjctd = adc rw_pls_rjct_cnt
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC RW4SERVOFF
write "@PW "
write "@PW Expecting command accept: ADC RWSERVICE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;what other TLM points if any?
if $$error = time_out
    write "@PW <R>Failed: Command ADC RWSERVICE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




ALIASSTATES:

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC SAFE_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait (ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = SAFE_STATE) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC MONITOR_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = MONITOR_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC IDLE_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = IDLE_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else

	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STANDBY_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = STANDBY_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DESAT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = DESAT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC SUN_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = SUN_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC INERTL_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = INERTL_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC EARTH_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = EARTH_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC MARS_PT_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = MARS_PT_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




NOWTESTED:



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC STATE with SELECT DV_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = DV_STATE)) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC MONITOR_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = MONITOR_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

wait $longwait; this is what crashed FSW last time.

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
let $lastvtc_eu = ADC LASTVTC0 + 5.0dn
let $lastvtc_real = $lastvtc_eu
let $lastvtc_int = $lastvtc_real
CMD ADC DVCFG with DVCMDX 0.0, DVCMDY 0.0, DVCMDZ 10.0, DVROTVECX 0.0, DVROTVECY 0.0, DVROTVECZ 0.0, BURNMINTIME 5.0, BURNMAXTIME 55.0, BURNTIMESEC $lastvtc_int , BURNTIMEFRACSEC 0.0
write "@PW "
write "@PW Expecting command accept: ADC DVCFG"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command ADC DVCFG not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $longwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DV_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = DV_STATE)) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC MONITOR_STATE
write "@PW "
write "@PW Expecting command accept: ADC STATE"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (adc state = MONITOR_STATE)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


Wait $shortwait

;test_rwtrq, test_rcson, and test_dvon all require monitor or idle state

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC TEST_RWTRQ with RW1 0.20nm, RW2 0.10nm, RW3 0.05nm, RW4 0.02nm
;test different torque values
write "@PW "
write "@PW Expecting command accept: ADC RWTRQ"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;must add trq tlm verification

if $$error = time_out
   write "@PW <R>Failed: Command ADC RWTRQ not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $longwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC TEST_RCSON with RCS1 2, RCS2 0, RCS3 0, RCS4 1, RCS5 1, RCS6 0, RCS7 0, RCS8 4
;try a few different configs
;must re-add rcs aot tlm checks
write "@PW "
write "@PW Expecting command accept: ADC TEST_RCSON"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
   write "@PW <R>Failed: Command ADC TEST_RCSON not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


;OTIS BATTSIP limit should be ~10A for this cmd
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC TEST_DVON with DV1 1, DV2 0, DV3 0, DV4 1, DV5 0, DV6 0
;try a few different configs here too
write "@PW "
write "@PW Expecting command accept: ADC TEST_DVON"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;and (ADC DV1AOT = 4.0ms) and (ADC DV2AOT = 8.0ms) and (ADC DV3AOT = 16.0ms) and (ADC DV4AOT = 8.0ms) and (ADC DV5AOT = 0.0ms) and (ADC DV6AOT = 2.0ms)) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command ADC TEST_DVON not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $longwait


CMD ADC POINTCFG with START_MRP_X 0.0, START_MRP_Y 0.0, START_MRP_Z 0.0, STOP_MRP_X 0.0, STOP_MRP_Y 0.0, STOP_MRP_Z 0.0, MNVR_DURATION 30.0
write "@PW "
write "@PW Expecting command accept: ADC POINTCFG"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command ADC POINTCFG not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $longwait





let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPDS
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPDS"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPENST = DS)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPDS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPDS accepted as expected"
endif
Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPDISARM
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPDISARM"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPARMST = SAFE)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPDISARM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPDISARM accepted as expected"
endif
Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPARM
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPARM"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPARMST = ARMED)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPARM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPARM accepted as expected"
endif
Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPEN
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPEN"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPENST = EN)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPEN unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPEN accepted as expected"
endif
Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPDS
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPDS"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPENST = DS)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPDS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPDS accepted as expected"
endif
Wait $shortwait


let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC PRPDISARM
;add tlm checks
write "@PW "
write "@PW Expecting command accept: ADC PRPDISARM"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn) and (ADC PRPARMST = SAFE)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command PRPDISARM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait; wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command PRPDISARM accepted as expected"
endif
Wait $shortwait


;let $cmdacptd = adc cmdacptcnt
;let $cmdrjctd = adc cmdrjctcnt
;CMD ADC CSSSELECT with ADC 0
;write "@PW "
;write "@PW Expecting command accept: ADC CSSSELECT"
;wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command ADC CSSSELECT not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;	write "@PW "
;	write "@PW <G>Command accepted as expected"
;endif
;
;Wait $shortwait



;turn on DPU1
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU1PRIME
write "@PW "
write "@PW Expecting command accept: ADC DPU1PRIME"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPU1PRIME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUTIME with SIDE 0, SNAPTOPAYLOAD 1, COMMANDSECONDS 0, COMMANDFRACSEC 65535;snaptopayload TRUE
;sets internal DPU tracking time
write "@PW "
write "@PW Expecting command accept: ADC DPUTIME"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUTIME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $shortwait





let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUSTOREIMG WITH DPU 0, COMPRESSION 3, CHU 1
;can only be used with DPU1 on flatsat
write "@PW "
write "@PW Expecting command accept: ADC DPUSENDIMG"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUSENDIMG not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif


wait $shortwait

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUSENDIMG WITH DPU 0, ADDR 0, LENGTH 34
;can only be used with DPU1 on Flatsat
write "@PW "
write "@PW Expecting command accept: ADC DPUSTOREIMG"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUSTOREIMG not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif



wait $longwait
wait $shortwait





let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUREBOOT WITH DPU 0
;can only be tested on DPU1 on flatsat
write "@PW "
write "@PW Expecting command accept: ADC DPUREBOOT"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUREBOOT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif



wait $longwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUWATERMARK with DPUSEL 0, WATERMARKSETTING 128
;sets watermark for DPU1 or DPU2, range is 0:512, default is 256
write "@PW "
write "@PW Expecting command accept: ADC DPUwatermark"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUwatermark not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC GETDPUWATER with DPUSEL 0
;yields event message with a value
write "@PW "
write "@PW Expecting command accept: ADC DPU2PRIME"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPU2PRIME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait




;turn off DPU1
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPU2PRIME
write "@PW "
write "@PW Expecting command accept: ADC DPU2PRIME"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPU2PRIME not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
CMD ADC DPUSECOFF
write "@PW "
write "@PW Expecting command accept: ADC DPUSECOFF"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd + 0.0dn)) or for $tm_wait
;should be DPU1 power off, leaving flatsat in safe config
if $$error = time_out
    write "@PW <R>Failed: Command ADC DPUSECOFF not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

Wait $shortwait



;wait $shortwait

;CMD ADC SENDPRACC

;CMD ADC EPHEM CORR with TDBTIME xxx, COMMANDSECONDS xxx, COMMANDFRACSEC xxx, SNAPTOPAYLOAD xxx

;CMD ADC DPUMODE with DPU xxx, ID xxx, SEQCTRL xxx, ADDR xxx, VALUE xxx

;Not testing for now, Not Safe
;CMD ADC DPUPARAM with xxx
;CMD ADC DPUREQSTAT with xxx




FINISH:

if $test_err = 0
        write "@PW "
	write "@PW <G>Total number of errors: ", $test_err
else
    write "@PW "
    write "@PW <R>Total number of errors: ", $test_err
endif

if $cmdrjctd = 11.0dn
    write "@PW <G>Expected number of commands rejected: 11"
    write "@PW <G>Total number of commands rejected: ", $cmdrjctd
else
    write "@PW <R>Expected number of commands rejected: 11"
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

endproc; adc

