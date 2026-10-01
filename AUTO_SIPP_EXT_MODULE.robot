*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process

*** Variables ***

*** Keyword ***
RUN SIPP EXT CLIENT SERVER
    [Arguments]    &{STATE_MACHINE}
    [Timeout]    3 minute 01 seconds
    Set Test Variable    @{sipp_result_count}    @{EMPTY}
    Set Test Variable    @{sipp_process_list}    @{EMPTY}
    Set Test Variable    &{sipp_process_dict}    &{EMPTY}
    Open Connection    ${SIPP_IP_ADDRESS}    ${SIPP_ALIAS}    timeout=30
    ${output}=    Login    ${SIPP_USERNAME}    ${SIPP_PASSWORD}
    Run    ${SEGENV}
    CLEAR EXT SIPP DIRECTORIES
    ${frame_new_scenario_dict}=    Run Keyword And Continue On Failure    DELETE AND COPY FILES REMOTE    ${STATE_MACHINE}
    ${scenario_keys}=    Get Dictionary Keys    ${frame_new_scenario_dict}
    Append To File    ${framework_log_file}    Starting Sipp State Machine\n
    FOR    ${i}    IN    @{scenario_keys}
    ${get_scenario_list}=    Get From Dictionary    ${frame_new_scenario_dict}    ${i}
    ${sipp_process_list}=    Create List    @{EMPTY}
    ${get_scenario_file}=    Set Variable    ${get_scenario_list}[${1}]
    ${fetch_sipp_cmdline}=    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Get File    ${get_scenario_list}[${3}]    encoding=UTF-8    encoding_errors=strict
    ${get_sipp_cmdline}=    BuiltIn.Run Keyword And Continue On Failure    String.Get Line    ${fetch_sipp_cmdline}    -1
    ${sipp_start}=    SSHLibrary.Start Command    sudo${SPACE}${SIPP_COMMAND}${/}${get_sipp_cmdline}${SPACE}-bg
    ${sipp_output}    ${sipp_error}=    Read Command Output    return_stdout=True	return_stderr=True
    ${stdout_output}=    Run Keyword And Continue On Failure    Create File   ${SIPP_TMP}${/}stdout_${get_scenario_list}[${0}].txt
    ${stderr_output}=    Run Keyword And Continue On Failure    Create File   ${SIPP_TMP}${/}stderr_${get_scenario_list}[${0}].txt
    Append To File    ${SIPP_TMP}${/}stdout_${get_scenario_list}[${0}].txt    ${sipp_output}
    Append To File    ${SIPP_TMP}${/}stderr_${get_scenario_list}[${0}].txt    ${sipp_error}
    @{fetch_process}=    Split String    ${sipp_output}   =
    ${sipp_processid}=    Remove String    ${fetch_process}[1]    [    ]
    Append To File    ${framework_log_file}    Process ID of the SIPP ${get_scenario_list}[${0}] is ${sipp_processid}\n
    log    Process ID of the SIPP ${get_scenario_list}[${0}] is ${sipp_processid}
    ${result}=    Should Match Regexp    ${sipp_processid}    [0-9]
    ${result}=    Run Keyword If    ${result} >0    Set Variable    PASS
    ...    ELSE    FAIL
    Append To List    ${sipp_result_count}    ${result}
    Append To List    ${sipp_process_list}    ${get_scenario_list}[${0}]    ${sipp_processid}
    Set To Dictionary    ${sipp_process_dict}    ${i}    ${sipp_process_list}
    Sleep    ${get_scenario_list}[${2}]s
    END
    ${get_result_count}=    Count Values In List    ${sipp_result_count}    FAIL
    ${result_status}=    Run Keyword If    ${get_result_count} >0    Set Variable    FAIL
    ...    ELSE    Set Variable    PASS
   [Return]     ${result_status}

DELETE AND COPY FILES REMOTE
    [Arguments]    ${STATE_MACHINE}
    [Timeout]    3 minute 01 seconds
    Set Test Variable    @{frame_new_scenario_list}    @{EMPTY}
    Set Test Variable    &{frame_new_scenario_dict}    &{EMPTY}
    ${scenario_count}=    Get Dictionary Keys    ${STATE_MACHINE}
    ${get_key_count}=    Get Length    ${scenario_count}
    FOR   ${i}    IN RANGE   ${get_key_count}-${get_key_count}+1    ${get_key_count}+1
    ${frame_new_scenario_list}=    Create List    @{EMPTY}
    ${str_value}=    Convert To String    ${i}	
    ${scenario_values}=    Get From Dictionary    ${STATE_MACHINE}    ${str_value}
    ${get_scenariovalue}=    Remove String     ${scenario_values}    [    ]
    ${get_scenariolist}=    Split String    ${get_scenariovalue}    ,
    ${get_file_out_name}=    Get From List    ${get_scenariolist}    0
    ${get_scenario}=    Get From List    ${get_scenariolist}    1
    ${get_scenario_sleep}=    Get From List    ${get_scenariolist}    2
    ${delete_stats_file}=    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    find${SPACE}${SIPP_REMOTE_PATH}${/}*${SPACE}-name${SPACE}${get_scenario}*${SPACE}|xargs${SPACE}rm ${SPACE}-rf
    ${kill_remote_sipp}=    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ps -ef | grep '${get_scenario}' | grep -v grep | awk '{ print $2 }' | xargs kill -9
    ${copy_inf_file}=    Run Keyword And Continue On Failure    Run Keyword And Return Status    SSHLibrary.Put File    ${SIPP_INF}/${get_scenario}.csv    ${SIPP_REMOTE_PATH}/INF/
    ${copy_scenario_file}=    Run Keyword And Continue On Failure    Run Keyword And Return Status    SSHLibrary.Put File    ${SIPP_SCENARIO}/${get_scenario}.xml    ${SIPP_REMOTE_PATH}/SCENARIO/
    ${copy_run_file}=    Run Keyword And Continue On Failure    Run Keyword And Return Status    SSHLibrary.Put File    ${SIPP_RUN}/${get_scenario}.sh    ${SIPP_REMOTE_PATH}/RUN/
    ${check_file_exist_rc}=    Run Keyword And Continue On Failure    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${SIPP_RUN}/${get_scenario}.sh
    Append To List    ${frame_new_scenario_list}    ${get_file_out_name}    ${get_scenario}    ${get_scenario_sleep}    ${SIPP_RUN}/${get_scenario}.sh
    Set To Dictionary    ${frame_new_scenario_dict}    ${i}    ${frame_new_scenario_list}
    END     
    [Return]    ${frame_new_scenario_dict}


RUN SIPP INT CLIENT SERVER
    [Arguments]    ${CLIENT_SCENARIO_FILE}    ${SERVER_SCENARIO_FILE}    ${SERVER_SCENARIO2_FILE}
    [Timeout]    3 minute 01 seconds
    CLEAR SIPP DIRECTORIES
    Run    ${SIPPENV}
    ${rc}=    Process.Start Process    sudo${SPACE}${SIPP_RUN}${/}${SERVER_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=True    alias=${SIPP_SERVER_PROCESS}    stderr=${SIPP_TMP}stderr_server.txt    stdout=${SIPP_TMP}stdout_server.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    sudo${SPACE}${SIPP_RUN}${/}${SERVER_SCENARIO2_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=True    alias=${SIPP_SERVER2_PROCESS}    stderr=${SIPP_TMP}stderr_server2.txt    stdout=${SIPP_TMP}stdout_server2.txt
    log    sipp Exit status ${rc}
    Sleep    2s
    ${rc}=    Process.Start Process    sudo${SPACE}${SIPP_RUN}${/}${CLIENT_SCENARIO_FILE}.sh    env:LD_LIBRARY_PATH=%{LD_LIBRARY_PATH}${:}${PROGDIR}    shell=True    alias=${SIPP_CLIENT_PROCESS}    stderr=${SIPP_TMP}stderr_client.txt    stdout=${SIPP_TMP}stdout_client.txt
    log    sipp Exit status ${rc}


VERIFY SIPP INT CLIENT SRVER SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${SIPP_CLIENT_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_client.txt    ${SIPP_PIDGREP}
    ${SIPP_SERVER_PID} =    OperatingSystem.Grep File    ${SIPP_TMP}stdout_server.txt    ${SIPP_PIDGREP}
    ${SIPP_CLIENT_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_CLIENT_PID}    ]
    ${SIPP_SERVER_EXT_PID} =    BuiltIn.Run Keyword And Continue On Failure    String.Remove String    ${SIPP_SERVER_PID}    ]
    @{words} =    Split String    ${SIPP_CLIENT_EXT_PID}    [
    Set Test Variable    ${SIP_ClientPID}    ${words[-1]}
    @{words} =    Split String    ${SIPP_SERVER_EXT_PID}    [
    Set Test Variable    ${SIP_ServerPID}    ${words[-1]}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${rc}    ${SIPP_clientgreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ClientPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_clientgreppid}
    ${rc}    ${SIPP_servergreppid} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${SIP_ServerPID} | grep -v grep | awk '{ print $2 }'
    Log    ${SIPP_servergreppid}
    ${rc_client}=    Process.Is Process Running    ${SIPP_CLIENT_PROCESS}
    ${rc_server}=    Process.Is Process Running    ${SIPP_SERVER_PROCESS}
    Exit For Loop If    "${SIPP_clientgreppid}"=="${EMPTY}" and "${SIPP_servergreppid}"=="${EMPTY}"
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_CLIENT_PROCESS}
    Run Keyword If    ${index}==${y}    Terminate Process    ${SIPP_SERVER_PROCESS}
    Sleep    ${SIPP_SLEEP}s
    END
    Log    SIP CLIENT AND SERVER EXECUTION COMPLETED PID is ${SIP_CLIENT_PID} and ${SIP_SERVER_PID}

VERIFY SIPP EXT CLIENT SRVER SCENARIO STATUS
    [Timeout]    3 minute 01 seconds
    ${get_scenario_keys}=    Get Dictionary Keys    ${sipp_process_dict}
    FOR    ${index}    IN RANGE    ${SIPP_TIMEOUT}
    ${y} =    Evaluate    ${SIPP_TIMEOUT} - 1
    ${get_sipp_process_dict}=    BuiltIn.Run Keyword And Continue On Failure    CHECK PROCESS STATUS
    ${get_sipp_process_keys}=    Get Dictionary Keys    ${get_sipp_process_dict}
    ${get_sipp_process_values}=    Get Dictionary Values    ${get_sipp_process_dict}
    ${get_sipp_value_index}=    Get Index From List    ${get_sipp_process_values}    1
    ${get_sipp_process_list}=    Run Keyword If    ${get_sipp_value_index}!=-1    Get Slice From List    ${get_sipp_process_keys}    ${get_sipp_value_index}
    ${get_sipp_process_check}=    Run Keyword If    ${get_sipp_value_index}!=-1    Remove String    ${get_sipp_process_list}    [    ]
    Run Keyword If    ${get_sipp_value_index}!=-1    Log    SIP  ${get_sipp_process_check} is still running with processid.Waiting for process to complete.
    Exit For Loop If    ${get_sipp_value_index}==-1 or ${index}==${y}
    Sleep    ${SIPP_SLEEP}s
    END

CHECK PROCESS STATUS
    [Timeout]    3 minute 01 seconds
    Set Test Variable    &{set_sipp_process_dict}    &{EMPTY}
    FOR   ${i}    IN    @{get_scenario_keys}
    ${get_process_verify_list}=    Get From Dictionary    ${sipp_process_dict}    ${i}
    ${rc}    ${SIPP_greppid}=    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Run And Return Rc And Output    ps -ef | grep -w ${get_process_verify_list}[1] | grep -v grep | awk '{ print $2 }'
    Run Keyword If    "${SIPP_greppid}"=="${EMPTY}"    Set To Dictionary    ${set_sipp_process_dict}    ${get_process_verify_list}[0]    0
    ...    ELSE    Set To Dictionary    ${set_sipp_process_dict}    ${get_process_verify_list}[0]    1
    Log    SIP ${get_process_verify_list}[0] PID is ${get_process_verify_list}[1]
    END
    [Return]    ${set_sipp_process_dict}


VERIFY SIPP EXT CLIENT SERVER RESULT
    [Timeout]    3 minute 01 seconds
    Set Test Variable    &{SCENARIO_DICT_FILE}    &{EMPTY}
    Log Many    ${frame_new_scenario_dict}
    ${dict_length}=    Get Length    ${frame_new_scenario_dict}
    ${scenario_keys}=    Get Dictionary Keys    ${frame_new_scenario_dict}
    COPY SIPP EXT SCENARIO LOGS REMOTE
    FOR    ${index}    IN    @{scenario_keys}
    ${get_scenario_verify_list}=    Get From Dictionary    ${frame_new_scenario_dict}    ${index}
    ${sipp_process_list}=    Create List    @{EMPTY}
    ${get_file_name}=    Get From List    ${get_scenario_verify_list}    1
    ${get_prefix_name}=    Get From List    ${get_scenario_verify_list}    0
    ${SIPPLOG_RESULT}=    VERIFY SIPP EXT LOG RESULT    ${get_file_name}
    ${SIPPSTAT_RESULT}=    VERIFY SIPP EXT STAT RESULT    ${get_file_name}
    ${SIPPLOG_RESULTS}=    Catenate  SEPARATOR=_    ${get_prefix_name}    log
    ${SIPPSTAT_RESULTS}=    Catenate  SEPARATOR=_    ${get_prefix_name}    stat
    Set To Dictionary    ${SCENARIO_DICT_FILE}    ${SIPPLOG_RESULTS}    ${SIPPLOG_RESULT}    ${SIPPSTAT_RESULTS}    ${SIPPSTAT_RESULT}
    END
    ${get_dict_content}=    Get Dictionary Values    ${SCENARIO_DICT_FILE}
    ${TEST_SCENARIO_RESULT}=    BuiltIn.Run Keyword And Continue On Failure    Set Variable If    ${False} in @{get_dict_content}    FAIL    PASS 
    log    ${TEST_SCENARIO_RESULT}
    COPY SIPP EXT SCENARIO LOGS RESULT
    [Return]    ${TEST_SCENARIO_RESULT}


VERIFY SIPP EXT LOG RESULT
    [Arguments]    ${SCENARIO_ID}
    [Timeout]    1 minute 01 seconds
    Sleep    4s
    ${SIPP_log}=    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ls -rt ${SIPP_LOG}${/}${SCENARIO_ID}_VALIDATION* | tail -1
    ${ret} =    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Grep File    ${SIPP_log}    ${SIPP_RESULT}    encoding=UTF-8    encoding_errors=strict
    ${scen_result}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    Should Contain    ${ret}    SCENARIO_PASS
    [Return]    ${scen_result}

VERIFY SIPP EXT STAT RESULT
    [Arguments]    ${SCENARIO_ID}
    [Timeout]    2 minute 01 seconds
    Sleep    4s
    ${SIPP_log}=    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    ls -rt ${SIPP_LOG}${/}${SCENARIO_ID}_STAT* | tail -1
    ${file_presence_check}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    OperatingSystem.File Should Exist    ${SIPP_log}
    ${ret}=    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    '${file_presence_check}'!='${False}'    OperatingSystem.Get File    ${SIPP_log}    encoding=UTF-8    encoding_errors=strict
    ...    ELSE    Set Variable    '${0}'
    ${ret_count}=    Get Length    ${ret} 
    ${retline}=    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${ret_count}>1    String.Get Line    ${ret}    -1
    BuiltIn.Run Keyword If    ${ret_count}>1    log    ${retline}
    @{words}=    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Run Keyword If    ${ret_count}>1    String.Split String    ${retline}    ,
    ${scen_result}=    BuiltIn.Run Keyword And Continue On Failure    Run Keyword And Return status    Run Keyword If    ${ret_count}>1    Should Contain    ${words}[15]    1
    ...    ELSE    Set Variable    ${False}
    log    ${scen_result}
    [Return]    ${scen_result}

COPY SIPP EXT SCENARIO LOGS RESULT
    [Timeout]    2 minute 01 seconds
    ${SIPP_LOG}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Copy Directory    ${SIPP_LOG}    ${result_path}${/}SIPP_LOG

COPY SIPP EXT SCENARIO LOGS REMOTE
    [Timeout]    2 minute 01 seconds
    Switch Connection    ${SIPP_ALIAS}
    ${SIPP_LOG}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}
    ${copy_log_file_local}=    Run Keyword And Continue On Failure    SSHLibrary.Get File    ${SIPP_REMOTE_PATH}/LOG/*    ${SIPP_LOG}/

CLEAR EXT SIPP DIRECTORIES
    [Timeout]    2 minute 01 seconds
    ${SIPP_LOG_LOCAL}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}
    ${SIPP_TMP_LOCAL}=    Catenate    SEPARATOR=    ${SIPP_TMP}    ${/}
    ${SIPP_LOG_REMOTE}=    Catenate    SEPARATOR=    ${SIPP_LOG}    ${/}*
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${SIPP_LOG_LOCAL}
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${SIPP_TMP_LOCAL}
    Switch Connection    ${SIPP_ALIAS}
    BuiltIn.Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm -rf ${SIPP_LOG_REMOTE}