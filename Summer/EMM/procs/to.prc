proc to
;*** $Revision: 1.3 $
;*** $Date: 2018/09/09 00:01:27 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/to.prc,v $
;*
;* Created by: EMM Operations Account, Laura Kohnert
;* Creation Date: 07/26/18
;*
;*  FUNCTION: Tests commands in Telemetry Output (TO) app
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: TONOOP,TOQRYOUTCHL,TOQUERYPQ,TODISABLCHNL,TOENABLCHNL,
;*           TOFLUSHCHNLCMD,TOSNDDIAGCMD,TOQRYMSGFLW,TOMODMSGFLW,
;*           TORMMSGFLW,TOABUFFPOS, TOCNTRESET
;*
;*  INVOKES: init
;*  Procedures: N/A
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
    check clp_2 procedure_name
    new_proc init
    start init
endif

start manage_files xfer, switch

wait 00:00:10 ;for log switching to complete

2goto RESTART ;comes out of loop and starts over
if (clp_2 status = "EXECUTING")
    write "@PW "
else
    2go;if clp 2 is waiting after 2goto RESTART, it needs 2go
endif

;---------------------
write "@PW Starting procedure $RCSfile: to.prc,v $"
write "@PW $Revision: 1.3 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $testrjct = 0.0dn
DECLARE VARIABLE $ans = n y,n
DECLARE VARIABLE $pass = n y,n
DECLARE VARIABLE $abuffq_dn = 10.0 dn
DECLARE VARIABLE $abuffq_flt = 10.0 
DECLARE VARIABLE $abuffq_cmd = 10 4:15
DECLARE VARIABLE $prev_ct = 0.0dn
DECLARE VARIABLE $prev_ct2 = 0.0dn
DECLARE VARIABLE $env = snorkel snorkel,spw,radio
DECLARE VARIABLE $exprjct = 0.0dn
; main body of script

;CDH noop for versions
FSW_VER:
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
write "@PW Expecting command: CDHNOOP"
CMD FSW CDHNOOP
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

; TO commands section 
NOOP: ; No-op command for TO task
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
write "@PW Expecting command: TONOOP"
CMD FSW TONOOP
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

CHNLCMDS:

GROUND:
;query channel status
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOQRYOUTCHL with CHANNELID 0
wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOQRYOUTCHL not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOQRYOUTCHNL accepted as expected"
    write "@PW <C>Confirm Event message received, then GO to continue."
    wait
endif

;QUERYPQ
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOQRYPQ with CHANNELID 0, PQIND 0; TODO - determine number of PQIND need to be sent
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOQRYPQ command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOQRYPQ accepted as expected" ; TODO telemetry point changes??
endif

;ground commands are only good when connected via snorkel but 
;they aren't rejected they just fail to have expected affect
;skip the ground diasable/enable/flush if using spacewire or radio.
write "@PW <C> Determine connection path for cube or flatsat."
ask $env "How connected? (snorkel,spw,radio)"
if $env /= snorkel
  GOTO SKIP_GROUND 
endif

write "@PW <Y> Disabling the ground telemetry path will "
write "@PW <Y> result in a loss of all telemetry when "
write "@PW <Y> connected via SNORKEL only (i.e. no radio). "
write "@PW <Y> It is temporary. OK to answer yes when asked." 

let $ans = n
ask $ans "Disable/enable ground channel? (y/n)"
; Disable ID = 0 (ground) - stops all telemetry?  
if $ans = y and $env = snorkel
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    CMD FSW TODISABLCHL with CHANNELID 0
    wait $tm_wait 
    let $prev_ct = fsw tosnklsent
    wait (fsw tosnklsent > $prev_ct) or for $tm_wait
        if $$error = time_out
            write "@PW <G> Counter not incrementing -  as expected"
        else
            write "@PW <R>Failed: Command TODISABLCHL did not function as expected."
            write "@PW Document the failure, then type 'GO' to continue"
            let $test_err = $test_err + 1
            wait;wait for documentation, then type 'GO'
       endif

;reenable ID = 0 (ground)
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    CMD FSW TOENABLCHL with CHANNELID 0
    wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: Command TOENABLCHL not accepted"
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW "
        write "@PW <G>Command TOENABLCHL accepted as expected"
        wait (fsw tosnklsent > $prev_ct) or for $tm_wait
        if $$error = time_out
            write "@PW <R>Failed: Command TOENABLCHL did not function as expected."
            write "@PW Document the failure, then type 'GO' to continue"
            let $test_err = $test_err + 1
            wait;wait for documentation, then type 'GO'         
        else
            write "@PW <G> Counter incrementing - channel re-enabled."
        endif
    endif 
endif

;clear buffers (snorkel only)
if $env = snorkel
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    CMD FSW TOFLUSHCHLCMD with CHANNELID 0
    wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: Command TOFLUSHCHLCMD not accepted"
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW "
        write "@PW <G>Command TOFLUSHCHL accepted as expected."
        wait fsw TOQDINOUTCHN0 = 0.0DN or for $tm_wait
        if $$error = time_out
            write "@PW <R>Failed: TOFLUSHCHL did not execute as expected."
            write "@PW Document the issue, then type 'GO' to continue"
            let $test_err = $test_err + 1
        else 
            write "@PW <G>TOFLUSHCMD Channel 0 executed as expected."
        endif    
    endif
endif

SKIP_GROUND:
;send dignostic packet for this channel
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
let $prev_ct = pkt_apid_0547 src_seq_ctr
let $prev_ct2 = pkt_apid_0546 src_seq_ctr
CMD FSW TOSNDDIAGCMD with CHANNELID 0
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOSNDDIAGCMD not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOSNDDIAGCMD accepted as expected"
    write "@PW "
    wait (pkt_apid_0547 src_seq_ctr > $prev_ct and pkt_apid_0546 src_seq_ctr > $prev_ct2) or for $tm_wait
    if $$error = time_out
        write "TO Diagnostic packet not received"
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        if fsw todchidx /= 0.0DN or fsw tomfchidx /= 0.0DN
           write "@PW Diagnostic packets Do not reflect proper Channel ID" 
           write "@PW Document the issue, then type 'GO' to continue"
           let $test_err = $test_err + 1
           wait;wait for documentation, then type 'GO' 
        else
           write "@PW "
           write "@PW <G> Proper diagnostic packets received "
;           write "@PW <C>Confirm telemetry fully populated, type GO to continue. "
;           wait ; Go to continue
        endif
    endif 
endif


RADIO: ; no radio on cube
;query channel status
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOQRYOUTCHL with CHANNELID 1
wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOQRYOUTCHL not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOQRYOUTCHL accepted as expected"
    write "@PW <C>Confirm Event message received, then GO to continue"
    wait
endif

write "@PW <Y> Disabling the radio telemetry path "
write "@PW <Y> is not an allowed option. "
write "@PW <Y> Test will confirm commands will reject."

let $ans = n
ask $ans "Test enable/disable command for radio channel? (y/n)"

if $ans = y
    ; Disable ID = 1 (radio)
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    CMD FSW TODISABLCHL with CHANNELID 1
    wait ((fsw tocmdrjctcnt >= $cmdrjctd + 1.0dn) and (fsw tocmdacptcnt = $cmdacptd)) or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: Command TODISABLCHL not rejected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW <G> TODISABLCHL rejected - as expected"
        let $exprjct = $exprjct +1.0dn
    endif 

    ;enable path to radio
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    let $prev_ct = fsw toradiosent 
    CMD FSW TOENABLCHL with CHANNELID 1
    wait ((fsw tocmdrjctcnt >= $cmdrjctd + 1.0dn) and (fsw tocmdacptcnt = $cmdacptd)) or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: Command TOENABLCHL not rejected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW <G> TOENABLCHL rejected as expected."
        let $exprjct = $exprjct +1.0dn
    endif
endif

;send dignostic packet for this channel
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
let $prev_ct = pkt_apid_0547 src_seq_ctr
let $prev_ct2 = pkt_apid_0546 src_seq_ctr

CMD FSW TOSNDDIAGCMD with CHANNELID 1
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOSNDDIAGCMD not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOSNDDIAGCMD accepted as expected"
    write "@PW "
    wait (pkt_apid_0547 src_seq_ctr > $prev_ct and pkt_apid_0546 src_seq_ctr > $prev_ct2) or for $tm_wait
    if $$error = time_out
        write "New TO Diagnostic packet not received"
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW <C> Confirm TODIAG and MSGDIAGPKT have updated."
        if fsw todchidx /= 1.0DN or fsw tomfchidx /= 1.0DN
           write "@PW Diagnostic packets do not reflect proper Channel ID" 
           write "@PW Document the issue, then type 'GO' to continue"
           let $test_err = $test_err + 1
           wait;wait for documentation, then type 'GO' 
        else
           write "@PW "
           write "@PW <G> Proper diagnostic packets received "
;           write "@PW  Review content, then type Go to continue. "
;           wait ; Go to continue
        endif
    endif  
endif

;QUERYPQ -radio
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOQRYPQ with CHANNELID 1, PQIND 1; TODO - determine number of PQIND need to be sent
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOQRYPQ command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOQRYPQ accepted as expected" 
; TODO determine which telemetry point changes??
endif

;clear buffers - radio
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOFLUSHCHLCMD with CHANNELID 1
wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOFLUSHCHLCMD not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOFLUSHCHL accepted as expected"
 wait fsw TOQDINOUTCHN1 = 0.0DN or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: TOFLUSHCHL command did not execute as expected."
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
    else 
        write "@PW <G>TOFLUSHCMD Channel 1 executed as expected."
    endif
endif

SSR: ; 
;query channel status
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOQRYOUTCHL with CHANNELID 2
wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOQRYOUTCHL not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOQRYOUTCHL accepted as expected"
    write "@PW <C>Confirm Event message received, then GO to continue"
    wait
endif

write "@PW <Y> Disabling the SSR telemetry path "
write "@PW <Y> is not an allowed option. "
write "@PW <Y> Test will confirm commands will reject."

let $ans = n
ask $ans "Test enable/disable commands for SSR channel? (y/n)"

if $ans = y
    ; Disable ID = 2 (SSR)
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    CMD FSW TODISABLCHL with CHANNELID 2
    wait ((fsw tocmdrjctcnt >= $cmdrjctd + 1.0dn) and (fsw tocmdacptcnt = $cmdacptd)) or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: Command TODISABLCHL not rejected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW <G> TODISABLCHL command rejected - as expected"
        let $exprjct = $exprjct +1.0dn
    endif    
    ;enable path to SSR
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    let $prev_ct = fsw tossrsent 
    CMD FSW TOENABLCHL with CHANNELID 2
    wait ((fsw tocmdrjctcnt >= $cmdrjctd + 1.0dn) and (fsw tocmdacptcnt = $cmdacptd)) or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: Command TOENABLCHL not rejected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW "
        write "@PW <G>Command TOENABLCHL rejected as expected"
        let $exprjct = $exprjct +1.0dn
    endif
endif

;send dignostic packet for this channel
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
let $prev_ct = pkt_apid_0547 src_seq_ctr
let $prev_ct2 = pkt_apid_0546 src_seq_ctr
CMD FSW TOSNDDIAGCMD with CHANNELID 2
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOSNDDIAGCMD not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOSNDDIAGCMD accepted as expected"
    write "@PW "
    wait (pkt_apid_0547 src_seq_ctr > $prev_ct and pkt_apid_0546 src_seq_ctr > $prev_ct2) or for $tm_wait
    if $$error = time_out
        write "TO Diagnostic packet not received"
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        if fsw todchidx /= 2.0DN or fsw tomfchidx /= 2.0DN
           write "@PW Diagnostic packets do not reflect proper Channel ID" 
           write "@PW Document the issue, then type 'GO' to continue"
           let $test_err = $test_err + 1
           wait;wait for documentation, then type 'GO' 
        else
           write "@PW "
           write "@PW <G> Proper diagnostic packets received "
;           write "@PW  Review content, then type GO to continue. "
;           wait ; Go to continue
        endif
    endif 
endif

;QUERYPQ
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOQRYPQ with CHANNELID 2, PQIND 2
; TODO - determine number of PQIND need to be sent
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOQRYPQ command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOQRYPQ accepted as expected" 
    ; TODO which telemetry point changes??
endif

;clear buffers
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOFLUSHCHLCMD with CHANNELID 2
wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOFLUSHCHLCMD not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOFLUSHCHL accepted as expected"
    wait fsw TOQDINOUTCHN2 = 0.0DN or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: TOFLUSHCHL command did not execute as expected."
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
    else 
        write "@PW <G>TOFLUSHCMD Channel 2 executed as expected."
    endif
endif

;reassign anomaly buffer then restore
ABUFF:
; capture current anomaly queue assignment
let $abuffq_dn = fsw toabuffpos
let $abuffq_flt = $abuffq_dn
let $abuffq_cmd = $abuffq_flt
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
cmd FSW TOABUFFPOS with QUEUE 4; what is OK? 10 expected, 4-15 acceptable range
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOABUFFPOS command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOABUFFPOS accepted as expected"
    wait fsw toabuffpos = 4.0DN or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: TOABUFFPOS not set to expected value."
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
    else 
        write "@PW <G>TOABUFFPOS set as expected."
        ;restore original
        let $cmdacptd = fsw tocmdacptcnt
        let $cmdrjctd = fsw tocmdrjctcnt        
        cmd FSW TOABUFFPOS with QUEUE $abuffq_cmd        
        wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw toabuffpos = $abuffq_dn)) or for $tm_wait
        if $$error = time_out 
            write "@PW <R>Failed: TOABUFFPOS not restored."
            write "@PW Document the issue, then type 'GO' to continue"
            let $test_err = $test_err + 1
        else 
            write "@PW <G>TOABUFFPOS reset as expected."
        endif
    endif
endif

; Query known message to get values (does test need to use all 100+ msg ids?) 
; then modify, remove and add back with original values 

QUERYMSG:
;MID = msgid, ML = msglimit, PQI = priority (0-3),N = filter (decimation 1 in N)
;D = dropped count Q = current queued count SB = SB message count 
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOQRYMSGFLW with MSGID 2769; 0x0ad1 = CDH_IOCHK_TLM packet
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOQRYMSGFLW command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOQRYMSGFLW accepted as expected"
    write "@PW"
    write "@PW <C> Review event message for initial values."
    write "@PW EXPECTING : CHANNEL = 0 MID = 0x0ad1"
    write "@PW   ML = 1, PQI = 2 N=3, AB =10, D = , Q =  SB = "
    write "@PW NOTE: D, Q and  SB value may vary with each query."
    ask $pass "Expected event message received? (y,n)"
        if $pass = n 
            write "@PW Document the issue, then type 'GO' to continue"
            let $test_err = $test_err + 1
        endif
    write "@PW <C> GO when ready to modify message flow."
    wait
endif

;modify message just queried -can only play with filter 
;storage queues stay 0 for snorkel (defaults??)
;MID = msgid, ML = msglimit, PQI = priority (0-3),N = filter (decimation 1 in N) 
MODMSG:
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOMODMSGFLW with CHANNELID 0, MSGID 2769, FILTERVALUE 1
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOMODMSGFLW command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOMODMSGFLW accepted as expected"
    write "@PW Querying message flow to confirm change." 
    let $cmdacptd = fsw tocmdacptcnt
    let $cmdrjctd = fsw tocmdrjctcnt
    CMD FSW TOQRYMSGFLW with MSGID 2769; 0x0ad1 = CDH_IOCHK_TLM packet
    wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
    if $$error = time_out
        write "@PW <R>Failed: Command TOQRYMSGFLW command not accepted"
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW <C> Review event message for change."
        write "@PW EXPECTING : CHANNEL = 0 MID = 0x0ad1"
        write "@PW  ML = 1, PQI = 2 N=1, AB =, D = , Q=, SB=" 
        write "@PW NOTE: AB, D, Q and  SB value may vary."
        ask $pass "Expected event message received? (y,n)"
        if $pass = n 
            write "@PW Document the issue, then type 'GO' to continue"
            let $test_err = $test_err + 1
        endif
        write "@PW <C> GO when ready to remove message flow."
        wait
    endif
endif

RMMSG:
;temporarily remove CDH_IOCHK message flow 
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
write "@PW <C> Expect event messages to prove success : "
write "@PW <W>         Executed ADD_REMOVE cmd"
write "@PW <Y> If timing is right may also see a second :"
write "@PW <W>      ERROR : Classifier Recvd invalid msgID"
write "@PW "
CMD FSW TORMMSGFLW with CHANNELID 0, MSGID 2769; 0x0ad1 = CDH_IOCHK_TLM packet
let $prev_ct = pkt_apid_0721 src_seq_ctr
wait ((fsw tocmdacptcnt >= $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TORMMSGFLOW command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
    let $test_err = $test_err + 1
else   
    ask $pass "Expected event message received? (y,n)"
    if $pass = n 
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        write "@PW <G> Command TORMMSGFLOW functioned as expected."
    endif
endif    

ADDMSG:
;add back CDH_IOCHK message flow with original values
;queues default to 0 which is correct for ground channel
let $cmdacptd = fsw tocmdacptcnt
let $cmdrjctd = fsw tocmdrjctcnt
CMD FSW TOADDMSGFLW with CHANNELID 0, MSGID 2769,MSGLIMIT 1,PQUEUEID 2, FILTERVALUE 3
wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOADDMSGFLW command not accepted"
    write "@PW Document the issue, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command TOADDMSGFLW accepted as expected"
    ask $pass "ADD_MESSAGE event message received? (y,n)"
    if $pass = n 
        write "@PW Document the issue, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
        let $cmdacptd = fsw tocmdacptcnt
        let $cmdrjctd = fsw tocmdrjctcnt
        CMD FSW TOQRYMSGFLW with MSGID 2769; 0x0ad1 = CDH_IOCHK_TLM packet
        wait ((fsw tocmdacptcnt = $cmdacptd + 1.0dn) and (fsw tocmdrjctcnt = $cmdrjctd)) or for $tm_wait
        if $$error = time_out
            write "@PW <R>Failed: Command TOQRYMSGFLW command not accepted"
            write "@PW Document the issue, then type 'GO' to continue"
            let $test_err = $test_err + 1
            wait;wait for documentation, then type 'GO'
        else
            write "@PW <C> Compare event message against original."
            write "@PW EXPECTING : CHANNEL = 0 MID = 0x0ad1"
            write "@PW   ML = 1, PQI = 2 N=3, AB = same,D  = 0, Q = ,SB = "
            write "@PW NOTE: Q and SB values expected to vary with query."
            ask $pass "Does Event message confirm original values? (y,n)"
            if $pass = n 
                write "@PW Document the issue, then type 'GO' to continue"
                let $test_err = $test_err + 1
                wait;wait for documentation, then type 'GO'
            endif
        endif
    endif
endif

CNTRESET: ;command to reset TO counters
;preserve rejected counter
if (fsw tocmdrjctcnt /= 0.0dn)
    let $testrjct = fsw tocmdrjctcnt
endif

write "@PW "
write "@PW Expecting command: TOCNTRESET"
CMD FSW TOCNTRESET
wait ((fsw tocmdacptcnt = 0.0dn) and (fsw tocmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command TOCNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command accepted as expected"
endif

FINISH:

write "@PW "
write "@PW Checking command reject counter..."
let $testrjct = $testrjct + (fsw tocmdrjctcnt)
check $testrjct
check $exprjct
if $testrjct > $exprjct
    write "@PW <R>Failed: Unexpected rejected TO commands during this test."
    write "@PW <R>Number of rejected commands:", $testrjct
    write "@PW NOTE : Expecting ",$exprjct, " rejected commands."
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>No commands unexpectedly rejected during this test"
endif

write "@PW "
write "@PW Completed testing of Telemetry Output (TO) task."
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

endproc; to

