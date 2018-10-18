proc cdh
;*** $Revision: 1.6 $
;*** $Date: 2018/09/08 23:01:36 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/cdh.prc,v $
;*
;* Created by: EMM Operations Account, Laura Kohnert
;* Creation Date: 07/03/18
;*
;*  FUNCTION: Tests commands in CDH app
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Tests cdh noop, cdh cntreset, cdh rstsclr,cdh peek,cdh poke, 
;*                 lzcmdclr,lzcmderrclr,lzidclr,lzintclr,lzstclr,cdh iocset
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

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $testrjct = 0.0dn
DECLARE VARIABLE $msg = n y,n
DECLARE VARIABLE $ans = y y,n
DECLARE VARIABLE $seqcnt = 0.0dn
DECLARE VARIABLE $env = cube cube,flatsat

;for telemetry checks
DECLARE VARIABLE $orig_gain1 = 0.0DN ; (should be converted??)
DECLARE VARIABLE $orig_offset1 = 0.0DN ; (should be converted??)
DECLARE VARIABLE $orig_gain2 = 0.0DN ; (should be converted??)
DECLARE VARIABLE $orig_offset2 = 0.0DN  ; (should be converted??)
DECLARE VARIABLE $gain1_tlm = 0.0DN ; (should be converted??)
DECLARE VARIABLE $gain2_tlm = 0.0DN ; (should be converted??)
DECLARE VARIABLE $offset1_tlm = 0.0DN ; (should be converted??)
DECLARE VARIABLE $offset2_tlm = 0.0DN ; (should be converted??)

;for commands
DECLARE VARIABLE $orig_g1_cmd = 0 ; (should be converted??)
DECLARE VARIABLE $orig_off1_cmd = 0 ; (should be converted??)
DECLARE VARIABLE $orig_g2_cmd = 0 ; (should be converted??)
DECLARE VARIABLE $orig_off2_cmd = 0 ; (should be converted??)
DECLARE VARIABLE $gain1_cmd = 0 ; (should be converted??)
DECLARE VARIABLE $gain2_cmd = 0 ; (should be converted??)
DECLARE VARIABLE $offset1_cmd = 0 ; (should be converted??)
DECLARE VARIABLE $offset2_cmd = 0 ; (should be converted??)

; main body of script
write "@PW Starting procedure $RCSfile: cdh.prc,v $"
write "@PW $Revision: 1.6 $"

;CDH noop for versions
NOOP:
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
write "@PW Expecting command: CDHNOOP"
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

RSTCLR:
;cdhrstclr - clear SBC reset status counter
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt

write "@PW Expecting command: CDHRSTSCLR"
CMD CDH RSTSCLR
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHRSTSCLR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHRSTCLR accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message : CDH RESET STATUS CLEARED "
    write "@PW If message is CDH SBC Reset Clear ERROR - indicates failure. " 
    ask $msg "Was success message generated? (y/n)"
    if $msg = n
        write "@PW <R>Failed: Command CDHRSTSCLR did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> Event message displayed correctly."
    endif
endif

;peek/poke sections
;3 cards 0=IOC1,1=IOC2 2=SSR, 3=SBC,
;mask = 0xffffffff
;addr = 0x38 for IOC,
;     = 0x20006000-0x2000601C for SBC,
;     = 0x1000, 0x1004, 0x1008, or 0x100c for SSR
;value = 0 initial , 0x2400 for poke, then return to 0

write "@PW Beginning peek/poke command section."
write "@PW See FSW EVSMSGSTR (sc_fsw_008 pkt) for peek messages."
ask $env "Cube or Flatsat? (cube,flatsat)"

if $env = cube 
    write "@PW "
    write "@PW IOC cards not available on the CUBE - skipping IOC sections."
    goto SBC
endif
 
IOC1:
write "@PW "
write "@PW This section will test CDH peek/poke commands to IOC1 card"
;IOC cards = 0,1 scratch area register 0x38, any value  
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 0, MASK x#ffffffff ,ADDR x#38
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Did the event message display IOC1 register 0x00000038? (y/n)"
    if $msg = n
        write "@PW <R>Event message not displayed correctly."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> Event message displayed correctly."
    endif
endif

;Poke IOC1 to test value of 0x2400 = 9216 (arbitrary)
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt

CMD CDH POKE with CARD 0, MASK x#ffffffff, ADDR x#38, VALUE x#2400
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif

;Command peek to confirm IOC1 interim value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 0, MASK x#ffffffff ,ADDR x#38 ;
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm value = 0x2400? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif

;Poke to return ioc1 initial value of
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH POKE with CARD 0, MASK x#ffffffff ,ADDR x#38 ,VALUE 0
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif
;Command peek to confirm returned ioc1 value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 0, MASK x#ffffffff ,ADDR x#38 ;
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm value = 0? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif
;conclude ioc1 section 

IOC2:
write "@PW "
write "@PW This section will test CDH peek/poke commands to the IOC2 card"

;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 1, MASK x#ffffffff ,ADDR x#38
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Did the event message display IOC2 register 0x00000038? (y/n)"
    if $msg = n
        write "@PW <R>Event message not displayed correctly."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> Event message displayed correctly."
    endif
endif

;Poke to ioc2 test value of 0x2400 = 9216 (arbitrary)
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH POKE with CARD 1, MASK x#ffffffff ,ADDR x#38 ,VALUE x#2400
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif

;Command peek to confirm ioc2 interim value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 1, MASK x#ffffffff ,ADDR x#38
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm value = 0x2400? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif

;Poke to return ioc2 initial value of 0
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH POKE with CARD 1, MASK x#ffffffff ,ADDR x#38 ,VALUE 0
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif
;Command peek to confirm ioc2 returned value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 1, MASK x#ffffffff ,ADDR x#38
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm IOC2 value = 0? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif
 
SBC:
write "@PW "
write "@PW This section will test CDH peek/poke commands to the SBC card"
;3 cards 0=IOC1,1=IOC2 2=SSR, 3=SBC,
;mask = 0xffffffff
;addr = 0x38 for IOC,
;     = 0x20006000-0x2000601C for SBC,
;     = 0x1000, 0x1004, 0x1008, or 0x100c for SSR
;value = 0 initial , 0x2400 for poke, then return to 0

;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 2, MASK x#ffffffff ,ADDR x#2000601c
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Did the event message display SBC register 0x200601c? (y/n)"
    if $msg = n
        write "@PW <R>Event message not displayed correctly."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> Event message displayed correctly."
    endif
endif

;Poke SBC to test value of 0x2400 = 9216 (arbitrary)
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH POKE with CARD 2, MASK x#ffffffff ,ADDR x#2000601c ,VALUE x#2400  ; TEST!
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif

;Command peek to confirm SBC interim value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 2, MASK x#ffffffff ,ADDR x#2000601c 
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm SBC value = 0x2400? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif

;Poke SBC back to initial value of 0
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH POKE with CARD 2, MASK x#ffffffff ,ADDR x#2000601c ,VALUE 0
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif
;Command peek to confirm SBC at returned value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 2, MASK x#ffffffff ,ADDR x#2000601c 
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm SBC value = 0? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif
; conclude SBC section 

SSR:
write "@PW "
write "@PW This section will test CDH peek/poke commands to the SSR card"
;3 cards 0=IOC1,1=IOC2 2=SSR, 3=SBC,
;mask = 0xffffffff
;addr = 0x38 for IOC,
;     = 0x20006000-0x2000601C for SBC,
;     = 0x1000, 0x1004, 0x1008, or 0x100c for SSR
;value = 0x0 initial , 0x2400 for poke, then return to 0x0

let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 3, MASK x#ffffffff ,ADDR x#1000
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Did the event message display SSR, addr =0x00001000(y/n)"
    if $msg = n
        write "@PW <R>Event message not displayed correctly."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> Event message displayed correctly."
    endif
endif

;Poke SSR to test value of 0x2400 = 9216 (arbitrary)
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH POKE with CARD 3, MASK x#ffffffff, ADDR x#1000, VALUE x#2400
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif

;Command peek to confirm SSR at interim value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 3, MASK x#ffffffff, ADDR x#1000 
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm SSR value = 0x2400? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif

;Poke SSR back to initial value of 0
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH POKE with CARD 3, MASK x#ffffffff ,ADDR x#1000 ,VALUE 0
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPOKE not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPOKE accepted as expected"
endif
;Command peek to confirm SSR at returned value
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH PEEK with CARD 3, MASK x#ffffffff ,ADDR x#1000
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHPEEK not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command CDHPEEK accepted as expected"
    write "@PW "
    write "@PW Confirm Event Message "
    ask $msg "Does the event message confirm SSR value = 0? (y/n)"
    if $msg = n
        write "@PW <R>CDHPOKE did not execute as expected."
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'
    else
         write "@PW <G> CDH POKE confirmed."
    endif
endif
; conclude SSR section

IOCSETGAIN:
;;this section tests the command to set the IOC cards' gain and offset values
;; commented out until conversion from DN to V found 
;;command offset first positive and then negative (+/- 30)

;;capture starting values for restore cmd ; *** FIX TYPE ***
;let $orig_gain1 = cdh gain1
;let $orig_g1_cmd = $orig_gain1
;let $orig_offset1 = cdh offset1
;let $orig_off1_cmd = $orig_offset1
;let $orig_g2 = cdh gain2
;let $orig_g2_cmd = $orig_gain2
;let $orig_offset2 = cdh offset2
;let $orig_off2_cmd = $orig_offset2

;;set up for positive change
;let $gain1_cmd = $orig_gain1 + TBD ; volts/count
;let $gain1_tlm = $gain1_cmd
;let $gain2_cmd = $orig_gain2 +TBD
;let $gain2_tlm = $gain1_cmd
;let $offset1_cmd = $orig_offset1+30.0 ;counts - need how much that is in DN 
;let $offset2_cmd =$orig_offset2 +30.0 ;counts ; need conversion
;let $offset1_tlm = $offset1_cmd
;let $offset2_tlm = $offset2_cmd  

;capture starting counts
;let $cmdacptd = cdh cmdacptcnt
;let $cmdrjctd = cdh cmdrjctcnt
;CMD CDH IOCSETGAIN with GAIN1 $gain1_cmd ,OFFSET1 $offset1_cmd,GAIN2 $gain2_cmd, OFFSET2 $offset2_cmd 
;wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command IOCSETGAIN not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;    write "@PW "
;    write "@PW <G>Command IOCSETGAIN accepted as expected"
;    write "@PW Confirming in telemetry... "
;    if (cdh gain1 = $gain1_tlm) and (cdh gain2 = $gain2_tlm) and &
;       (cdh offset1 = $offset1_tlm) and (cdh offset2 = $offset2_tlm)
;        write "@PW <G> IOCSETGAIN command executed as expected."
;    else
;        write "@PW <R>CDH command IOCSETGAIN did not execute as expected."
;        write "@PW <C>Values in telemetry :"
;        check cdh gain1
;        check cdh offset1
;        check cdh gain2
;        check cdh offset2
;        write "@PW <C> Values Commanded: "
;        write "@PW CDH GAIN1 = ",$gain1_cmd
;        write "@PW CDH OFFSET1 = ",$offset1_cmd
;        write "@PW CDH GAI21 = ",$gain2_cmd
;        write "@PW CDH OFFSET2 = ",$offset2_cmd      
;        write "@PW Document the failure, then type 'GO' to continue"
;        let $test_err = $test_err + 1
;        wait;wait for documentation, then type 'GO'   
;    endif
;endif

;;set up for negative change
;let $gain1_cmd = $orig_gain1 - TBD ; volts/count
;let $gain1_dn = $gain1_cmd
;let $gain2_cmd = $orig_gain2 - TBD
;let $gain2_tlm = $gain1_cmd
;let $offset1_cmd = $orig_offset1-30.0 ;counts - need how much that is in DN 
;let $offset2_cmd =$orig_offset2-30.0 ;counts ; need conversion
;let $offset1_tlm = $offset1_cmd
;let $offset2_tlm = $offset2_cmd  


;;capture starting counts
;let $cmdacptd = cdh cmdacptcnt
;let $cmdrjctd = cdh cmdrjctcnt
;CMD CDH IOCSETGAIN with GAIN1 $gain1_cmd ,OFFSET1 $offset1_cmd,GAIN2 $gain2_cmd, OFFSET2 $offset2_cmd 
;wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command IOCSETGAIN not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;    write "@PW "
;    write "@PW <G>Command IOCSETGAIN accepted as expected"
;    write "@PW Confirming in telemetry... "
;    if (cdh gain1 = $gain1_tlm) and (cdh gain2 = $gain2_tlm) and &
;       (cdh offset1 = $offset1_tlm) and (cdh offset2 = $offset2_tlm)
;        write "@PW <G> IOCSETGAIN command executed as expected."
;    else
;        write "@PW <R>CDH command IOCSETGAIN did not execute as expected."
;        write "@PW <C>Values in telemetry :"
;        check cdh gain1
;        check cdh offset1
;        check cdh gain2
;        check cdh offset2
;        write "@PW <C> Values Commanded: "
;        write "@PW CDH GAIN1 = ",$gain1_cmd
;        write "@PW CDH OFFSET1 = ",$offset1_cmd
;        write "@PW CDH GAI21 = ",$gain2_cmd
;        write "@PW CDH OFFSET2 = ",$offset2_cmd      
;        write "@PW Document the failure, then type 'GO' to continue"
;        let $test_err = $test_err + 1
;        wait;wait for documentation, then type 'GO'   
;    endif
;endif

;;Restore original values
;;capture starting counts
;let $cmdacptd = cdh cmdacptcnt
;let $cmdrjctd = cdh cmdrjctcnt
;CMD CDH IOCSETGAIN with GAIN1 $_orig_g1_cmd ,OFFSET1 $orig_off1_cmd,GAIN2 $orig_g2_cmd, OFFSET2 $orig_off2_cmd 
;wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
;if $$error = time_out
;    write "@PW <R>Failed: Command IOCSETGAIN not accepted"
;    write "@PW Document the failure, then type 'GO' to continue"
;    let $test_err = $test_err + 1
;    wait;wait for documentation, then type 'GO'
;else
;    write "@PW "
;    write "@PW <G>Command IOCSETGAIN accepted as expected"
;    write "@PW Confirming in telemetry... "
;    if (cdh gain1 = $orig_gain1) and (cdh gain2 = $orig_gain2) and &
;       (cdh offset1 = $orig_offset1) and (cdh offset2 = $orig_offset2)
;        write "@PW <G> IOCSETGAIN command executed as expected."
;    else
;        write "@PW <R>CDH command IOCSETGAIN did not execute as expected."
;        write "@PW <C>Values in telemetry :"
;        check cdh gain1
;        check cdh offset1
;        check cdh gain2
;        check cdh offset2
;        write "@PW <C> Values Commanded: "
;        write "@PW CDH GAIN1 = ",$orig_g1_cmd
;        write "@PW CDH OFFSET1 = ",$orig_off1_cmd
;        write "@PW CDH GAI21 = ",$orig_g2_cmd
;        write "@PW CDH OFFSET2 = ",$orig_off2_cmd      
;        write "@PW Document the failure, then type 'GO' to continue"
;        let $test_err = $test_err + 1
;        wait;wait for documentation, then type 'GO'   
;    endif
;endif

RESETS:
;this section clears LZ counters and then CDH counters
;CDHLZ cmds do not affect Unit Manager counts

;TODO : Find out how to send a level zero command to ensure non-zero fields.
;       (only an issue for cube as flatsat setup include LZ commands)

;lzintclr - clear interrupt enable fields 
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH LZINTCLR
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command LZINTCLR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command LZINTCLR accepted as expected"
    write "@PW Confirming in telemetry... "
    if (cdh LZINTEN = 0.0DN); TRUE?? 
        write "@PW <G> Level Zero interrupt enable field cleared."
    else
        write "@PW <R>Level Zero interrupt enable field NOT cleared."
        check cdh LZINTEN
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'   
    endif
endif

;lzstclr - clear LZ command status fields 
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH LZSTCLR
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command LZSTCLR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command LZSTCLR accepted as expected"
    write "@PW Confirming in telemetry... "
    if (cdh LZMEMCMDST = 0.0DN) and (cdh LZCLKCMDST = 0.0DN)
        write "@PW <G> LZ command status fields cleared."
    else
        write "@PW <R>Level Zero command status fields NOT cleared."
        check cdh LZMEMCMDST
        check cdh LZCLKCMDST
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'   
    endif
endif

;lzidclr - clear command ID fields
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
check cdh LZCMDIDST
CMD CDH LZIDCLR
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command LZIDCLR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command LZIDCLR accepted as expected"
    
    write "@PW Confirming in telemetry... "
    if (cdh LZCMDIDST = 0.0DN) 
        write "@PW <G> Level Zero ID status field cleared."
    else
        write "@PW <R>Level Zero ID status fields NOT cleared."
        check cdh LZCMDIDST 
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'   
    endif
endif

;lzcmderrclr - clear level zero command error fields 
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH LZCMDERRCLR
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command LZCMDERRCLR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command LZCMDERRCLR accepted as expected"
    write "@PW Confirming in telemetry... "
    if (cdh LZBADCMDCNT = 0.0DN)
        write "@PW <G> Level Zero ERROR status field cleared."
    else
        write "@PW <R>Level Zero ERROR status fields NOT cleared."
        check cdh LZBADCMDCNT
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'   
    endif
endif

;lzcmdclr - clear level zero command counters 
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
CMD CDH LZCMDCLR
wait ((cdh cmdacptcnt = $cmdacptd + 1.0dn) and (cdh cmdrjctcnt = $cmdrjctd)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command LZCMDCLR not accepted"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>Command LZCMDCLR accepted as expected"
    write "@PW Confirming in telemetry... "
    if (cdh LZCMDCNT = 0.0DN)
        write "@PW <G> Level Zero ERROR status field cleared."
    else
        write "@PW <R>Level Zero command counts NOT cleared."
        check cdh LZCMDCNT
        write "@PW Document the failure, then type 'GO' to continue"
        let $test_err = $test_err + 1
        wait;wait for documentation, then type 'GO'   
    endif
endif

CDHCNTR:
;cdhcntreset - clear cdh command counter
;capture starting counts
let $cmdacptd = cdh cmdacptcnt
let $cmdrjctd = cdh cmdrjctcnt
;preserve rejected counter
if (cdh cmdrjctcnt /= 0.0dn)
    let $testrjct = cdh cmdrjctcnt
endif

write "@PW "
write "@PW Expecting command: CDHCNTRESET"
CMD CDH CNTRESET
wait ((cdh cmdacptcnt = 0.0dn) and (cdh cmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command CDHCNTRESET unsuccessful"
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
let $testrjct = $testrjct + (cdh cmdrjctcnt)
if $testrjct > 0.0dn
    write "@PW <R>Failed: There were rejected commands during this test"
    write "@PW <R>Number of rejected commands:", $testrjct
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
    write "@PW "
    write "@PW <G>No commands rejected during this test"
endif

write "@PW "
write "@PW Completed testing of CDH"
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

endproc; cdh


