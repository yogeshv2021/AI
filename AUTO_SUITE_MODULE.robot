*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           DateTime
Library           Collections
Library           ArchiveLibrary



*** Variables ***



*** Keyword ***
START CONNECTION
    [Documentation]    This Keyword is used to establish connection to all servers, creates Timestamp File, cretes PID file to maintain Seagull PID's and Empty Seagull Log Directory
    Set Global Variable    &{alias_platform_map}     &{EMPTY}
    Set Global Variable    @{SHELL_PRE_CONFIG}       @{EMPTY}
    Set Global Variable    @{SHELL_ONCALL_CONFIG}    @{EMPTY}
    Set Global Variable    @{SHELL_POST_CONFIG}      @{EMPTY}
    Set Global Variable    &{alias_script_map}       &{EMPTY}
    ${num_of_servers}=    Get Length    ${SERVERS}
    FOR    ${i}    IN RANGE    ${num_of_servers}
    ${dict}=    Get From List    ${SERVERS}    ${i}
    ${num_of_apps}=    Get Length    ${dict}[APP_PRODUCTS]
    BuiltIn.Run Keyword    Set To Dictionary    ${alias_platform_map}    ${dict}[ALIAS]=${dict}[PLATFORM]
    BuiltIn.Run Keyword If    ${REMOTE_START_TYPE}==${1}    Set To Dictionary    ${alias_script_map}    ${dict}[ALIAS]=${dict}[APP_PRODUCTS]
    Open Connection   ${dict}[HOST]    prompt=${dict}[PROMPT]    encoding=${dict}[ENCODING]    alias=${dict}[ALIAS]    timeout=10 hour
    BuiltIn.Run Keyword If    "${dict}[LOGIN_TYPE]"=="PUBLICKEY"    Login With Public Key    ${dict}[USERNAME]    ${ID_RSA}    keep_alive_interval    30 seconds
    ...    ELSE    Login    ${dict}[USERNAME]    ${dict}[PASSWORD]    keep_alive_interval    30 seconds
    ${command}=    Get From Dictionary    ${REMOTE_DISK_SPACE_CHK}    ${dict}[ALIAS]
    ${output}=    BuiltIn.Run Keyword    SSHLibrary.Execute Command    ${command}
    Run Keyword If    ${output}<${MIN_DISK_SPACE}    Fatal Error    REMOTE SERVER ${dict}[ALIAS] DISK SPACE CROSSED THRESHOLD
    BuiltIn.Run Keyword If    ${REMOTE_START_TYPE}==${1}    BuiltIn.Run Keyword If    ${num_of_apps}>${0}    START REMOTE APP    ${dict}[ALIAS]
    END
    Enable SSH Logging    ${AUTOMATION_TEMP_PATH}APP_LOGS.txt
    ${TC_TIMESTAMP}=    Getting date time
    Create File    ${AUTOMATION_TEMP_PATH}timestamp.txt    ${TC_TIMESTAMP}
    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION}==${1}    OperatingSystem.Empty Directory    ${SEAGULL_LOGPATH}
    PREPARE BACKUP
    Set Global Variable    ${RESULT_FILES}    ${CONSOLIDATED_RESULT_FILE}Result_${TC_TIMESTAMP}.txt


RECONNECTION
    [Documentation]    This Keyword is used to establish connection to all servers, creates Timestamp File, cretes PID file to maintain Seagull PID's and Empty Seagull Log Directory
    Set Global Variable    &{alias_platform_map}     &{EMPTY}
    Set Global Variable    @{SHELL_PRE_CONFIG}       @{EMPTY}
    Set Global Variable    @{SHELL_ONCALL_CONFIG}    @{EMPTY}
    Set Global Variable    @{SHELL_POST_CONFIG}      @{EMPTY}
    Set Global Variable    &{alias_script_map}       &{EMPTY}
    ${num_of_servers}=    Get Length    ${SERVERS}
    FOR    ${i}    IN RANGE    ${num_of_servers}
    ${dict}=    Get From List    ${SERVERS}    ${i}
    ${num_of_apps}=    Get Length    ${dict}[APP_PRODUCTS]
    BuiltIn.Run Keyword    Set To Dictionary    ${alias_platform_map}    ${dict}[ALIAS]=${dict}[PLATFORM]
    BuiltIn.Run Keyword If    ${REMOTE_START_TYPE}==${1}    Set To Dictionary    ${alias_script_map}    ${dict}[ALIAS]=${dict}[APP_PRODUCTS]
    Open Connection   ${dict}[HOST]    prompt=${dict}[PROMPT]    encoding=${dict}[ENCODING]    alias=${dict}[ALIAS]    timeout=2 hour
    BuiltIn.Run Keyword If    "${dict}[LOGIN_TYPE]"=="PUBLICKEY"    Login With Public Key    ${dict}[USERNAME]    ${ID_RSA}    keep_alive_interval    30 seconds
    ...    ELSE    Login    ${dict}[USERNAME]    ${dict}[PASSWORD]    keep_alive_interval    30 seconds
    END


CLOSE EXISTING CONNECTION
    Close All Connections


READ TEST FILE
    [Documentation]    This Keyword is used to read queries from Precondition,OnCallCondition and Postcondition Validation Files into Memory
    [Timeout]    2 minute
    Set Test Variable    @{testcase_input}    @{EMPTY}
    @{test_files}=    BuiltIn.Run Keyword    OperatingSystem.List Files In Directory    ${PRE_POST_VALIDATE_PATH}${suite_name}/    ${TEST_NAME}.txt
  
    ${test_file_length}=    Get Length    ${test_files}
    ${temp}=    BuiltIn.Run Keyword If    ${test_file_length}>${0}    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Grep File    ${PRE_POST_VALIDATE_PATH}${suite_name}/${TEST_NAME}.txt    *?*
    BuiltIn.Run Keyword If    ${test_file_length}>${0}    Append To List    ${testcase_input}    ${temp}
    ...    ELSE    Append To List    ${testcase_input}    TEST
    [Return]    ${test_file_length}


WRITE LATEST REF FILE
    [Documentation]    This Keyword is used to read queries from Precondition,OnCallCondition and Postcondition Validation Files into Memory
    [Arguments]    ${list}
    [Timeout]    2 minute
    BuiltIn.Run Keyword And Continue On Failure    Append To File    ${LATEST_REF_PATH}${TEST_NAME}.txt    ${list}

SEAGULL SCENARIO PREPARATION
    [Timeout]    2 minute
    ${value}=    BuiltIn.Run Keyword If    ${SEAGULL_EXECUTION_TYPE}==${1}    Set Variable    ${TEST_NAME}.xml
    ...    ELSE    Set Variable    ${SEAGULL_STATE_MACHINE}.xml
    [Return]    ${value}


INPUT FILE PROCESSING
    [Arguments]    ${pattern}
    [Timeout]    3 minute
    Set Test Variable    @{testcase_content}    @{EMPTY}
    ${current_content}=    BuiltIn.Run Keyword And Continue On Failure    Get Lines Containing String    ${testcase_input}[0]    ${pattern}
    @{testcase_list}=    Split To Lines    ${current_content}
    ${testcase_list_length}=    Get Length    ${testcase_list}
    FOR    ${i}    IN RANGE    ${testcase_list_length}
    ${first}    ${last}=    Split String    ${testcase_list}[${i}]    :${SPACE}    1
    Append To List    ${testcase_content}    ${last}
    END
    ${count}=    Get Length    ${testcase_content}
    [Return]    ${count}    ${current_content}    @{testcase_content}


CONNECTION
    [Documentation]    This Keyword defines at Suite Start Up in __init__.robot & calls keyword for connecting servers,loading DB Queries,Shell Commands & CDR's
    DISK SPACE CHECK
    Log    Automation Start Sleep time=${AUTO_START_SLEEP_TIME}
    Sleep    ${AUTO_START_SLEEP_TIME}s
    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${0}    Connect Application with PublicKey
    ...    ELSE    START CONNECTION
    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${1}    BuiltIn.Run Keyword If    ${DB_Validation}==${1}    DB READ
    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${1}    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    INITIALIZE LOGGER PREFIX
    BuiltIn.Run Keyword If    ${MODEL_TYPE}==${1}    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    INITIALIZE CDR PREFIX


DB READ
    Set Global Variable    @{debug_queries}    @{EMPTY}
    ${debug_length}=    Get Length    ${DEBUGGING_QUERIES}
    FOR    ${i}    IN RANGE    ${debug_length}
    ${content}    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Grep File    ${DEBUGGING_QUERIES}[${i}]    *?*
    Append To List    ${debug_queries}    ${content}
    END
    BuiltIn.Run Keyword If    ${POST_DB_QUERY_Validation}==${1}    INITIALIZE DUMMY


SUITE STARTUP
    [Documentation]    This Keyword defines at Suite Start Up for each suites & mainly used for the purpose of creating Result Directory
    Suite Execution Time Set
    RECONNECTION
    ${suite_exact_name}=    Fetch From Right    ${SUITE_NAME}    .
    ${suite_exact_name}=    Replace String    ${suite_exact_name}    ${SPACE}    _
    Set Suite Variable    ${suite_name}    ${suite_exact_name}
    Set Suite Variable    ${result_file_name}    ${RESULT_LOGPATH}/${AUTO_REL}/${AUTO_REV}/${TIMESTAMP}
    ${index}=    Get Length    ${DB_CONNECTION_STRING}
    Set Suite Variable    ${index_end}    ${index}
    Create Directory    ${result_file_name}
    BuiltIn.Run Keyword If    ${MGTS_EXECUTION}==${1}    BuiltIn.Run Keyword And Continue On Failure    Connect MGTS with PublicKey



SUITE STOP
    ${TIMESTAMP}=    OperatingSystem.Get File    ${AUTOMATION_TEMP_PATH}timestamp.txt
    Run    cd ${RESULT_LOGPATH}/${AUTO_REL}/${AUTO_REV}/;tar -cvf ${TIMESTAMP}.tar ${TIMESTAMP};gzip ${TIMESTAMP}.tar
    BuiltIn.Run Keyword If    ${MGTS_EXECUTION}==${1}    Close Mgts Connection
    Close Application Server Connection
    Remove Directory    ${RESULT_LOGPATH}/${AUTO_REL}/${AUTO_REV}/${TIMESTAMP}    recursive=True
    ${output} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run    ${ROOT_USER_CHK}
    BuiltIn.Run Keyword If    "${output}"=="root"    ROOT EXE PERMESSION CHANGES

INITIALIZE DUMMY
    ${dummy_length}=    Get Length    ${DUMMY_PLACE_HOLDERS}
    FOR    ${i}    IN RANGE    ${dummy_length}
    Set Global Variable    ${${DUMMY_PLACE_HOLDERS}[${i}]}    ${-1}
    END


INITIALIZE LOGGER PREFIX
    Set Global Variable    @{LOG_PREFIX}    @{EMPTY}
    ${num_of_applications}=    Get Length    ${LOGGER_PREFIX}
    FOR    ${i}    IN RANGE    ${num_of_applications}
    ${list}=    Get From List    ${LOGGER_PREFIX}    ${i}
    BuiltIn.Run Keyword    CONVERT NESTED LOGGER LIST TO LOGGER LIST    ${list}
    END


INITIALIZE CDR PREFIX
    Set Global Variable    @{CDR_PREFIX}    @{EMPTY}
    ${num_of_applications}=    Get Length    ${CDRS_PREFIX}
    FOR    ${i}    IN RANGE    ${num_of_applications}
    ${list}=    Get From List    ${CDRS_PREFIX}    ${i}
    BuiltIn.Run Keyword    CONVERT NESTED CDR LIST TO CDR LIST    ${list} 
    END


CONVERT NESTED LOGGER LIST TO LOGGER LIST
    [Arguments]    ${list}
    FOR    ${i}    IN    @{list}
    Append To List    ${LOG_PREFIX}    ${i}
    END


CONVERT NESTED CDR LIST TO CDR LIST
    [Arguments]    ${list}
    FOR    ${i}    IN    @{list}
    Append To List    ${CDR_PREFIX}    ${i}
    END


PREPARE BACKUP
    ${GETTIME}=    OperatingSystem.Get File    ${AUTOMATION_TEMP_PATH}timestamp.txt
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    BuiltIn.Run Keyword And Continue On Failure    Create Directory    ${BKP_INPUT_PATH}${GETTIME}
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    BuiltIn.Run Keyword And Continue On Failure    Create Directory    ${BKP_INPUT_PATH}${GETTIME}
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    Copy Files    ${PRE_POST_VALIDATE_PATH}*    ${BKP_INPUT_PATH}${GETTIME}
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${2}    Copy Files    ${PRE_POST_VALIDATE_PATH}*    ${BKP_INPUT_PATH}${GETTIME}
    BuiltIn.Run Keyword If    ${MIGRATION_FLAG}==${1}    Copy Files    ${LATEST_REF_PATH}*    ${PRE_POST_VALIDATE_PATH}
    Move Files    ${LATEST_REF_PATH}*    ${BACKUP_REF_PATH}



PREPROCESSING
    [Documentation]    This Keyword is used to capture parameters necessary for Capturing of Logs,CDR's and PCAP
    BuiltIn.Run Keyword If    ${REMOTE_START_TYPE}==${1}    BuiltIn.Run Keyword And Continue On Failure    IS APPLICATION ALIVE
    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    INITIALIZE
    BuiltIn.Run Keyword If    ${LOGGER_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET LOG PATH    0
    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    CDR INITIALIZE
    BuiltIn.Run Keyword If    ${CDR_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    GET CDR PATH    0
    BuiltIn.Run Keyword If    ${PCAP_Validation}==${1}    BuiltIn.Run Keyword And Continue On Failure    START PCAP

DEPENDANT
    [Arguments]    ${tc_id}    ${strings}
    BuiltIn.Run Keyword If    ${TC_DEPENDENCY_ENABLE}==${1}    DEPENDANT SUB KEYWORD    ${tc_id}    ${strings}

DEPENDANT SUB KEYWORD
    [Arguments]    ${tc_id}    ${strings}
    Set Test Variable    @{string_lists}    @{EMPTY}
    Set Test Variable    ${TC_ID}    ${tc_id}
    Set Test Variable    ${TEMP_TEST}    ${TEST_NAME}
    Set Test Variable    ${TEST_NAME}    ${tc_id}
    @{string_lists}=    Split String    ${strings}    ,
    Set Test Variable    ${TC_DEPENDENCY_ENABLE}    ${2}
    Set Test Variable    ${PRE_DB_Validation}    ${string_lists}[0]
    Set Test Variable    ${SHELL_PRE_CMD}    ${string_lists}[1]
    Set Test Variable    ${SCENARIO_EXECUTION}    ${string_lists}[2]
    Set Test Variable    ${ON_CALL_DB_Validation}    ${string_lists}[3]
    Set Test Variable    ${SHELL_ON_CALL_CMD}    ${string_lists}[4]
    Set Test Variable    ${LOGGER_Validation}    ${string_lists}[5]
    Set Test Variable    ${SHELL_POST_CMD}    ${string_lists}[6]
    Set Test Variable    ${PCAP_Validation}    ${string_lists}[7]
    Set Test Variable    ${CDR_Validation}    ${string_lists}[8]
    Set Test Variable    ${POST_DB_QUERY_Validation}    ${string_lists}[9]
    ${TC_RESULT} =    START AUTO
    log    ${TC_RESULT}
    Set Test Variable    ${TC_DEPENDENCY_ENABLE}    ${1}
    Set Test Variable    ${TEST_NAME}    ${TEMP_TEST}

DISK SPACE CHECK
    [Documentation]    This Keyword is used to Validate the Disk Space in Automation Server
    [Timeout]    2 minute
    ${rc}    ${output} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ${DISK_SPACE_CHK}    
    Run Keyword If    ${output}<${MIN_DISK_SPACE}    Fatal Error    DISK SPACE CROSSED THRESHOLD

ROOT EXE PERMESSION CHANGES
    [Documentation]    This Keyword is used to Change Permessions of Automation directories & files when automation executed with root user.
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run    ${ROOT_PERMESSION_CHNG} ${AUTOMATION_PATH}
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run    ${ROOT_PERMESSION_CHNG} ${AUTOMATION_RESULT_PATH}
