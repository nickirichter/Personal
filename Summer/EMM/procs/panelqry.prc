proc panelqry
;*** $Revision: 1.6 $
;*** $Date: 2018/08/02 21:11:18 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/panelqry.prc,v $
;*
;* Created by: EMM Operations Account, Del Sherman
;* Creation Date: 04/05/2018
;*
;*  FUNCTION: Sends commands for one-shot panels to populate
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Populates the following APID panels: 6, 10, 11, 12, 15, 16,
;*           121, 123, 124, 125, 126, 127, 546, 547, 641, 649, 715, 726, 737
;*
;*  INVOKES:
;*  Procedures: N/A
;*  Utilities: N/A
;*
;*  RETURNS: N/A
;*
;*  CALLED BY: check_panels.prc
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
write "@PW Starting procedure $RCSfile: panelqry.prc,v $"
write "@PW $Revision: 1.6 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $tblmempoolhndl_eu = 0.0dn
DECLARE VARIABLE $tblmempoolhndl_real = 0.0
DECLARE VARIABLE $tblmempoolhndl_int = 0

; main body of script

;APID 6
let $cmdacptd = fsw timecmdacptcnt
let $cmdrjctd = fsw timecmdrjctcnt
write "@PW "
write "@PW Populating APID 6 panel..."
write "@PW Expecting command accept: TIMEDIAG"
CMD FSW TIMEDIAG
wait ((fsw timecmdacptcnt = $cmdacptd + 1.0dn) and (fsw timecmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TIMEDIAG not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 6 panel should now be populated..."
endif

;APID 10
let $cmdacptd = fsw sbcmdacptcnt
let $cmdrjctd = fsw sbcmdrjctcnt
write "@PW "
write "@PW Populating APID 10 panel..."
write "@PW Expecting command accept: SBSTATTX"
CMD FSW SBSTATTX
wait ((fsw sbcmdacptcnt = $cmdacptd + 1.0dn) and (fsw sbcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SBSTATTX not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 10 panel should now be populated..."
endif

;APID 11
let $cmdacptd = fsw escmdacptcnt
let $cmdrjctd = fsw escmdrjctcnt
write "@PW "
write "@PW Populating APID 11 panel..."
write "@PW Expecting command accept: ESQAPP"
CMD FSW ESQAPP with NAME "ADC"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw escmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESQAPP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 11 panel should now be populated..."
endif

;APID 12
let $cmdacptd = fsw tblcmdacptcnt
let $cmdrjctd = fsw tblcmdrjctcnt
write "@PW "
write "@PW Populating APID 12 panel..."
write "@PW Expecting command accept: TBLREGDUMP"
CMD FSW TBLREGDUMP with NAME "LC.LC_WRT"
wait ((fsw tblcmdacptcnt = $cmdacptd + 1.0dn) and (fsw tblcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TBLREGDUMP not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 12 panel should now be populated..."
endif

;APID 15
let $cmdacptd = fsw escmdacptcnt
let $cmdrjctd = fsw escmdrjctcnt
write "@PW "
write "@PW Populating APID 15 panel..."
write "@PW Expecting command accept: ESSHELL"
CMD FSW ESSHELL with STR "pwd", FILE "/ram/ops_test1.txt"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw escmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSHELL not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 15 panel should now be populated..."
endif

;APID 16
let $cmdacptd = fsw escmdacptcnt
let $cmdrjctd = fsw escmdrjctcnt
let $tblmempoolhndl_eu = fsw tblmempoolhndl
let $tblmempoolhndl_real = $tblmempoolhndl_eu
let $tblmempoolhndl_int = $tblmempoolhndl_real
write "@PW "
write "@PW Populating APID 16 panel..."
write "@PW Expecting command accept: ESPOOLTX"
CMD FSW ESPOOLTX with NAME "TBL", HANDLE $tblmempoolhndl_int
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw escmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPOOLTX not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 16 panel should now be populated..."
endif

;APID 121
let $cmdacptd = fsw dscmdacptcnt
let $cmdrjctd = fsw dscmdrjctcnt
write "@PW "
write "@PW Populating APID 121 panel..."
write "@PW Expecting command accept: DSFILEGET"
CMD FSW DSFILEGET
wait ((fsw dscmdacptcnt = $cmdacptd + 1.0dn) and (fsw dscmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command DSFILEGET not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 121 panel should now be populated..."
endif

;APID 123
;file created by esshell
let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
write "@PW "
write "@PW Populating APID 123 panel..."
write "@PW Expecting command accept: FMINFO"
CMD FSW FMINFO with NAME "/ram/ops_test1.txt", CRC ignore
wait ((fsw fmcmdacptcnt = $cmdacptd + 1.0dn) and (fsw fmcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMINFO not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 123 panel should now be populated..."
endif
;remove file created by esshell and for fminfo commands
write "@PW "
write "@PW Remove file created by esshell and for FMINFO commands"
let $cmdacptd = fsw fmcmdacptcnt
CMD FSW FMRM with NAME "/ram/ops_test1.txt"
wait (fsw fmcmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command FMRM successful"
endif

;APID 124
let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
write "@PW "
write "@PW Populating APID 124 panel..."
write "@PW Expecting command accept: FMLSPKT"
CMD FSW FMLSPKT with DIR "/ram", OFFSET 0, MODE NO_INFO
wait ((fsw fmcmdacptcnt = $cmdacptd + 1.0dn) and (fsw fmcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMLSPKT not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 124 panel should now be populated..."
endif

;APID 125
let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
write "@PW "
write "@PW Populating APID 125 panel..."
write "@PW Expecting command accept: FMOPEN"
CMD FSW FMOPEN with OFFSET 0
wait ((fsw fmcmdacptcnt = $cmdacptd + 1.0dn) and (fsw fmcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMOPEN not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 125 panel should now be populated..."
endif

;APID 126
let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
write "@PW "
write "@PW Populating APID 126 panel..."
write "@PW Expecting command accept: FMFREE"
CMD FSW FMFREE
wait ((fsw fmcmdacptcnt = $cmdacptd + 1.0dn) and (fsw fmcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMFREE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 126 panel should now be populated..."
endif

;APID 127
let $cmdacptd = fsw fmcmdacptcnt
let $cmdrjctd = fsw fmcmdrjctcnt
write "@PW "
write "@PW Populating APID 127 panel..."
write "@PW Expecting command accept: FMSNDDG"
CMD FSW FMSNDDG
wait ((fsw fmcmdacptcnt = $cmdacptd + 1.0dn) and (fsw fmcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMSNDDG not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 127 panel should now be populated..."
endif

;APID 546 & 547
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
write "@PW "
write "@PW Populating APID 546 and 547 panels..."
write "@PW Expecting command accept: TOSNDDIAGCMD"
CMD FSW TOSNDDIAGCMD with CHANNELID 0
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOSNDDIAGCMD not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 546 and 547 panels should now be populated..."
endif

;APID 641
let $cmdacptd = eps cmdacptcnt
write "@PW "
write "@PW Populating APID 641 panel..."
write "@PW Expecting command accept: EPS REQ_PEAKHOLD"
CMD EPS REQ_PEAKHOLD
wait (eps cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS REQ_PEAKHOLD not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 641 panel should now be populated..."
endif

;APID 649
let $cmdacptd = eps cmdacptcnt
write "@PW "
write "@PW Populating APID 649 panel..."
write "@PW Expecting command accept: EPS REQ_HDRMHR"
CMD EPS REQ_HDRMHR
wait (eps cmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command EPS REQ_HDRMHR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 649 panel should now be populated..."
endif

;APID 715
;have to go to another adc state and then switch to safe state
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
write "@PW "
write "@PW Expecting command accept: ADC DESAT_STATE"
CMD ADC DESAT_STATE
wait ((adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC DESAT_STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
write "@PW "
write "@PW Populating APID 715 panel..."
write "@PW Expecting command accept: ADC SAFE_STATE"
CMD ADC SAFE_STATE
wait ((adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC SAFE_STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 715 panel should now be populated..."
endif
;leave adc in a non-safed state
let $cmdacptd = adc cmdacptcnt
let $cmdrjctd = adc cmdrjctcnt
write "@PW "
write "@PW Expecting command accept: ADC STANDBY_STATE"
CMD ADC STANDBY_STATE
wait ((adc cmdacptcnt = $cmdacptd + 1.0dn) and (adc cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ADC STANDBY_STATE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

;APID 726
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
write "@PW "
write "@PW Populating APID 726 panel..."
write "@PW Expecting command accept: CDH BOOTSEND"
CMD CDH BOOTSEND
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDH BOOTSEND not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 726 panel should now be populated..."
endif

;APID 737
let $cmdacptd = fsw seqcmdacptcnt
let $cmdrjctd = fsw seqcmdrjctcnt
write "@PW "
write "@PW Populating APID 737 panel..."
write "@PW Expecting command accept: SEQGVSEND"
CMD FSW SEQGVSEND
wait ((fsw seqcmdacptcnt = $cmdacptd + 1.0dn) and (fsw seqcmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command SEQGVSEND not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
	write "@PW "
	write "@PW <G>APID 737 panel should now be populated..."
endif




FINISH:

endproc; panelqry

