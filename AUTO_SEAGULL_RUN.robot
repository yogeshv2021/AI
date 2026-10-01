*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process

*** Variables ***

*** Keyword ***

SEAGULL SCENARIO PREPARE
    [Timeout]    2 minute
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION_TYPE}==${2}    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Copy File    ${SEAGULL_SCENPATH}${/}${SEAGULL_SCENARIO_NAME}.xml    ${SEAGULL_SCENPATH}${/}${DEFAULT_SEAGULL_SCENARIO}.xml
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION_TYPE}==${2}    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run    perl -pi -e 's/SESSID/${SEAGULL_SESSION_ID}/g' ${SEAGULL_SCENPATH}${/}${DEFAULT_SEAGULL_SCENARIO}.xml
    ${SCENFILE}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION_TYPE}==${1}    Set Variable    ${TEST_NAME}.xml
    ...    ELSE    Set Variable    ${DEFAULT_SEAGULL_SCENARIO}.xml
    ${CONFFILE}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION_TYPE}==${1}    Set Variable    ${TEST_NAME}.xml
    ...    ELSE    Set Variable    ${SEAGULL_CONFIG_NAME}.xml
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION_TYPE}==${2}    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Copy File    ${SEAGULL_FILEPATH}${/}${TEST_NAME}.csv    ${SEAGULL_FILEPATH}${/}Temp.csv
    [Return]    ${SCENFILE}    ${CONFFILE}

RUN SEAGULL SCENARIO
    [Arguments]    ${TESTCASE_ID}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    [Timeout]    3 minute 01 seconds
    Run Keyword If    '${msgchk}'=='YES'    set test variable    ${mesgchk}    "-msgcheck"
    ...    ELSE    set test variable    ${mesgchk}    ${msgno}
    Run    ${SEGENV}
    Append To File    ${framework_log_file}    Starting Seagull State Machine\n
    ${rc}=    Process.Start Process    ${PROGDIR}${/}seagull    -conf    ${SEAGULL_confpath}${/}${CONFIG_FILE}    -dico    ${SEAGULL_DICO}
    ...    -scen    ${SEAGULL_SCENPATH}${/}${SCENARIO_FILE}    -log    ${SEAGULL_LOGPATH}${/}${TEST_NAME}.txt    -llevel    A
    ...    -bg    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=False    alias=${SEG_PROCESS}    stderr=${SEAGULL_STDERR_FILE}    stdout=stdout
    log    Seagull Exit status ${rc}
    Sleep    1s
    ${result}=    Process.Wait For Process    ${SEG_PROCESS}    timeout=20 secs    on_timeout=terminate
    [Return]    ${result}

VERIFY SEAGULL SCENARIO STATUS
    [Arguments]    ${TESTCASE_ID}
    [Timeout]    3 minute 01 seconds
    ${SEAG_PID} =    OperatingSystem.Grep File    ${SEAGULL_STDERR_FILE}    ${SEAGULL_PIDGREP}
    ${SEAG_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SEAG_PID}    ]
    @{words} =    Split String    ${SEAG_EXT_PID}    [
    Set Test Variable    ${SEG_PID}    ${words[-1]}
    FOR    ${index}    IN RANGE    ${SEAGULL_TIMEOUT}
    ${rc}    ${seagull_greppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SEG_PID} | grep -v grep | awk '{ print $2 }'
    Log    ${seagull_greppid}
    ${rc}=    Process.Is Process Running    ${SEG_PROCESS}
    Exit For Loop If    "${seagull_greppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SEAGULL_TIMEOUT} - 1
    Run Keyword If    ${index}==${y}    Terminate Process    ${SEG_PROCESS}
    Sleep    ${SEAGULL_SLEEP}s
    END
    Log    SEAGULL EXECUTION COMPLETED PID is ${SEG_PID}
    Append To File    ${framework_log_file}    Stopping Seagull State Machine\n
    Append To File    ${framework_log_file}    SEAGULL EXECUTION COMPLETED PID is ${SEG_PID}\n

GET SEAGULL RESULT
    [Arguments]    ${TESTCASE_ID}
    [Timeout]    1 minute 01 seconds
    ${seagull_log}=    BuiltIn.Run Keyword And Continue On Failure    Run    ls -rt ${SEAGULL_LOGPATH}${/}${TESTCASE_ID}* | tail -1
    ${ret} =    BuiltIn.Run Keyword And Continue On Failure    Grep File    ${seagull_log}    ${GREP_STRING}
    ${scen_result}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    Should Contain    ${ret}    passed
    log    ${scen_result}
    BuiltIn.Run Keyword And Continue On Failure    COPY SEAGULL SCENARIO LOGS    ${TEST_NAME}
    [Return]    ${scen_result}

COPY SEAGULL SCENARIO LOGS
    [Arguments]    ${TESTCASE_ID}
    [Timeout]    1 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Copy File    ${SEAGULL_LOGPATH}${/}${TEST_NAME}*    ${result_path}${/}
