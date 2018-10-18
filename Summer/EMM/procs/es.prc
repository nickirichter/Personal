proc es
;*** $Revision: 1.10 $
;*** $Date: 2018/08/28 13:43:27 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/es.prc,v $
;*
;* Created by: EMM Operations Account, Del Sherman
;* Creation Date: 05/23/2018
;*
;*  FUNCTION: Tests commands in ES
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: Do not send ESRESTART yet
;*
;*  OUTLINE: Tests ESNOOP, ESCNTRESET, ESSHELL,
;*           ESQAPP, ESQALL, ESSYSLOGCLR, ESSYSLOGWRT, ESERLOGCLR, 
;*           ESERLOGWRT, ESPERFSTRT, ESPERFSTP, ESFILTER, ESTRGMSK, 
;*           ESSYSLOGOVR, ESRMCDS, ESPOOLTX, ESCDSDMP, ESALLTASKS
;*
;*  INVOKES:
;*  Procedures: eslists.prc, init.prc
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

write "@PW Starting procedure $RCSfile: es.prc,v $"
write "@PW $Revision: 1.10 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn
DECLARE VARIABLE $cmdrjctd = 0.0dn
DECLARE VARIABLE $answer = y y,n;question for eslists.prc
DECLARE VARIABLE $src_seq_ctr = 0.0dn
DECLARE VARIABLE $fmcmdacptd = 0.0dn
DECLARE VARIABLE $fmcmdrjctd = 0.0dn
DECLARE VARIABLE $esperftrigcnt = 0.0dn
DECLARE VARIABLE $esperfdataend = 0.0dn
DECLARE VARIABLE $esperfdatacnt = 0.0dn
DECLARE VARIABLE $tblmempoolhndl_eu = 0.0dn
DECLARE VARIABLE $tblmempoolhndl_real = 0.0
DECLARE VARIABLE $tblmempoolhndl_int = 0

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

;eslists.prc

ask $answer "Run eslists.prc? (y,n)"
if $answer = y
	new_proc eslists
	start eslists
endif


;noop
let $cmdacptd = fsw escmdacptcnt
let $cmdrjctd = fsw escmdrjctcnt
CMD FSW ESNOOP
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

;cntreset

CMD FSW ESCNTRESET
wait ((fsw escmdacptcnt = 0.0dn) and (fsw escmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESCNTRESET unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESCNTRESET accepted as expected"
endif


;esshell

let $cmdacptd = fsw escmdacptcnt
let $src_seq_ctr = PKT_APID_0015 SRC_SEQ_CTR
CMD FSW ESSHELL with STR "pwd", FILE "/ram/ops_test1.txt"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (PKT_APID_0015 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSHELL unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ESSHELL successful"
endif

let $fmcmdacptd = fsw fmcmdacptcnt
let $src_seq_ctr = PKT_APID_0123 SRC_SEQ_CTR
CMD FSW FMINFO with NAME "/ram/ops_test1.txt", CRC ignore
wait ((fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) and (PKT_APID_0123 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSHELL did not create file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESSHELL created file"
endif
if (fsw fmfisize > 0.0dn)
	write "@PW "
	write "@PW <G>Command ESSHELL populated file"
else
    write "@PW <R>Failed: Command ESSHELL did not populate file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $fmcmdacptd = fsw fmcmdacptcnt
CMD FSW FMRM with NAME "/ram/ops_test1.txt"
wait (fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command FMRM successful"
endif


;esqapp

let $cmdacptd = fsw escmdacptcnt
let $src_seq_ctr = PKT_APID_0011 SRC_SEQ_CTR
CMD FSW ESQAPP with NAME "ADC"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (PKT_APID_0011 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESQAPP unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	write "@PW <R>FSW ESCMDACPTCNT: ", fsw escmdacptcnt
	write "@PW <R>PKT_APID_0011 SRC_SEQ_CTR: ", PKT_APID_0011 SRC_SEQ_CTR
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESQAPP successful"
endif

;esqall

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESQALL with FILE "/ram/ops_test2.txt"
wait (fsw escmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for ESQALL unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command counter for ESQALL successful"
endif

let $fmcmdacptd = fsw fmcmdacptcnt
let $src_seq_ctr = PKT_APID_0123 SRC_SEQ_CTR
CMD FSW FMINFO with NAME "/ram/ops_test2.txt", CRC ignore
wait ((fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) and (PKT_APID_0123 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESQALL did not create file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESQALL created file"
endif
if (fsw fmfisize > 0.0dn)
	write "@PW "
	write "@PW <G>Command ESQALL populated file"
else
    write "@PW <R>Failed: Command ESQALL did not populate file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $fmcmdacptd = fsw fmcmdacptcnt
CMD FSW FMRM with NAME "/ram/ops_test2.txt"
wait (fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command FMRM successful"
endif



;essyslogwrt

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESSYSLOGWRT with FILE "/ram/ops_test3.txt"
wait (fsw escmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for ESSYSLOGWRT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command counter for ESSYSLOGWRT successful"
endif

let $fmcmdacptd = fsw fmcmdacptcnt
let $src_seq_ctr = PKT_APID_0123 SRC_SEQ_CTR
CMD FSW FMINFO with NAME "/ram/ops_test3.txt", CRC ignore
wait ((fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) and (PKT_APID_0123 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSYSLOGWRT did not create file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESSYSLOGWRT created file"
endif
if (fsw fmfisize = fsw essyslogsize + 64.0dn)
	write "@PW "
	write "@PW <G>Command ESSYSLOGWRT populated file to the correct size"
else
    write "@PW <R>Failed: Command ESSYSLOGWRT did not populate file to the correct size"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $fmcmdacptd = fsw fmcmdacptcnt
CMD FSW FMRM with NAME "/ram/ops_test3.txt"
wait (fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command FMRM on ops_test3.txt successful"
endif

;essyslogclr

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESSYSLOGCLR
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw essyslogused = 0.0dn) and (fsw essyslogent = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSYSLOGCLR telemetry unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	write "@PW <R>FSW ESCMDACPTCNT: ",fsw escmdacptcnt
	write "@PW <R>FSW ESSYSLOGUSED: ",fsw essyslogused
	write "@PW <R>FSW ESSYSLOGENT: ",fsw essyslogent
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESSYSLOGCLR telemetry successful"
endif

;eserlogwrt

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESERLOGWRT with FILE "/ram/ops_test4.txt"
wait (fsw escmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for ESERLOGWRT unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command counter for ESERLOGWRT successful"
endif

let $fmcmdacptd = fsw fmcmdacptcnt
let $src_seq_ctr = PKT_APID_0123 SRC_SEQ_CTR
CMD FSW FMINFO with NAME "/ram/ops_test4.txt", CRC ignore
wait ((fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) and (PKT_APID_0123 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESERLOGWRT did not create file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESERLOGWRT created file"
endif
if (fsw fmfisize > 0.0dn)
	write "@PW "
	write "@PW <G>Command ESERLOGWRT populated file"
else
    write "@PW <R>Failed: Command ESERLOGWRT did not populate file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $fmcmdacptd = fsw fmcmdacptcnt
CMD FSW FMRM with NAME "/ram/ops_test4.txt"
wait (fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command FMRM on ops_test4.txt successful"
endif

;eserlogclr

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESERLOGCLR
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw eserlogind = 0.0dn) and (fsw eserlogentcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESERLOGCLR telemetry unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	write "@PW <R>FSW ESCMDACPTCNT: ", fsw escmdacptcnt
	write "@PW <R>FSW ESERLOGIND: ", fsw eserlogind
	write "@PW <R>FSW ESERLOGENTCNT: ", fsw eserlogentcnt
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESERLOGCLR telemetry successful"
endif



;Performance Analyzer


;esfilter

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESFILTER with NUM 0, MASK 0
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperffiltmask1 = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESFILTER with NUM 0, MASK 1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESFILTER with NUM 0, MASK 1 successful"
endif

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESFILTER with NUM 1, MASK 10
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperffiltmask2 = 10.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESFILTER with NUM 1, MASK 10 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESFILTER with NUM 1, MASK 10 successful"
endif

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESFILTER with NUM 2, MASK 500
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperffiltmask3 = 500.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESFILTER with NUM 2, MASK 500 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESFILTER with NUM 2, MASK 500 successful"
endif

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESFILTER with NUM 3, MASK 5000
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperffiltmask4 = 5000.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESFILTER with NUM 3, MASK 5000 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESFILTER with NUM 3, MASK 5000 successful"
endif


;estrigger

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESTRIGGER with NUM 0, MASK 0
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperftrigmask1 = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESTRIGGER with NUM 0, MASK 1 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESTRIGGER with NUM 0, MASK 1 successful"
endif

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESTRIGGER with NUM 1, MASK 10
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperftrigmask2 = 10.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESTRIGGER with NUM 1, MASK 10 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESTRIGGER with NUM 1, MASK 10 successful"
endif

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESTRIGGER with NUM 2, MASK 500
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperftrigmask3 = 500.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESTRIGGER with NUM 2, MASK 500 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESTRIGGER with NUM 2, MASK 500 successful"
endif

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESTRIGGER with NUM 3, MASK 5000
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperftrigmask4 = 5000.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESTRIGGER with NUM 3, MASK 5000 unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESTRIGGER with NUM 3, MASK 5000 successful"
endif

;reset filter and trigger masks for nominal performance monitor data collection

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESFILTER with NUM 0, MASK x#FFFFFFF
wait 00:00:02
CMD FSW ESFILTER with NUM 1, MASK x#FFFFFFF
wait 00:00:02
CMD FSW ESFILTER with NUM 2, MASK x#FFFFFFF
wait 00:00:02
CMD FSW ESFILTER with NUM 3, MASK x#FFFFFFF
wait (fsw escmdacptcnt = $cmdacptd + 4.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESFILTER to all F's unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESFILTER to all F's successful"
endif

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESTRIGGER with NUM 0, MASK 0
wait 00:00:02
CMD FSW ESTRIGGER with NUM 1, MASK 0
wait 00:00:02
CMD FSW ESTRIGGER with NUM 2, MASK 0
wait 00:00:02
CMD FSW ESTRIGGER with NUM 3, MASK 0
wait (fsw escmdacptcnt = $cmdacptd + 4.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESTRIGGER to all 0's unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESTRIGGER to all 0's successful"
endif

;esperfstrt

;with mode start

let $cmdacptd = fsw escmdacptcnt

if ((fsw esperftrigcnt = 0.0dn) and (fsw esperfdataend = 0.0dn) and (fsw esperfdatacnt = 0.0dn))
	CMD FSW ESPERFSTRT with MODE START
	wait ((fsw esperftrigcnt = 0.0dn) and (fsw esperfdatastart = 0.0dn) and (fsw esperfdataend > 0.0dn) and (fsw esperfdatacnt > 0.0dn)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command ESPERFSTRT with MODE START telemetry did not zero"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;GO to continue
	else
		write "@PW "
		write "@PW <G>Command ESPERFSTRT with MODE START telemetry zeroed"
	endif
else
	let $esperftrigcnt = fsw esperftrigcnt
	let $esperfdataend = fsw esperfdataend
	let $esperfdatacnt = fsw esperfdatacnt
	CMD FSW ESPERFSTRT with MODE START;commenting out full check in case mode END was run right before
wait (fsw esperfdatastart = 0.0dn) or for $tm_wait
if $$error = time_out
	write "@PW <R>Failed: Command ESPERFSTRT with MODE START telemetry did not zero"
	write "@PW Document the failure, then type 'GO' to continue"
	let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPERFSTRT with MODE START telemetry zeroed"
endif
;	wait ((fsw esperftrigcnt < $esperftrigcnt) and (fsw esperfdatastart = 0.0dn) and (fsw esperfdataend < $esperfdataend) and (fsw esperfdatacnt < $esperfdatacnt)) or for $tm_wait
;	if $$error = time_out
;		write "@PW <R>Failed: Command ESPERFSTRT with MODE START telemetry did not zero"
;		write "@PW Document the failure, then type 'GO' to continue"
;		let $test_err = $test_err + 1
;		wait;GO to continue
;	else
;		write "@PW "
;		write "@PW <G>Command ESPERFSTRT with MODE START telemetry zeroed"
;	endif
endif
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and ((fsw esperfst = WAITING) or (fsw esperfst = TRIGGERED)) and (fsw esperfmode = START)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTRT with MODE START unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPERFSTRT with MODE START successful"
endif

wait 00:00:15;waiting for increasing perf counters to go up enough before grabbing comparison values

;with mode center
let $cmdacptd = fsw escmdacptcnt
let $esperftrigcnt = fsw esperftrigcnt
let $esperfdataend = fsw esperfdataend
let $esperfdatacnt = fsw esperfdatacnt
CMD FSW ESPERFSTRT with MODE CENTER
wait ((fsw esperftrigcnt <= $esperftrigcnt) and (fsw esperfdatastart <= 0.0dn) and (fsw esperfdataend <= $esperfdataend) and (fsw esperfdatacnt <= $esperfdatacnt)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTRT with MODE CENTER telemetry did not zero"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPERFSTRT with MODE CENTER telemetry zeroed"
endif
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and ((fsw esperfst = WAITING) or (fsw esperfst = TRIGGERED)) and (fsw esperfmode = CENTER)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTRT with MODE CENTER unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPERFSTRT with MODE CENTER successful"
endif

wait 00:00:15;waiting for increasing perf counters to go up enough before grabbing comparison values

;with mode end
let $cmdacptd = fsw escmdacptcnt
let $esperftrigcnt = fsw esperftrigcnt
let $esperfdataend = fsw esperfdataend
let $esperfdatacnt = fsw esperfdatacnt
CMD FSW ESPERFSTRT with MODE END
wait ((fsw esperftrigcnt <= $esperftrigcnt) and (fsw esperfdatastart <= 0.0dn) and (fsw esperfdataend <= $esperfdataend) and (fsw esperfdatacnt <= $esperfdatacnt)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTRT with MODE END telemetry did not zero"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPERFSTRT with MODE END telemetry zeroed"
endif
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw esperfmode = END)) or for $tm_wait;removed triggered check because it was happening too quickly with whatever the trigger mask was
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTRT with MODE END unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPERFSTRT with MODE END successful"
endif

;esperfstp


let $cmdacptd = fsw escmdacptcnt
CMD FSW ESPERFSTP with FILE "/ram/ops_test5.h"
wait (fsw escmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for ESPERFSTP unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command counter for ESPERFSTP successful"
endif

let $fmcmdacptd = fsw fmcmdacptcnt
let $src_seq_ctr = PKT_APID_0123 SRC_SEQ_CTR
CMD FSW FMINFO with NAME "/ram/ops_test5.h", CRC ignore
wait ((fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) and (PKT_APID_0123 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTP did not create file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPERFSTP created file"
endif
if (fsw fmfisize > 0.0dn)
	write "@PW "
	write "@PW <G>Command ESPERFSTP populated file"
else
    write "@PW <R>Failed: Command ESPERFSTP did not populate file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $fmcmdacptd = fsw fmcmdacptcnt
CMD FSW FMRM with NAME "/ram/ops_test5.h"
wait (fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command FMRM successful"
endif


;essyslogovr

if (fsw essyslogmode = DIS)
	let $cmdacptd = fsw escmdacptcnt
	CMD FSW ESSYSLOGOVR with MODE OVR
	wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw essyslogmode = OVR)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command ESSYSLOGOVR to mode OVR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;GO to continue
	else
		write "@PW "
		write "@PW <G>Command ESSYSLOGOVR to mode OVR successful"
	endif
	
	let $cmdacptd = fsw escmdacptcnt
	CMD FSW ESSYSLOGOVR with MODE DIS
	wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw essyslogmode = DIS)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command ESSYSLOGOVR to mode DIS unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;GO to continue
	else
		write "@PW "
		write "@PW <G>Command ESSYSLOGOVR to mode DIS successful"
		write "@PW <Y>ESSYSLOGMODE returned to original value"
	endif
else;fsw essyslogmode = OVR
	let $cmdacptd = fsw escmdacptcnt
	CMD FSW ESSYSLOGOVR with MODE DIS
	wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw essyslogmode = DIS)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command ESSYSLOGOVR to mode DIS unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;GO to continue
	else
		write "@PW "
		write "@PW <G>Command ESSYSLOGOVR to mode DIS successful"
	endif
	
	let $cmdacptd = fsw escmdacptcnt
	CMD FSW ESSYSLOGOVR with MODE OVR
	wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (fsw essyslogmode = OVR)) or for $tm_wait
	if $$error = time_out
		write "@PW <R>Failed: Command ESSYSLOGOVR to mode OVR unsuccessful"
		write "@PW Document the failure, then type 'GO' to continue"
		let $test_err = $test_err + 1
		wait;GO to continue
	else
		write "@PW "
		write "@PW <G>Command ESSYSLOGOVR to mode OVR successful"
		write "@PW <Y>ESSYSLOGMODE returned to original value"
	endif
endif


;esrmcds ;can't test without CDS... should be removed


;espooltx


let $cmdacptd = fsw escmdacptcnt
let $src_seq_ctr = PKT_APID_0016 SRC_SEQ_CTR
let $tblmempoolhndl_eu = fsw tblmempoolhndl
let $tblmempoolhndl_real = $tblmempoolhndl_eu
let $tblmempoolhndl_int = $tblmempoolhndl_real
CMD FSW ESPOOLTX with NAME "TBL", HANDLE $tblmempoolhndl_int
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn) and (PKT_APID_0016 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn) and (fsw espoolhndl = fsw tblmempoolhndl)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPOOLTX unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	write "@PW <R>FSW ESCMDACPTCNT: ", fsw escmdacptcnt
	write "@PW <R>PKT_APID_0016 SRC_SEQ_CTR: ", PKT_APID_0016 SRC_SEQ_CTR
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESPOOLTX successful"
	write "@PW FSW ESPOOLSIZE: ", fsw espoolsize
endif


;escdsdmp;this command fails because there is no CDS



;esalltasks


let $cmdacptd = fsw escmdacptcnt
CMD FSW ESALLTASKS with FILE "/ram/ops_test6.txt"
wait (fsw escmdacptcnt = $cmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command counter for ESALLTASKS unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command counter for ESALLTASKS successful"
endif

let $fmcmdacptd = fsw fmcmdacptcnt
let $src_seq_ctr = PKT_APID_0123 SRC_SEQ_CTR
CMD FSW FMINFO with NAME "/ram/ops_test6.txt", CRC ignore
wait ((fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) and (PKT_APID_0123 SRC_SEQ_CTR = $src_seq_ctr + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESALLTASKS did not create file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command ESALLTASKS created file"
endif
if (fsw fmfisize > 0.0dn)
	write "@PW "
	write "@PW <G>Command ESALLTASKS populated file"
else
    write "@PW <R>Failed: Command ESALLTASKS did not populate file"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
endif

let $fmcmdacptd = fsw fmcmdacptcnt
CMD FSW FMRM with NAME "/ram/ops_test6.txt"
wait (fsw fmcmdacptcnt = $fmcmdacptd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command FMRM unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>Command FMRM successful"
endif





FINISH:

write "@PW "
write "@PW Making sure all ops_test files are removed..."

let $fmcmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMRM with NAME "/ram/ops_test1.txt"
wait (fsw fmcmdrjctcnt = $fmcmdrjctd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: File ops_test1.txt was not properly deleted earlier"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>File ops_test1.txt was properly deleted"
endif

let $fmcmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMRM with NAME "/ram/ops_test2.txt"
wait (fsw fmcmdrjctcnt = $fmcmdrjctd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: File ops_test2.txt was not properly deleted earlier"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>File ops_test2.txt was properly deleted"
endif

let $fmcmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMRM with NAME "/ram/ops_test3.txt"
wait (fsw fmcmdrjctcnt = $fmcmdrjctd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: File ops_test3.txt was not properly deleted earlier"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>File ops_test3.txt was properly deleted"
endif

let $fmcmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMRM with NAME "/ram/ops_test4.txt"
wait (fsw fmcmdrjctcnt = $fmcmdrjctd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: File ops_test4.txt was not properly deleted earlier"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>File ops_test4.txt was properly deleted"
endif

let $fmcmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMRM with NAME "/ram/ops_test5.h"
wait (fsw fmcmdrjctcnt = $fmcmdrjctd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: File ops_test5.h was not properly deleted earlier"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>File ops_test5.h was properly deleted"
endif

let $fmcmdrjctd = fsw fmcmdrjctcnt
CMD FSW FMRM with NAME "/ram/ops_test6.txt"
wait (fsw fmcmdrjctcnt = $fmcmdrjctd + 1.0dn) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: File ops_test6.txt was not properly deleted earlier"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>File ops_test6.txt was properly deleted"
endif


;removing FM command rejects
write "@PW "
write "@PW Cleaning up FM command counters..."
CMD FSW FMCNTRESET
wait ((fsw fmcmdacptcnt = 0.0dn) and (fsw fmcmdrjctcnt = 0.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Error sending FMCNTRESET"
    write "@PW Document the failure, then type 'GO' to continue"
	wait;GO to continue
else
	write "@PW "
	write "@PW <G>FM command counters have been zeroed"
endif


write "@PW "
write "@PW Checking command reject counter..."

if fsw escmdrjctcnt > 0.0dn
    write "@PW <R>Failed: There were rejected commands during this test"
    write "@PW <R>Number of rejected commands:", fsw escmdrjctcnt
    write "@PW Document the failure, then type 'GO' to continue"
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>No commands rejected during this test"
endif

write "@PW <C>Ran eslists.prc?", $answer

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

endproc; es

