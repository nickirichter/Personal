proc eslists
;*** $Revision: 1.2 $
;*** $Date: 2018/08/23 17:45:33 $
goto BEGIN
;***************************************************************************
;* PROJECT:
;*
;* $Author: emm-ops $
;* $Source: /msn/software/CVS/fsw_cstol/eslists.prc,v $
;*
;* Created by: EMM Operations Account, Del Sherman
;* Creation Date: 07/03/2018
;*
;*  FUNCTION: Generates and CFDP downlinks files to monitor cFE/OSAL resource usage
;*            Reports utilization diagnostics in event messages with HSUDALL cmd
;*
;*  PARAMETERS: N/A
;*
;*  HAZARDS: N/A
;*
;*  OUTLINE: Sends HSUDALL cmd to send event messages with utilization diagnostics
;*           Makes user turn on CFDP, then invokes shell commands: 
;*           ES_ListResources, ES_ListApps, ES_ListTasks
;*
;*           Starts perf mon with mode CENTER, waits 30 seconds, then downlinks.
;*
;*  INVOKES:
;*  Procedures: N/A
;*  Utilities: N/A
;*
;*  RETURNS: N/A
;*
;*  CALLED BY: es.prc
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

;;no switching logs because this is part of the es.prc test

write "@PW Starting procedure $RCSfile: eslists.prc,v $"
write "@PW $Revision: 1.2 $"

; *** VARIABLE DEFINITIONS ***
DECLARE VARIABLE $tm_wait = 00:00:30
DECLARE VARIABLE $test_err = 0
DECLARE VARIABLE $cmdacptd = 0.0dn

; main body of script

let $cmdacptd = fsw hscmdacptcnt
CMD FSW HSUDALL
wait ((fsw hscmdacptcnt = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command HSUDALL unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command HSUDALL successful"
endif

write "@PW <Y>Start CFDP node"
write "@PW <Y>Go to continue when CFDP node has been started"
wait;go to continue


;ES_ListResources

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESSHELL with STR "ES_ListResources", FILE "/ram/downlink2/esresources.txt"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSHELL ListResources unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ESSHELL ListResources successful"
endif

;ES_ListApps

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESSHELL with STR "ES_ListApps", FILE "/ram/downlink2/esapps.txt"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSHELL ListApps unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ESSHELL ListApps successful"
endif

;ES_ListTasks

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESSHELL with STR "ES_ListTasks", FILE "/ram/downlink2/estasks.txt"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESSHELL ListTasks unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ESSHELL ListTasks successful"
endif

;ESperfmon_center

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESPERFSTRT with MODE CENTER
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTRT mode CENTER unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ESPERFSTRT mode CENTER successful"
endif

wait 00:00:30;wait for perf mon to gather sufficient data

let $cmdacptd = fsw escmdacptcnt
CMD FSW ESPERFSTP with FILE "/ram/downlink2/perfmon_center.h"
wait ((fsw escmdacptcnt = $cmdacptd + 1.0dn)) or for $tm_wait
if $$error = time_out
    write "@PW <R>Failed: Command ESPERFSTP unsuccessful"
    write "@PW Document the failure, then type 'GO' to continue"
    let $test_err = $test_err + 1
    wait;wait for documentation, then type 'GO'
else
	write "@PW "
	write "@PW <G>Command ESPERFSTP successful"
endif

FINISH:

write "@PW "
write "@PW <C>Grab 4 files downlinked by CFDP and include in regression report"
write "@PW Go to continue after grabbing files"
wait;go to continue

if $test_err = 0
	write "@PW <G>Total number of errors: ", $test_err
else
	write "@PW <R>Total number of errors: ", $test_err
endif

endproc; eslists

