proc noop
;*** $Revision: 1.7 $
;*** $Date: 2018/08/24 16:58:19 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/noop.prc,v $
;*
;* Created by: EMM Operations Account
;* Creation Date: 05/15/2018
;*
;*  FUNCTION: Tests all app and instrument noops, plus CDH and RTMS
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Noops for all the following apps, then counter resets for all: 
;*           SCH, DS, HS, HK, CS, MM, MD, FM, CF, ES, TIME, EVS, SB, TBL, ADC,
;*           PRP, THM, EPS, LC, SEQ, FDC, CI, TO, SSRA, COM, CDH, EMR, EMU, 
;*           EXI, RTMS
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


write "@PW Starting procedure $RCSfile: noop.prc,v $"
write "@PW $Revision: 1.7 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $test_err = 0

; main body of script

;noops

;CDH
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH NOOP
write "@PW "
write "@PW Expecting command accept: CDHNOOP"
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

;SCH
let $cmdacptd = fsw schcmdacptcnt
let $cmdrjctd = fsw schcmdrjctcnt
CMD FSW SCHNOOP
write "@PW "
write "@PW Expecting command accept: SCHNOOP"
wait ((fsw schcmdacptcnt = $cmdacptd + 1.0dn) and (fsw schcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SCHNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SCHNOOP accepted as expected"
endif

;DS
let $cmdacptd = fsw dscmdacptcnt
let $cmdrjctd = fsw dscmdrjctcnt
CMD FSW DSNOOP
write "@PW "
write "@PW Expecting command accept: DSNOOP"
wait ((fsw dscmdacptcnt = $cmdacptd + 1.0dn) and (fsw dscmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DSNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command DSNOOP accepted as expected"
endif

;HS
let $cmdacptd = fsw hscmdacptcnt
let $cmdrjctd = fsw hscmdrjctcnt
CMD FSW HSNOOP
write "@PW "
write "@PW Expecting command accept: HSNOOP"
wait ((fsw hscmdacptcnt = $cmdacptd + 1.0dn) and (fsw hscmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command HSNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command HSNOOP accepted as expected"
endif

;HK
let $cmdacptd = fsw hkcmdacptcnt
let $cmdrjctd = fsw hkcmdrjctcnt
CMD FSW HKNOOP
write "@PW "
write "@PW Expecting command accept: HKNOOP"
wait ((fsw hkcmdacptcnt = $cmdacptd + 1.0dn) and (fsw hkcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command HKNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command HKNOOP accepted as expected"
endif

;CS
let $cmdacptd = fsw cscmdacptcnt
let $cmdrjctd = fsw cscmdrjctcnt
CMD FSW CSNOOP
write "@PW "
write "@PW Expecting command accept: CSNOOP"
wait ((fsw cscmdacptcnt = $cmdacptd + 1.0dn) and (fsw cscmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CSNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CSNOOP accepted as expected"
endif

;MM
let $cmdacptd = fsw mmcmdacptcnt
let $cmdrjctd = fsw mmcmdrjctcnt
CMD FSW MMNOOP
write "@PW "
write "@PW Expecting command accept: MMNOOP"
wait ((fsw mmcmdacptcnt = $cmdacptd + 1.0dn) and (fsw mmcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command MMNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command MMNOOP accepted as expected"
endif

;MD
let $cmdacptd = fsw mdcmdacptcnt
let $cmdrjctd = fsw mdcmdrjctcnt
CMD FSW MDNOOP
write "@PW "
write "@PW Expecting command accept: MDNOOP"
wait ((fsw mdcmdacptcnt = $cmdacptd + 1.0dn) and (fsw mdcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command MDNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command MDNOOP accepted as expected"
endif

;FM
let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
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
	write "@PW "
	write "@PW <G>Command FMNOOP accepted as expected"
endif

;CF
let $cmdacptd = fsw cfcmdacptcnt
let $cmdrjctd = fsw cfcmdrjctcnt
CMD FSW CFNOOP
write "@PW "
write "@PW Expecting command accept: CFNOOP"
wait ((fsw cfcmdacptcnt = $cmdacptd + 1.0dn) and (fsw cfcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CFNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CFNOOP accepted as expected"
endif

;ES
let $cmdacptd = fsw escmdacptcnt
let $cmdrjctd = fsw escmdrjctcnt
CMD FSW ESNOOP
write "@PW "
write "@PW Expecting command accept: ESNOOP"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw escmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else

	write "@PW "
	write "@PW <G>Command ESNOOP accepted as expected"
endif

;TIME
let $cmdacptd = fsw timecmdacptcnt
let $cmdrjctd = fsw timecmdrjctcnt
CMD FSW TIMENOOP
write "@PW "
write "@PW Expecting command accept: TIMENOOP"
wait ((fsw timecmdacptcnt = $cmdacptd + 1.0dn) and (fsw timecmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TIMENOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command TIMENOOP accepted as expected"
endif

;EVS
let $cmdacptd = fsw evscmdacptcnt
let $cmdrjctd = fsw evscmdrjctcnt
CMD FSW EVSNOOP
write "@PW "
write "@PW Expecting command accept: EVSNOOP"
wait ((fsw evscmdacptcnt = $cmdacptd + 1.0dn) and (fsw evscmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EVSNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EVSNOOP accepted as expected"

endif

;SB
let $cmdacptd = fsw sbcmdacptcnt
let $cmdrjctd = fsw sbcmdrjctcnt
CMD FSW SBNOOP
write "@PW "
write "@PW Expecting command accept: SBNOOP"
wait ((fsw sbcmdacptcnt = $cmdacptd + 1.0dn) and (fsw sbcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SBNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SBNOOP accepted as expected"

endif

;TBL
let $cmdacptd = fsw tblcmdacptcnt
let $cmdrjctd = fsw tblcmdrjctcnt
CMD FSW TBLNOOP
write "@PW "
write "@PW Expecting command accept: TBLNOOP"
wait ((fsw tblcmdacptcnt = $cmdacptd + 1.0dn) and (fsw tblcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TBLNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command TBLNOOP accepted as expected"
endif

;adcnoop

let $cmdacptd = ADC CMDACPTCNT
let $cmdrjctd = ADC CMDRJCTCNT
CMD ADC NOOP
write "@PW "
write "@PW Expecting command accept: ADCNOOP"
wait ((ADC CMDACPTCNT = $cmdacptd + 1.0dn) and (ADC CMDRJCTCNT = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADCNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ADCNOOP accepted as expected"
endif

;prpnoop

let $cmdacptd = PRP CMDACPTCNT
let $cmdrjctd = PRP CMDRJCTCNT
CMD PRP NOOP
write "@PW "
write "@PW Expecting command accept: PRP NOOP"
wait ((PRP CMDACPTCNT = $cmdacptd + 1.0dn) and (PRP CMDRJCTCNT = $cmdrjctd)) or for $tm_wait

if $$error = time_out
    write "@PW <R>Failed: Command PRP NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command PRPNOOP accepted as expected"
endif

;thmnoop

let $cmdacptd = THM CMDACPTCNT
let $cmdrjctd = THM CMDRJCTCNT
CMD THM NOOP
write "@PW "
write "@PW Expecting command accept: THM NOOP"
wait ((THM CMDACPTCNT = $cmdacptd + 1.0dn) and (THM CMDRJCTCNT = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command THM NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command THMNOOP accepted as expected"
endif

;epsnoop

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
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EPSNOOP accepted as expected"
endif

;lcnoop

let $cmdacptd = fsw lccmdacptcnt
let $cmdrjctd = fsw lccmdrjctcnt
CMD FSW LCNOOP
write "@PW "
write "@PW Expecting command accept: LCNOOP"
wait ((fsw lccmdacptcnt = $cmdacptd + 1.0dn) and (fsw lccmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command LCNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command LCNOOP accepted as expected"
endif

;seqnoop

let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
CMD FSW SEQNOOP
write "@PW "
write "@PW Expecting command accept: SEQNOOP"
wait ((fsw seqcmdacptcnt = $cmdacptd + 1.0dn) and (fsw seqcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SEQNOOP accepted as expected"
endif

;fdcnoop

let $cmdacptd = fsw fdccmdacptcnt
let $cmdrjctd = fsw fdccmdrjctcnt
CMD FSW FDCNOOP
write "@PW "
write "@PW Expecting command accept: FDCNOOP"
wait ((fsw fdccmdacptcnt = $cmdacptd + 1.0dn) and (fsw fdccmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FDCNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command FDCNOOP accepted as expected"
endif

;cinoop

let $cmdacptd = fsw cicmdacptcnt
let $cmdrjctd = fsw cicmdrjctcnt
CMD FSW CINOOP
write "@PW "
write "@PW Expecting command accept: CINOOP"
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

;tonoop

let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TONOOP
write "@PW "
write "@PW Expecting command accept: TONOOP"
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TONOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command TONOOP accepted as expected"
endif

;ssranoop

let $cmdacptd = fsw ssracmdacptcnt
let $cmdrjctd = fsw ssracmdrjctcnt
CMD FSW SSRANOOP
write "@PW "
write "@PW Expecting command accept: SSRANOOP"
wait ((fsw ssracmdacptcnt = $cmdacptd + 1.0dn) and (fsw ssracmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SSRANOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SSRANOOP accepted as expected"
endif

;comnoop

let $cmdacptd = com cmdacptcnt
let $cmdrjctd = COM CMDRJCTCNT
CMD COM NOOP
write "@PW "
write "@PW Expecting command accept: COM NOOP"
wait ((com cmdacptcnt = $cmdacptd + 1.0dn) and (COM CMDRJCTCNT = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command COM NOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command COMNOOP accepted as expected"	
endif

;VTC
let $cmdacptd = fsw vtccmdacptcnt
let $cmdrjctd = fsw vtccmdrjctcnt
CMD FSW VTCNOOP
write "@PW "
write "@PW Expecting command accept: VTCNOOP"
wait ((fsw vtccmdacptcnt = $cmdacptd + 1.0dn) and (fsw vtccmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command VTCNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command VTCNOOP accepted as expected"
endif

;EMRA
let $cmdacptd = fsw emrcmdacptcnt
let $cmdrjctd = fsw emrcmdrjctcnt
CMD FSW EMRNOOP
write "@PW "
write "@PW Expecting command accept: EMRNOOP"
wait ((fsw emrcmdacptcnt = $cmdacptd + 1.0dn) and (fsw emrcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EMRNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EMRNOOP accepted as expected"
endif

;EMUA
let $cmdacptd = fsw emucmdacptcnt
let $cmdrjctd = fsw emucmdrjctcnt
CMD FSW EMUNOOP
write "@PW "
write "@PW Expecting command accept: EMUNOOP"
wait ((fsw emucmdacptcnt = $cmdacptd + 1.0dn) and (fsw emucmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EMUNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EMUNOOP accepted as expected"
endif

;EXIA
let $cmdacptd = fsw exicmdacptcnt
let $cmdrjctd = fsw exicmdrjctcnt
CMD FSW EXINOOP
write "@PW "
write "@PW Expecting command accept: EXINOOP"
wait ((fsw exicmdacptcnt = $cmdacptd + 1.0dn) and (fsw exicmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EXINOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EXINOOP accepted as expected"
endif

;rtmsnoop

let $cmdacptd = fsw rtmscmdacptcnt
let $cmdrjctd = fsw rtmscmdrjctcnt
write "@PW "
write "@PW Expecting command accept: RTMSNOOP"
CMD FSW RTMSNOOP
wait ((fsw rtmscmdacptcnt = $cmdacptd + 1.0dn) and (fsw rtmscmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command RTMSNOOP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command RTMSNOOP accepted as expected"
endif




;cntresets

;CDH
CMD CDH CNTRESET
write "@PW "
write "@PW Expecting command accept: CDHCNTRESET"
wait ((cdh cmdacptcnt = 0.0dn) and (cdh cmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CDHCNTRESET accepted as expected"
endif

;SCH
CMD FSW SCHCNTRESET
write "@PW "
write "@PW Expecting command accept: SCHCNTRESET"
wait ((fsw schcmdacptcnt = 0.0dn) and (fsw schcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SCHCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SCHCNTRESET accepted as expected"
endif

;DS
CMD FSW DSCNTRESET
write "@PW "
write "@PW Expecting command accept: DSCNTRESET"
wait ((fsw dscmdacptcnt = 0.0dn) and (fsw dscmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DSCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command DSCNTRESET accepted as expected"
endif

;HS
CMD FSW HSCNTRESET
write "@PW "
write "@PW Expecting command accept: HSCNTRESET"
wait ((fsw hscmdacptcnt = 0.0dn) and (fsw hscmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command HSCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command HSCNTRESET accepted as expected"
endif

;HK
CMD FSW HKCNTRESET
write "@PW "
write "@PW Expecting command accept: HKCNTRESET"
wait ((fsw hkcmdacptcnt = 0.0dn) and (fsw hkcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command HKCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command HKCNTRESET accepted as expected"
endif

;CS
CMD FSW CSCNTRESET
write "@PW "
write "@PW Expecting command accept: CSCNTRESET"
wait ((fsw cscmdacptcnt = 0.0dn) and (fsw cscmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CSCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CSCNTRESET accepted as expected"
endif

;MM
CMD FSW MMCNTRESET
write "@PW "
write "@PW Expecting command accept: MMCNTRESET"
wait ((fsw mmcmdacptcnt = 0.0dn) and (fsw mmcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command MMCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command MMCNTRESET accepted as expected"
endif

;MD
CMD FSW MDCNTRESET
write "@PW "
write "@PW Expecting command accept: MDCNTRESET"
wait ((fsw mdcmdacptcnt = 0.0dn) and (fsw mdcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command MDCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command MDCNTRESET accepted as expected"
endif

;FM
CMD FSW FMCNTRESET
write "@PW "
write "@PW Expecting command accept: FMCNTRESET"
wait ((fsw fmcmdacptcnt = 0.0dn) and (fsw fmcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command FMCNTRESET accepted as expected"
endif

;CF
CMD FSW CFCNTRESET with VALUE 1;1 = reset only cmdcounter and errcounter
write "@PW "
write "@PW Expecting command accept: CFCNTRESET"
wait ((fsw cfcmdacptcnt = 0.0dn) and (fsw cfcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CFCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CFCNTRESET accepted as expected"
endif

;ES
CMD FSW ESCNTRESET
write "@PW "
write "@PW Expecting command accept: ESCNTRESET"
wait ((fsw escmdacptcnt = 0.0dn) and (fsw escmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else

	write "@PW "
	write "@PW <G>Command ESCNTRESET accepted as expected"
endif

;TIME
CMD FSW TIMECNTRESET
write "@PW "
write "@PW Expecting command accept: TIMECNTRESET"
wait ((fsw timecmdacptcnt = 0.0dn) and (fsw timecmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TIMECNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command TIMECNTRESET accepted as expected"
endif

;EVS
CMD FSW EVSCNTRESET
write "@PW "
write "@PW Expecting command accept: EVSCNTRESET"
wait ((fsw evscmdacptcnt = 0.0dn) and (fsw evscmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EVSCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EVSCNTRESET accepted as expected"

endif

;SB
CMD FSW SBCNTRESET
write "@PW "
write "@PW Expecting command accept: SBCNTRESET"
wait ((fsw sbcmdacptcnt = 0.0dn) and (fsw sbcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SBCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SBCNTRESET accepted as expected"

endif

;TBL
CMD FSW TBLCNTRESET
write "@PW "
write "@PW Expecting command accept: TBLCNTRESET"
wait ((fsw tblcmdacptcnt = 0.0dn) and (fsw tblcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TBLCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command TBLCNTRESET accepted as expected"
endif

;adc
CMD ADC CNTRESET
write "@PW "
write "@PW Expecting command accept: ADCCNTRESET"
wait ((ADC CMDACPTCNT = 0.0dn) and (ADC CMDRJCTCNT = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADCCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ADCCNTRESET accepted as expected"
endif

;prp
CMD PRP CNTRESET
write "@PW "
write "@PW Expecting command accept: PRP CNTRESET"
wait ((PRP CMDACPTCNT = 0.0dn) and (PRP CMDRJCTCNT = 0.0dn)) or for $tm_wait

if $$error = time_out
    write "@PW <R>Failed: Command PRP CNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command PRPCNTRESET accepted as expected"
endif

;thm
CMD THM CNTRESET
write "@PW "
write "@PW Expecting command accept: THM CNTRESET"
wait ((THM CMDACPTCNT = 0.0dn) and (THM CMDRJCTCNT = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command THM CNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command THMCNTRESET accepted as expected"
endif

;eps
CMD EPS CNTRESET
write "@PW "
write "@PW Expecting command accept: EPS CNTRESET"
wait ((EPS CMDACPTCNT = 0.0dn) and (EPS CMDRJCTCNT = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS CNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EPSCNTRESET accepted as expected"
endif

;lc
CMD FSW LCCNTRESET
write "@PW "
write "@PW Expecting command accept: LCCNTRESET"
wait ((fsw lccmdacptcnt = 0.0dn) and (fsw lccmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command LCCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command LCCNTRESET accepted as expected"
endif

;seq
CMD FSW SEQCNTRESET
write "@PW "
write "@PW Expecting command accept: SEQCNTRESET"
wait ((fsw seqcmdacptcnt = 0.0dn) and (fsw seqcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SEQCNTRESET accepted as expected"
endif

;fdc
CMD FSW FDCCNTRESET
write "@PW "
write "@PW Expecting command accept: FDCCNTRESET"
wait ((fsw fdccmdacptcnt = 0.0dn) and (fsw fdccmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FDCCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command FDCCNTRESET accepted as expected"
endif

;ci
CMD FSW CICNTRESET
write "@PW "
write "@PW Expecting command accept: CICNTRESET"
wait ((fsw cicmdacptcnt = 0.0dn) and (fsw cicmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CICNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command CICNTRESET accepted as expected"
endif

;to
CMD FSW TOCNTRESET
write "@PW "
write "@PW Expecting command accept: TOCNTRESET"
wait ((fsw tocmdacptcnt = 0.0dn) and (fsw tocmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command TOCNTRESET accepted as expected"
endif

;ssra
CMD FSW SSRACNTRESET
write "@PW "
write "@PW Expecting command accept: SSRACNTRESET"
wait ((fsw ssracmdacptcnt = 0.0dn) and (fsw ssracmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SSRACNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command SSRACNTRESET accepted as expected"
endif

;com
CMD COM CNTRESET
write "@PW "
write "@PW Expecting command accept: COM CNTRESET"
wait ((com cmdacptcnt = 0.0dn) and (COM CMDRJCTCNT = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command COM CNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command COMCNTRESET accepted as expected"	
endif

;VTC
CMD FSW VTCCNTRST
write "@PW "
write "@PW Expecting command accept: VTCCNTRST"
wait ((fsw vtccmdacptcnt = 0.0dn) and (fsw vtccmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command VTCCNTRST not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command VTCCNTRST accepted as expected"
endif

;EMRA
CMD FSW EMRCNTRESET
write "@PW "
write "@PW Expecting command accept: EMRCNTRESET"
wait ((fsw emrcmdacptcnt = 0.0dn) and (fsw emrcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EMRCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EMRCNTRESET accepted as expected"
endif

;EMUA
CMD FSW EMUCNTRESET
write "@PW "
write "@PW Expecting command accept: EMUCNTRESET"
wait ((fsw emucmdacptcnt = 0.0dn) and (fsw emucmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EMUCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EMUCNTRESET accepted as expected"
endif

;EXIA
CMD FSW EXICNTRESET
write "@PW "
write "@PW Expecting command accept: EXICNTRESET"
wait ((fsw exicmdacptcnt = 0.0dn) and (fsw exicmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EXICNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command EXICNTRESET accepted as expected"
endif

;rtms
write "@PW "
write "@PW Expecting command accept: RTMSCNTRESET"
CMD FSW RTMSCNTRESET
wait ((fsw rtmscmdacptcnt = 0.0dn) and (fsw rtmscmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command RTMSCNTRESET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command RTMSCNTRESET accepted as expected"
endif



FINISH:

write "@PW "
write "@PW Completed testing of NOOPs and CNTRESETs"
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

endproc; noop

