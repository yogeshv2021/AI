*** Settings ***
Library           Collections
Library           SSHLibrary    5min
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process

*** Variables ***

*** Keyword ***
START AUTO
    [Documentation]    This Keyword Extracts Test Data from Test Setup File and calls RUN TEST SCENARIO Keyword.
    [Timeout]    5 minute 50 seconds
    ${SEAGULL_STATE_MACHINE}=    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${1}    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    SEAGULL SCENARIO PREPARE
    ${SCEN_STATUS}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${TC_RESULT}=    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}
    ...    RUN TEST SCENARIO OLD    ${TC_CONF}    ${TC_SCEN}    ${TIMESTAMP}
    ...    ELSE    RUN TEST SCENARIO    ${SEAGULL_STATE_MACHINE}    ${SEAGULL_STATE_MACHINE}    ${TIMESTAMP}   
    log    TEST_RESULT=${TC_RESULT}
    log    Autostop_Status=${autostop_status}
    log    SCEN_STATUS=${SCEN_STATUS}
    log    POSTDB_STATUS=${postdb_status}
    log    CDR_STATUS=${cdr_status}
    log    PCAP_STATUS=${pcap_status}
    log    SOAP_STATUS=${http_status}
    Set Test Variable    ${TESTCASE_SCEN_STATUS}    ${SCEN_STATUS}
    Set Test Variable    ${TESTCASE_POSTDB_STATUS}    ${postdb_status}
    Set Test Variable    ${TESTCASE_CDR_STATUS}    ${cdr_status}
    Set Test Variable    ${TESTCASE_PCAP_STATUS}    ${pcap_status}
    Set Test Variable    ${TESTCASE_RESULT}    ${TC_RESULT}
    Set Test Variable    ${TESTCASE_SHELLPRE_STATUS}    ${shellpre_status}
    Set Test Variable    ${TESTCASE_SHELLON_STATUS}    ${shelloncall_status}
    Set Test Variable    ${TESTCASE_SHELLPOST_STATUS}    ${shellpost_status}
    Set Test Variable    ${TESTCASE_HTTP_STATUS}    ${http_status}
    Run Keyword if    '${TC_RESULT}'!='PASS'    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}    BuiltIn.Run Keyword And Continue On Failure    Execute Automation DIRCOPY    ${TEST_NAME}    ${TIMESTAMP}
    Run Keyword if    '${TC_RESULT}'!='PASS'    Builtin.Fail    TC_FAIL
    [Return]    ${TC_RESULT}


START AUTO MSISDN
    [Documentation]    This Keyword Extracts Test Data from Test Setup File and calls RUN TEST SCENARIO Keyword.
    [Timeout]    5 minute 50 seconds
    ${SEAGULL_STATE_MACHINE}=    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${1}    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    SEAGULL SCENARIO PREPARE
    ${SCEN_STATUS}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${TC_RESULT}=    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}
    ...    RUN TEST SCENARIO OLD    ${TC_CONF}    ${TC_SCEN}    ${TIMESTAMP}
    ...    ELSE    RUN TEST SCENARIO MSISDN    ${SEAGULL_STATE_MACHINE}    ${SEAGULL_STATE_MACHINE}    ${TIMESTAMP}
    log    TEST_RESULT=${TC_RESULT}
    log    Autostop_Status=${autostop_status}
    log    SCEN_STATUS=${SCEN_STATUS}
    log    POSTDB_STATUS=${postdb_status}
    log    CDR_STATUS=${cdr_status}
    log    PCAP_STATUS=${pcap_status}
    log    SOAP_STATUS=${http_status}
    Set Test Variable    ${TESTCASE_SCEN_STATUS}    ${SCEN_STATUS}
    Set Test Variable    ${TESTCASE_POSTDB_STATUS}    ${postdb_status}
    Set Test Variable    ${TESTCASE_CDR_STATUS}    ${cdr_status}
    Set Test Variable    ${TESTCASE_PCAP_STATUS}    ${pcap_status}
    Set Test Variable    ${TESTCASE_RESULT}    ${TC_RESULT}
    Set Test Variable    ${TESTCASE_SHELLPRE_STATUS}    ${shellpre_status}
    Set Test Variable    ${TESTCASE_SHELLON_STATUS}    ${shelloncall_status}
    Set Test Variable    ${TESTCASE_SHELLPOST_STATUS}    ${shellpost_status}
    Set Test Variable    ${TESTCASE_HTTP_STATUS}    ${http_status}
    Run Keyword if    '${TC_RESULT}'!='PASS'    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}    BuiltIn.Run Keyword And Continue On Failure    Execute Automation DIRCOPY    ${TEST_NAME}    ${TIMESTAMP}
    Run Keyword if    '${TC_RESULT}'!='PASS'    Builtin.Fail    TC_FAIL
    [Return]    ${TC_RESULT}


RUN TEST SCENARIO
    [Arguments]    ${CONFIG_FILE}    ${SCENARIO_FILE}    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    ${http_status}=    BuiltIn.Run Keyword If    ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${xml_status}=    BuiltIn.Run Keyword If    ${XML_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    XML
    log    ${xml_status}
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${pcap_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${cdr_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','NULL','None'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None'] and '${http_status}' in['Pass','None','DONE']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${TC_RESULT}


RUN TEST SCENARIO OLD    [Arguments]    ${CONFIG_FILE}    ${SCENARIO_FILE}    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    ${predb_status}=     BuiltIn.Run Keyword And Continue On Failure    Execute DB Precondition    ${TEST_NAME}    ${TIMESTAMP}
    ${shellpre_status}=     BuiltIn.Run Keyword And Continue On Failure    Execute Automation SHELL_PRE    ${TEST_NAME}    ${TIMESTAMP}
    BuiltIn.Run Keyword And Continue On Failure    Execute Automation Start    ${TEST_NAME}    ${TIMESTAMP}
    ${SCEN_STATUS}=    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    ${oncalldb_status}=    BuiltIn.Run Keyword And Continue On Failure    Execute DB Oncallcondition    ${TEST_NAME}    ${TIMESTAMP}
    ${shelloncall_status}=    BuiltIn.Run Keyword And Continue On Failure    Execute Automation ShellOncall    ${TEST_NAME}    ${TIMESTAMP}
    Sleep    ${TC_POSTTIME}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    ${autostop_status}=    BuiltIn.Run Keyword And Continue On Failure    Execute Automation Stop    ${TEST_NAME}    ${TIMESTAMP}
    ${shellpost_status}=     BuiltIn.Run Keyword And Continue On Failure    Execute Automation SHELL_POST    ${TEST_NAME}    ${TIMESTAMP}
    ${pcap_status}=     BuiltIn.Run Keyword And Continue On Failure    Execute Automation PCAP    ${TEST_NAME}    ${TIMESTAMP}
    ${cdr_status}=    BuiltIn.Run Keyword And Continue On Failure    Execute Automation CDR    ${TEST_NAME}    ${TIMESTAMP}
    ${postdb_status}=     BuiltIn.Run Keyword And Continue On Failure    Execute DB Postcondition    ${TEST_NAME}    ${TIMESTAMP}
    ${SCEN_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${http_status}=    Set Variable    ${None}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If	'${SCEN_RESULT}'in['True','NULL'] and '${cdr_status}'in['PASS','NULL'] and '${pcap_status}'in['PASS','NULL'] and '${autostop_status}'in['pass','null'] and '${postdb_status}'in['pass','null']    PASS    FAIL
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${TC_RESULT}


RUN TEST SCENARIO MSISDN
    [Arguments]    ${CONFIG_FILE}    ${SCENARIO_FILE}    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    ${http_status}=    BuiltIn.Run Keyword If    ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${pcap_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${cdr_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION WITH MSISDN
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','NULL','None'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None'] and '${http_status}' in['Pass','None','DONE']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${TC_RESULT}


START MGTS AUTO    [Arguments]    ${SCENARIO_NAME}
    [Documentation]    This Keyword Extracts Test Data from Test Setup File and calls RUN TEST SCENARIO Keyword.
    [Timeout]    10 minute 50 seconds
    Set Test Variable    ${TC_ID}    ${SCENARIO_NAME}
    ${SCEN_STATUS}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${TC_RESULT}=    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}
    ...    RUN TEST SCENARIO OLD    ${TC_CONF}    ${TC_SCEN}    ${TIMESTAMP}
    ...    ELSE    RUN MGTS TEST SCENARIO    ${TIMESTAMP}   
    log    TEST_RESULT=${TC_RESULT}
    log    Autostop_Status=${autostop_status}
    log    SCEN_STATUS=${SCEN_STATUS}
    log    POSTDB_STATUS=${postdb_status}
    log    CDR_STATUS=${cdr_status}
    log    PCAP_STATUS=${pcap_status}
    Set Test Variable    ${TESTCASE_SCEN_STATUS}    ${SCEN_STATUS}
    Set Test Variable    ${TESTCASE_POSTDB_STATUS}    ${postdb_status}
    Set Test Variable    ${TESTCASE_CDR_STATUS}    ${cdr_status}
    Set Test Variable    ${TESTCASE_PCAP_STATUS}    ${pcap_status}
    Set Test Variable    ${TESTCASE_RESULT}    ${TC_RESULT}
    Set Test Variable    ${TESTCASE_SHELLPRE_STATUS}    ${shellpre_status}
    Set Test Variable    ${TESTCASE_SHELLON_STATUS}    ${shelloncall_status}
    Set Test Variable    ${TESTCASE_SHELLPOST_STATUS}    ${shellpost_status}
    Run Keyword if    '${TC_RESULT}'!='PASS'    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}    BuiltIn.Run Keyword And Continue On Failure    Execute Automation DIRCOPY    ${TEST_NAME}    ${TIMESTAMP}
    Run Keyword if    '${TC_RESULT}'!='PASS'    Builtin.Fail    TC_FAIL
    [Return]    ${TC_RESULT}

RUN MGTS TEST SCENARIO
    [Arguments]    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    10 minute 01 seconds
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN MGTS State Machine
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    Verify MGTS State Machine
    ${SCEN_RESULT}    ${mgts_fail}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    MGTS State Machine PASS FAIL SET
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    MGTS State Machine STOP
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${pcap_status}=        BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${cdr_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    MGTS LOG COPY
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','1','None'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None']    PASS    FAIL
    ${SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','1','None']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCENARIO_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${TC_RESULT}

START IMS AUTO
    [Documentation]    This Keyword Extracts Test Data from Test Setup File and calls RUN TEST SCENARIO Keyword.
    [Timeout]    5 minute 50 seconds
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${KILL_OLD_SIPP_SEAGULL_SCENARIOS}==${1}    Run    ps -ef | egrep -i 'SIPP|SEAGULL' | egrep 'AUTO_IMS|AUTO_VoLTE|IMS_PCRF' | awk '{print$2}' | xargs kill -9
    ${SEAGULL_STATE_MACHINE}    ${SEAGULL_CONFIG_FILE}=    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${1}    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    SEAGULL SCENARIO PREPARE
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    Set Test Variable    ${SEAGULL_SCENARIO_FILE}    ${SEAGULL_STATE_MACHINE}
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    Set Test Variable    ${SEAGULL_CONFIGURATION_FILE}    ${SEAGULL_CONFIG_FILE}
    ${SCEN_STATUS}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${protocol_status}    ${SEAGULL_RESULT}    ${TC_RESULT}=    BuiltIn.Run Keyword If    ${CLIENT_SERVER_SCENARIO}==1
    ...    RUN SIPP CLIENT SERVER SCENARIO    ${SEAGULL_CONFIG_FILE}    ${SEAGULL_STATE_MACHINE}    ${TIMESTAMP}
    ...    ELSE IF    ${CLIENT_SERVER_SCENARIO}==${4}    RUN SIPP CLIENT THREE SERVER SCENARIO    ${SEAGULL_CONFIG_FILE}    ${SEAGULL_STATE_MACHINE}    ${TIMESTAMP}
    ...    ELSE IF    ${CLIENT_SERVER_SCENARIO}>${1}    RUN SIPP CLIENT TWO SERVER SCENARIO    ${SEAGULL_CONFIG_FILE}    ${SEAGULL_STATE_MACHINE}    ${TIMESTAMP}
    ...    ELSE    RUN SIPP    ${TIMESTAMP}
    log    TEST_RESULT=${TC_RESULT}
    log    Autostop_Status=${autostop_status}
    log    SCEN_STATUS=${SCEN_STATUS}
    log    POSTDB_STATUS=${postdb_status}
    log    CDR_STATUS=${cdr_status}
    log    PCAP_STATUS=${pcap_status}
    log    SOAP_STATUS=${http_status}
    log    PROTOCOL_STATUS=${protocol_status}
    Set Test Variable    ${TESTCASE_SCEN_STATUS}    ${SCEN_STATUS}
    Set Test Variable    ${TESTCASE_POSTDB_STATUS}    ${postdb_status}
    Set Test Variable    ${TESTCASE_CDR_STATUS}    ${cdr_status}
    Set Test Variable    ${TESTCASE_PCAP_STATUS}    ${pcap_status}
    Set Test Variable    ${TESTCASE_RESULT}    ${TC_RESULT}
    Set Test Variable    ${TESTCASE_SHELLPRE_STATUS}    ${shellpre_status}
    Set Test Variable    ${TESTCASE_SHELLON_STATUS}    ${shelloncall_status}
    Set Test Variable    ${TESTCASE_SHELLPOST_STATUS}    ${shellpost_status}
    Set Test Variable    ${TESTCASE_HTTP_STATUS}    ${http_status}
    Set Test Variable    ${TESTCASE_PROTOCOL_STATUS}    ${protocol_status}
    Set Test Variable    ${TESTCASE_SEAGULL_STATUS}    ${SEAGULL_RESULT}
    Run Keyword if    '${TC_RESULT}'!='PASS'    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}    BuiltIn.Run Keyword And Continue On Failure    Execute Automation DIRCOPY    ${TEST_NAME}    ${TIMESTAMP}
    Run Keyword if    '${TC_RESULT}'!='PASS'    Builtin.Fail    TC_FAIL
    [Return]    ${TC_RESULT}

START IMS REMOTE AUTO
    [Documentation]    This Keyword Extracts Test Data from Test Setup File and calls RUN TEST SCENARIO Keyword.
    [Timeout]    5 minute 50 seconds
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${KILL_OLD_SIPP_SEAGULL_SCENARIOS}==${1}    Run    ps -ef | egrep -i 'SIPP|SEAGULL' | egrep 'AUTO_IMS|AUTO_VoLTE|IMS_PCRF' | awk '{print$2}' | xargs kill -9
    ${SEAGULL_STATE_MACHINE}    ${SEAGULL_CONFIG_FILE}=    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${1}    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    SEAGULL SCENARIO PREPARE
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    Set Test Variable    ${SEAGULL_SCENARIO_FILE}    ${SEAGULL_STATE_MACHINE}
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    Set Test Variable    ${SEAGULL_CONFIGURATION_FILE}    ${SEAGULL_CONFIG_FILE}
    ${SCEN_STATUS}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${protocol_status}    ${SEAGULL_RESULT}    ${TC_RESULT}=    BuiltIn.Run Keyword    RUN SIPP INT EXT CLIENT SERVER SCENARIO    ${SEAGULL_CONFIG_FILE}    ${SEAGULL_STATE_MACHINE}    ${TIMESTAMP}
    log    TEST_RESULT=${TC_RESULT}
    log    Autostop_Status=${autostop_status}
    log    SCEN_STATUS=${SCEN_STATUS}
    log    POSTDB_STATUS=${postdb_status}
    log    CDR_STATUS=${cdr_status}
    log    PCAP_STATUS=${pcap_status}
    log    SOAP_STATUS=${http_status}
    log    PROTOCOL_STATUS=${protocol_status}
    Set Test Variable    ${TESTCASE_SCEN_STATUS}    ${SCEN_STATUS}
    Set Test Variable    ${TESTCASE_POSTDB_STATUS}    ${postdb_status}
    Set Test Variable    ${TESTCASE_CDR_STATUS}    ${cdr_status}
    Set Test Variable    ${TESTCASE_PCAP_STATUS}    ${pcap_status}
    Set Test Variable    ${TESTCASE_RESULT}    ${TC_RESULT}
    Set Test Variable    ${TESTCASE_SHELLPRE_STATUS}    ${shellpre_status}
    Set Test Variable    ${TESTCASE_SHELLON_STATUS}    ${shelloncall_status}
    Set Test Variable    ${TESTCASE_SHELLPOST_STATUS}    ${shellpost_status}
    Set Test Variable    ${TESTCASE_HTTP_STATUS}    ${http_status}
    Set Test Variable    ${TESTCASE_PROTOCOL_STATUS}    ${protocol_status}
    Set Test Variable    ${TESTCASE_SEAGULL_STATUS}    ${SEAGULL_RESULT}
    Run Keyword if    '${TC_RESULT}'!='PASS'    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}    BuiltIn.Run Keyword And Continue On Failure    Execute Automation DIRCOPY    ${TEST_NAME}    ${TIMESTAMP}
    Run Keyword if    '${TC_RESULT}'!='PASS'    Builtin.Fail    TC_FAIL
    [Return]    ${TC_RESULT}


RUN SIPP
    [Arguments]    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    BuiltIn.Run Keyword And Continue On Failure    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${Actual_INPUT_PATH}${suite_name}/${TEST_NAME}.txt
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    ${SEAGULL_STATUS}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${SEAGULL_CONFIGURATION_FILE}    ${SEAGULL_SCENARIO_FILE}
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP SCENARIO    ${STATE_MACHINE}
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP SCENARIO STATUS
    ${http_status}=    BuiltIn.Run Keyword If    ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${xml_status}=    BuiltIn.Run Keyword If    ${XML_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    XML
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${pcap_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP RESULT    ${STATE_MACHINE}
    ${SIPP_STAT_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP STAT RESULT    ${STATE_MACHINE}
    Sleep    2s    Wait for a POST QUERY Execution
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and "${SCENARIO_EXECUTION}"=="${1}"    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP SCENARIO    ${STATE_MACHINE}
    ...    ELSE IF    "${SCENARIO_EXECUTION}"=="${1}"    Set Variable    ${SCEN_STATUS} 
    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    ...    ELSE IF    "${SCENARIO_EXECUTION}"=="${1}"    Set Variable    ${shelloncall_status} 
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP SCENARIO STATUS
    ${http_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${xml_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${XML_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    XML
    ...    ELSE IF    ${XML_Validation}==${1}    Set Variable    ${xml_status} 
    ${autostop_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ...    ELSE IF    ${LOGGER_Validation}==${1}    Set Variable    ${autostop_status} 
    ${shellpost_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ...    ELSE IF    ${test_file_length}!=${0}    Set Variable    ${shellpost_status} 
    ${pcap_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ...    ELSE IF    ${test_file_length}!=${0}    Set Variable    ${pcap_status} 
    ${cdr_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ...    ELSE IF    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    ...    ELSE IF    ${test_file_length}!=${0}    Set Variable    ${postdb_status} 
    ${shellpost_status}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ...    ELSE IF    ${test_file_length}!=${0}    Set Variable    ${shellpost_status} 
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    "${SIPP_STAT_RESULT}"!="True" and ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP RESULT    ${STATE_MACHINE}
    ...    ELSE IF    "${SCENARIO_EXECUTION}"=="${1}"    Set Variable    ${SCEN_RESULT} 
    ${protocol_status}=    BuiltIn.Run Keyword If    ${PROTOCOL_VALIDATION}==${1}    BuiltIn.Run Keyword And Continue On Failure    PCAP PROTOCOL VALIDATION
    ${SEAGULL_RESULT}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','NULL','None','PASS'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None'] and '${shellpost_status}'in['PASS','NONE','None'] and '${http_status}'in['Pass','None','DONE'] and '${protocol_status}'in['PASS','NONE','None'] and '${SEAGULL_RESULT}'in['True','NULL','None']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${protocol_status}    ${SEAGULL_RESULT}    ${TC_RESULT}

RUN SIPP CLIENT SERVER SCENARIO
    [Arguments]    ${CONFIG_FILE}    ${SCENARIO_FILE}    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    BuiltIn.Run Keyword And Continue On Failure    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${Actual_INPUT_PATH}${suite_name}/${TEST_NAME}.txt
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    ${SEAGULL_STATUS}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP CLIENT SERVER    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT SRVER SCENARIO STATUS
    ${http_status}=    BuiltIn.Run Keyword If    ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${xml_status}=    BuiltIn.Run Keyword If    ${XML_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    XML
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${pcap_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${cdr_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT SERVER RESULT    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    "${SCEN_RESULT}"!="PASS"    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP CLIENT SERVER    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}
    ${protocol_status}=    BuiltIn.Run Keyword If    ${PROTOCOL_VALIDATION}==${1}    BuiltIn.Run Keyword And Continue On Failure    PCAP PROTOCOL VALIDATION
    ${SEAGULL_RESULT}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','NULL','None','PASS'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None'] and '${shellpost_status}'in['PASS','NONE','None'] and '${http_status}' in['Pass','None','DONE'] and '${protocol_status}'in['PASS','NONE','None'] and '${SEAGULL_RESULT}'in['True','NULL','None']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${protocol_status}    ${SEAGULL_RESULT}    ${TC_RESULT}

RUN SIPP CLIENT TWO SERVER SCENARIO
    [Arguments]    ${CONFIG_FILE}    ${SCENARIO_FILE}    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    BuiltIn.Run Keyword And Continue On Failure    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${Actual_INPUT_PATH}${suite_name}/${TEST_NAME}.txt
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    ${SEAGULL_STATUS}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${2}    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP CLIENT TWO SERVER    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${SERVER_STATE_MACHINE_TWO}
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${3}  BuiltIn.Run Keyword And Continue On Failure    RUN SIPP TWO CLIENT ONE SERVER    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${CLIENT_STATE_MACHINE_TWO}
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${2}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT TWO SRVER SCENARIO STATUS
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${3}  BuiltIn.Run Keyword And Continue On Failure    VERIFY TWO SIPP CLIENT ONE SRVER SCENARIO STATUS
    ${http_status}=    BuiltIn.Run Keyword If    ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${xml_status}=    BuiltIn.Run Keyword If    ${XML_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    XML
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${pcap_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${cdr_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${2}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT TWO SERVER RESULT    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${SERVER_STATE_MACHINE_TWO}
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${3}  BuiltIn.Run Keyword And Continue On Failure    VERIFY TWO SIPP CLIENT ONE SERVER RESULT    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${CLIENT_STATE_MACHINE_TWO}
    ${protocol_status}=    BuiltIn.Run Keyword If    ${PROTOCOL_VALIDATION}==${1}    BuiltIn.Run Keyword And Continue On Failure    PCAP PROTOCOL VALIDATION
    ${SEAGULL_RESULT}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','NULL','None','PASS'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None'] and '${shellpost_status}'in['PASS','NONE','None'] and '${http_status}' in['Pass','None','DONE'] and '${protocol_status}'in['PASS','NONE','None'] and '${SEAGULL_RESULT}'in['True','NULL','None']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${protocol_status}    ${SEAGULL_RESULT}    ${TC_RESULT}



RUN SIPP CLIENT THREE SERVER SCENARIO
    [Arguments]    ${CONFIG_FILE}    ${SCENARIO_FILE}    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    BuiltIn.Run Keyword And Continue On Failure    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${Actual_INPUT_PATH}${suite_name}/${TEST_NAME}.txt
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    ${SEAGULL_STATUS}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${2}    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP CLIENT TWO SERVER    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${SERVER_STATE_MACHINE_TWO}
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${3}  BuiltIn.Run Keyword And Continue On Failure    RUN SIPP TWO CLIENT ONE SERVER    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${CLIENT_STATE_MACHINE_TWO}
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${4}  BuiltIn.Run Keyword And Continue On Failure    RUN SIPP ONE CLIENT THREE SERVER    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${SERVER_STATE_MACHINE_TWO}     ${SERVER_STATE_MACHINE_THREE}
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${2}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT TWO SRVER SCENARIO STATUS
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${3}  BuiltIn.Run Keyword And Continue On Failure    VERIFY TWO SIPP CLIENT ONE SRVER SCENARIO STATUS
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${4}  BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT THREE SRVER SCENARIO STATUS
    ${http_status}=    BuiltIn.Run Keyword If    ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${xml_status}=    BuiltIn.Run Keyword If    ${XML_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    XML
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${pcap_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${cdr_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${2}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT TWO SERVER RESULT    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${SERVER_STATE_MACHINE_TWO}
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${3}  BuiltIn.Run Keyword And Continue On Failure    VERIFY TWO SIPP CLIENT ONE SERVER RESULT    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${CLIENT_STATE_MACHINE_TWO}
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${CLIENT_SERVER_SCENARIO}==${4}  BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP CLIENT THREE SERVER RESULT    ${CLIENT_STATE_MACHINE}    ${SERVER_STATE_MACHINE}    ${SERVER_STATE_MACHINE_TWO}    ${SERVER_STATE_MACHINE_THREE}
    ${protocol_status}=    BuiltIn.Run Keyword If    ${PROTOCOL_VALIDATION}==${1}    BuiltIn.Run Keyword And Continue On Failure    PCAP PROTOCOL VALIDATION
    ${SEAGULL_RESULT}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','NULL','None','PASS'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None'] and '${shellpost_status}'in['PASS','NONE','None'] and '${http_status}' in['Pass','None','DONE'] and '${protocol_status}'in['PASS','NONE','None'] and '${SEAGULL_RESULT}'in['True','NULL','None']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${protocol_status}    ${SEAGULL_RESULT}    ${TC_RESULT}



RUN SIPP INT EXT CLIENT SERVER SCENARIO
    [Arguments]    ${CONFIG_FILE}    ${SCENARIO_FILE}    ${TIMESTAMP}
    [Documentation]    This Keyword Calls all Test Steps.
    [Timeout]    5 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    BuiltIn.Run Keyword And Continue On Failure    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${Actual_INPUT_PATH}${suite_name}/${TEST_NAME}.txt
    TEST START
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${PRE_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    PRECONDITION
    ${shellpre_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_PRE_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL PRECONDITION
    BuiltIn.Run Keyword And Continue On Failure    PREPROCESSING
    ${SEAGULL_STATUS}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SEAGULL SCENARIO    ${TEST_NAME}    ${CONFIG_FILE}    ${SCENARIO_FILE}
    ${SCEN_STATUS}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${REMOTE_EXECUTION}==${0}    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP INT CLIENT SERVER    &{STATE_MACHINE}
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${REMOTE_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    RUN SIPP EXT CLIENT SERVER    &{STATE_MACHINE}
    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${ON_CALL_DB_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    ONCALLDBCONDITION
    ${shelloncall_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_ON_CALL_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL ON CALL CONDITION
    Sleep    ${POST_SLEEP_EXECUTION}s    Wait for a POST QUERY Execution
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SEAGULL SCENARIO STATUS    ${TEST_NAME}
    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1} and ${REMOTE_EXECUTION}==${0}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP INT CLIENT SRVER SCENARIO STATUS
    ...    ELSE IF    ${SCENARIO_EXECUTION}==${1} and ${REMOTE_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP EXT CLIENT SRVER SCENARIO STATUS
    ${http_status}=    BuiltIn.Run Keyword If    ${SOAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    HTTP
    ${xml_status}=    BuiltIn.Run Keyword If    ${XML_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    XML
    ${autostop_status}=    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    LOGGER
    ${pcap_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    EXECUTE PCAP
    ${cdr_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR
    ${postdb_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    POSTCONDITION
    ${shellpost_status}=    BuiltIn.Run Keyword If    ${test_file_length}!=${0}    BuiltIn.Run Keyword If    ${SHELL_COMMAND_VALIDATION}==${1}    BuiltIn.Run Keyword If    ${SHELL_POST_CMD}==${1}    BuiltIn.Run Keyword And Continue On Failure    SHELL POST CONDITION
    ${SCEN_RESULT}=    BuiltIn.Run Keyword If    ${SCENARIO_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    VERIFY SIPP EXT CLIENT SERVER RESULT
    ${protocol_status}=    BuiltIn.Run Keyword If    ${PROTOCOL_VALIDATION}==${1}    BuiltIn.Run Keyword And Continue On Failure    PCAP PROTOCOL VALIDATION
    ${SEAGULL_RESULT}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET SEAGULL RESULT    ${TEST_NAME}
    ${TC_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    '${SCEN_RESULT}'in['True','NULL','None','PASS'] and '${cdr_status}'in['PASS','NONE','None'] and '${pcap_status}'in['PASS','NONE','None'] and '${autostop_status}'in['PASS','NONE','None'] and '${postdb_status}'in['PASS','NONE','None'] and '${shellpost_status}'in['PASS','NONE','None'] and '${http_status}' in['Pass','None','DONE'] and '${protocol_status}'in['PASS','NONE','None'] and '${SEAGULL_RESULT}'in['True','NULL','None']    PASS    FAIL
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword If    '${TC_RESULT}' in['PASS']    Copy File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${PRE_POST_VALIDATE_PATH}
    [Return]    ${SCEN_RESULT}    ${autostop_status}    ${cdr_status}    ${postdb_status}    ${pcap_status}    ${shellpre_status}    ${shelloncall_status}    ${shellpost_status}    ${http_status}    ${protocol_status}    ${SEAGULL_RESULT}    ${TC_RESULT}
