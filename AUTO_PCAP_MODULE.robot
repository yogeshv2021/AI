*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           DateTime
Library           Collections
Library           DiffLibrary



*** Variables ***


*** Keyword ***

START PCAP
    [Documentation]    This Keyword initiates the PCAP Capturing for all servers listed in Configuration File
    Set Test Variable    @{PCAP_PID_LISTS}    @{EMPTY}
    ${NUM_OF_PCAP_SERVERS}=    Get Length    ${PCAP_SERVER_ALIAS}
    Append To File    ${framework_log_file}    PCAP Capturing Initiated\n
    FOR    ${i}    IN RANGE    ${NUM_OF_PCAP_SERVERS}
    ${pcap_alias}=    Get From List    ${PCAP_SERVER_ALIAS}    ${i}
    ${pcap_platform}=    Set Variable    ${alias_platform_map}[${pcap_alias}]
    ${pcap_pattern}=    Get From List    ${PCAP_STRING}    ${i}
    ${remote_path}=    Get From List    ${PCAP_CAPTURE_REMOTE_PATH}    ${i}
    Switch Connection    ${pcap_alias}
    ${rc}=    BuiltIn.Run Keyword If    "${pcap_platform}"=="SOLARIS"    SSHLibrary.Start Command    ${pcap_pattern} -w ${remote_path}${TEST_NAME}_${pcap_alias}.pcap >/dev/null &
    ...    ELSE    SSHLibrary.Start Command    ${pcap_pattern} -w ${remote_path}${TEST_NAME}_${pcap_alias}.pcap >/dev/null
    END


STOP PCAP
    [Documentation]    This Keyword terminates the PCAP Capturing for all servers listed in Configuration File and also copy PCAP files to Local Path
    ${NUM_OF_PCAP_SERVERS}=    Get Length    ${PCAP_SERVER_ALIAS}
    FOR    ${i}    IN RANGE    ${NUM_OF_PCAP_SERVERS}
    ${pcap_alias}=    Get From List    ${PCAP_SERVER_ALIAS}    ${i}
    ${pcap_platform}=    Set Variable    ${alias_platform_map}[${pcap_alias}]
    ${remote_path}=    Get From List    ${PCAP_CAPTURE_REMOTE_PATH}    ${i}
    Switch Connection    ${pcap_alias}
    BuiltIn.Run Keyword If    "${pcap_platform}"=="SOLARIS"    SSHLibrary.Execute Command    /usr/ucb/ps -auxww | grep "${remote_path}${TEST_NAME}_${pcap_alias}.pcap" | grep -v grep | awk '{print $2}' | xargs kill -9
    ...    ELSE    SSHLibrary.Execute Command    ps -auxww | grep "${remote_path}${TEST_NAME}_${pcap_alias}.pcap" | grep -v grep | awk '{print $2}' | xargs kill -9
    SSHLibrary.Get File    ${remote_path}${TEST_NAME}_${pcap_alias}.pcap    ${result_path}
    END
    Append To File    ${framework_log_file}    PCAP Capturing Terminated\n


CAPTURE SIPP STATS
    [Documentation]    This keyword captured the sipp stats from captured trace
    Set Test Variable    ${rtp_status}    ${EMPTY}
    Set Test Variable    ${rtp_current_directory}    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/CURRENT/
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${rtp_current_directory}
    ${NUM_OF_PCAP_SERVERS}=    Get Length    ${PCAP_SERVER_ALIAS}
    FOR    ${i}    IN RANGE    ${NUM_OF_PCAP_SERVERS}
    ${pcap_start_pattern}=    Get From List    ${PCAP_STATS_START_STRING}    ${i}
    ${pcap_end_pattern_sip}=    Get From List    ${PCAP_STATS_SIP_END_STRING}    ${i}
    ${pcap_end_pattern_rtp}=    Get From List    ${PCAP_STATS_RTP_END_STRING}    ${i}
    ${pcap_alias}=    Get From List    ${PCAP_SERVER_ALIAS}    ${i}
    ${pcap_platform}=    Set Variable    ${alias_platform_map}[${pcap_alias}]
    ${remote_path}=    Get From List    ${PCAP_CAPTURE_REMOTE_PATH}    ${i}
    Switch Connection    ${pcap_alias}
    ${pcap_combined_pattern_sip}=    SSHLibrary.Execute Command    ${pcap_start_pattern} ${remote_path}${TEST_NAME}_${pcap_alias}.pcap ${pcap_end_pattern_sip} > ${remote_path}${TEST_NAME}_SIP_STATS_${pcap_alias}.xml
    ${pcap_combined_pattern_rtp}=    SSHLibrary.Execute Command    ${pcap_start_pattern} ${remote_path}${TEST_NAME}_${pcap_alias}.pcap ${pcap_end_pattern_rtp} > ${remote_path}${TEST_NAME}_RTP_STATS_${pcap_alias}.xml
    SSHLibrary.Get File    ${remote_path}${TEST_NAME}_${pcap_alias}.pcap    ${result_path}

    SSHLibrary.Get File    ${remote_path}${TEST_NAME}_SIP_STATS_${pcap_alias}.xml    ${result_path}
    SSHLibrary.Get File    ${remote_path}${TEST_NAME}_SIP_STATS_${pcap_alias}.xml    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/CURRENT/

    SSHLibrary.Get File    ${remote_path}${TEST_NAME}_RTP_STATS_${pcap_alias}.xml    ${result_path}
    SSHLibrary.Get File    ${remote_path}${TEST_NAME}_RTP_STATS_${pcap_alias}.xml    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/CURRENT/
    ${rtp_status}=    Run Keyword If    "${RTP_VALIDATION_TYPE}"=="1"    REFERENCE SIPP RTP STATS COUNT
    ${sip_status}=    Run Keyword If    "${SIP_VALIDATION_TYPE}"=="1"    REFERENCE SIPP SIP STATS COUNT
    END
    Append To File    ${framework_log_file}    RTP Result : ${rtp_status}.SIPP STATS COUNT captured successfully\n
   [Return]    ${rtp_status}

REFERENCE SIPP RTP STATS COUNT
    [Documentation]    This keyword will take the sipp stats count from the reference file.
    Set Test Variable    &{D1}    &{EMPTY}
    Set Test Variable    &{D2}    &{EMPTY}
    Set Test Variable    @{L1}    @{EMPTY}
    Set Test Variable    @{L2}    @{EMPTY}
    Set Test Variable    ${get_rtp_packet_result1}    ${EMPTY}
    Set Test Variable    ${get_rtp_packet_result2}    ${EMPTY}
    Set Test Variable    @{rtp_packet_status}    @{EMPTY}
    ${ref_filecontent}=    OperatingSystem.Get File    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/REFERENCE/${TEST_NAME}_RTP_STATS_${pcap_alias}.xml
    ${actual_filecontent}=    OperatingSystem.Get File    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/CURRENT/${TEST_NAME}_RTP_STATS_${pcap_alias}.xml
    ${splitline1}=    Split To Lines    ${ref_filecontent}    2    -1
    ${splitline2}=    Split To Lines    ${actual_filecontent}    2    -1
    Sort List    ${splitline1}
    Sort List    ${splitline2}
    ${getlength1}=    Get Length    ${splitline1}
    ${getlength2}=    Get Length    ${splitline2}
    ${rtp_count_result}=    Run Keyword If    ${getlength1}==${getlength2}    Set Variable    PASS
    ...    ELSE    Set Variable     FAIL
    FOR    ${i}    IN RANGE    ${getlength1}
    ${itercount}=    Set Variable    ${getlength1}
    Exit For Loop If    ${getlength1}!=${getlength2}
    ${fetch_line_content1}=    Get From List    ${splitline1}    ${i}
    ${fetch_line_content2}=    Get From List    ${splitline2}    ${i}
    ${fetch_content1}=    Split String    ${fetch_line_content1}    \
    ${fetch_content2}=    Split String    ${fetch_line_content2}    \
    ${fetch_tag1}=    Get From List    ${fetch_content1}    0
    ${fetch_tag2}=    Get From List    ${fetch_content2}    0
    ${fetch_tag3}=    Get From List     ${fetch_content1}    2
    ${fetch_tag4}=    Get From List     ${fetch_content2}    2
    ${fetch_packet_count1}=    Get From List     ${fetch_content1}    6
    ${fetch_packet_count1}=    Run Keyword If    "${fetch_packet_count1}">="${RTP_PACKET_COUNT}"    Set Variable    ${TRUE}
        ...    ELSE    Set Variable    ${FALSE}
    ${fetch_packet_count2}=    Get From List     ${fetch_content2}    6
    ${fetch_packet_count2}=    Run Keyword If    "${fetch_packet_count2}">="${RTP_PACKET_COUNT}"    Set Variable    ${TRUE}
        ...    ELSE    Set Variable    ${FALSE}
    ${get_rtp_packet_result2}=    Run Keyword If    "${fetch_packet_count2}"=="False"    Set Variable    ${FAIL}
    Append To List    ${L1}    ${fetch_tag1}    ${fetch_tag3}    ${fetch_packet_count1}   
    Append To List    ${L2}    ${fetch_tag2}    ${fetch_tag4}    ${fetch_packet_count2}   
    ${keycount}=    Evaluate    ${itercount}-${itercount}+${i}
    ${reference_stat1}=    Collections.Set To Dictionary    ${D1}    r${keycount}=${L1}
    ${reference_stat2}=    Collections.Set To Dictionary    ${D2}    r${keycount}=${L2}
    ${L1}=    Create List
    ${L2}=    Create List
    END
    ${get_rtp_packet_result1}=    Run Keyword And Continue On Failure    Run Keyword If    ${getlength1}>2    Dictionaries Should Be Equal    ${D1}    ${D2}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    ${rtp_packet_result_status1}=    Run Keyword And Continue On Failure    Run Keyword If    "${rtp_count_result}"!="FAIL"    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    ${rtp_packet_result_status2}=    Run Keyword And Continue On Failure    Run Keyword If    "${get_rtp_packet_result2}"!="FAIL"    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    Append To List    ${rtp_packet_status}    ${get_rtp_packet_result1}    ${rtp_packet_result_status1}    ${rtp_packet_result_status2}
    ${rtp_flag}=    Count Values In List    ${rtp_packet_status}   ${1}
    ${rtp_flag_state}=    Run Keyword If    ${rtp_flag}>${0}    Set Variable    FAIL
    ...    ELSE    Set Variable    PASS
    Append To File    ${framework_log_file}    RTP Result after comparison ${rtp_flag_state} \n
   [Return]    ${rtp_flag_state}

REFERENCE SIPP SIP STATS COUNT
    [Documentation]    This keyword will take the sipp stats count from the reference file.
    Set Test Variable    &{D1}    &{EMPTY}
    Set Test Variable    &{D2}    &{EMPTY}
    Set Test Variable    @{L1}    @{EMPTY}
    Set Test Variable    @{L2}    @{EMPTY}
    ${ref_filecontent}=    OperatingSystem.Get File    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/REFERENCE/${TEST_NAME}_SIP_STATS_${pcap_alias}.xml
    ${actual_filecontent}=    OperatingSystem.Get File    ${PRE_POST_VALIDATE_PATH}/SIPP_STATS/CURRENT/${TEST_NAME}_SIP_STATS_${pcap_alias}.xml
   [Return]    ${sip_packet_result_status}

    
VALIDATE SIPP STATS COUNT
    [Documentation]    This keyword will validate the current sipp stats count with the reference file.
    [Arguments]    ${reference_stat}
    ${filecontent}=    OperatingSystem.grep File    ${result_path}/${TEST_NAME}_STATS_${pcap_alias}.xml    ${reference_stat}
    ${current_list}=    Split String    ${filecontent}    :    1
    ${current_tag}=    Remove String    ${current_list}[0]    [' ]
    ${current_value}=    Remove String    ${current_list}[1]    [' ]
    ${status}=    Run Keyword If    '${fetch_tag.strip()}'=='${current_tag.strip()}' and '${fetch_value.strip()}'=='${current_value.strip()}'    Set Variable    PASS
    ...    ELSE    Set Variable    FAIL
    Run Keyword And Continue On Failure    Run Keyword If    '${status}'=='FAIL'    Append To File    ${result_path}/${TEST_NAME}_SIPPSTATS_FAILURE_${pcap_alias}.xml    Expected Count: ${fetch_tag.strip()}:${fetch_value.strip()}\nCurrent Count: ${current_tag.strip()}:${current_value.strip()}\n
   [Return]    ${status}



CAPTURE PCAP XML
    [Documentation]    This Keyword is used to convert PCAP file to XML file and validates XML file with reference file to return PCAP Success Status
    Set Test Variable    @{PCAP_SERVERS_STATUS}    @{EMPTY}
    ${NUM_OF_PCAP_SERVERS}=    Get Length    ${PCAP_SERVER_ALIAS}
    Append To File    ${framework_log_file}    Decoding PCAP Trace into XML File\n
    @{test_files}=    OperatingSystem.List Files In Directory    ${PRE_POST_VALIDATE_PATH}${suite_name}/    ${TEST_NAME}.txt
    ${test_file_length}=    Get Length    ${test_files}
    FOR    ${i}    IN RANGE    ${NUM_OF_PCAP_SERVERS}
    ${validate_file}=    Get From List    ${PCAP_VALIDATION_INPUT_ALIAS}    ${i}
    ${grep_string}=    BuiltIn.Run Keyword If    ${test_file_length}>${0}    Grep File    ${PRE_POST_VALIDATE_PATH}${suite_name}/${TEST_NAME}.txt    ${validate_file}_PCAP    encoding=UTF-8
    Set Test Variable    ${pcap_grep_string}    ${grep_string}
    ${length}=    Get Length    ${grep_string}
    BuiltIn.Run Keyword If    ${length}>${0}    WRITE LATEST REF FILE    ${grep_string}\n
    ${pcap_alias}=    BuiltIn.Run Keyword If    ${length}>${0}    Get From List    ${PCAP_SERVER_ALIAS}    ${i}
    ${remote_path}=    BuiltIn.Run Keyword If    ${length}>${0}    Get From List    ${PCAP_CAPTURE_REMOTE_PATH}    ${i}
    ${PER_SERVER_XML_CONVERTER}=    BuiltIn.Run Keyword If    ${length}>${0}    Get From List    ${PCAP_XML_CONVERSION_STRING}    ${i}
    ${PER_SERVER_XML_END_CONVERTER}=    BuiltIn.Run Keyword If    ${length}>${0}    Get From List    ${PCAP_XML_CONVERSION_END_STRING}    ${i}
    BuiltIn.Run Keyword If    ${length}>${0}    XML CONVERTER    ${pcap_alias}    ${remote_path}    ${PER_SERVER_XML_CONVERTER}    ${PER_SERVER_XML_END_CONVERTER}
    ${status}=    BuiltIn.Run Keyword If    ${length}>${0}    XML COMPARE    ${pcap_alias}
    Append To List    ${PCAP_SERVERS_STATUS}    ${status}
    END
    ${pcap_server_flag}=    Count Values In List    ${PCAP_SERVERS_STATUS}   ${0}
    ${no_of_items}=    Get Length    ${PCAP_SERVERS_STATUS}
    ${pcap_server_flag}=    Run Keyword If    ${pcap_server_flag}>${0}    Set Variable    ${FAIL}
    ...    ELSE IF    ${no_of_items}>${0}    Set Variable    PASS
    ...    ELSE    Set Variable    NONE
    Append To File    ${framework_log_file}    XML Decoding Done\n
    [Return]    ${pcap_server_flag}


XML CONVERTER
    [Arguments]    ${pcap_alias}    ${remote_path}    ${XML_CONVERSION_STRING}    ${XML_CONVERSION_END_STRING}
    [Documentation]    This Keyword is used to convert PCAP file to XML file and also copy the coverted XML file into Local Path
    Switch Connection    ${pcap_alias}
    SSHLibrary.Execute Command    ${XML_CONVERSION_STRING} -r ${remote_path}${TEST_NAME}_${pcap_alias}.pcap ${XML_CONVERSION_END_STRING} > ${remote_path}/${TEST_NAME}_${pcap_alias}.xml
    SSHLibrary.Get File    ${remote_path}${TEST_NAME}_${pcap_alias}.xml    ${result_path}


XML COMPARE
    [Arguments]    ${pcap_alias}
    [Documentation]    This Keyword is used to validate converted PCAP XML file for the test case with the reference file and return PASS/FAIL PCAP status
    Set Test Variable    @{PCAP_STATUS_LIST}    @{EMPTY}
    ${line_number}=    Get Line Count    ${pcap_grep_string}
    FOR    ${i}    IN RANGE    ${line_number}
    ${lines}=    Get Line    ${pcap_grep_string}    ${i}
    ${line}=    Fetch From Right    ${lines}    PCAP${SPACE}:${SPACE}
    ${content}=    Operating System.Get File    ${result_path}/${TEST_NAME}_${pcap_alias}.xml
    ${generated_pcap_xml}=    Run Keyword If    ${PCAP_GREP_CHANGE}==${1}    String.Get Lines Containing String    ${content}    ${line}
    ...    ELSE    Operating System.Grep File    ${result_path}/${TEST_NAME}_${pcap_alias}.xml    ${line}
    ${local_pcap_status}=    Get Length    ${generated_pcap_xml}
    BuiltIn.Run Keyword If    ${local_pcap_status}==${0}    BuiltIn.Run Keyword    PCAP_LOGGING    ${pcap_alias}    ${lines}
    Append To List    ${PCAP_STATUS_LIST}    ${local_pcap_status}
    END
    ${pcap_flag}=    Count Values In List    ${PCAP_STATUS_LIST}   ${0}
    ${pcap_flag}=    Run Keyword If    ${pcap_flag}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    [Return]    ${pcap_flag}


PCAP_LOGGING
    [Arguments]    ${pcap_alias}    ${line}
    [Documentation]    This Keyword is used to log the PCAP XML Messages for which Test Case Fails
    ${file}=    Set Variable    ${result_path}/PCAP_FAILURE_${TEST_NAME}_${pcap_alias}.txt
    Append To File    ${file}    ${line}
    

EXECUTE PCAP
    [Documentation]    This consilated keyword calls STOP PCAP and CAPTURE PCAP XML Keywords
    Set Test Variable    @{pcap_result_status}    @{EMPTY}
    STOP PCAP
    ${get_rtp_status}=    BuiltIn.Run Keyword And Continue On Failure    CAPTURE SIPP STATS
    ${status}=    BuiltIn.Run Keyword If    ${XML_DECODE_Validation}==${1}    BuiltIn.Run Keyword    CAPTURE PCAP XML
    Append To List    ${pcap_result_status}    ${get_rtp_status}    ${status}
    ${pcap_flag}=    Count Values In List    ${pcap_result_status}   ${FAIL}
    ${pcap_status}=    Run Keyword If     ${pcap_flag}>${0}    Set Variable    FAIL
    ...    ELSE    Set Variable    PASS
    [Return]    ${pcap_status}

TEST PCAP PROTOCOL VALIDATION
    [Documentation]    PCAP PROTOCOL SPECIFIC FILE LEVEL VALIDATION
    [Timeout]    2 minute 01 seconds
    Set Test Variable    @{proto_status}    @{EMPTY}
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${PCAP_TEMP_PATH}
    ${temp_pcap_xml}=    Run    ${PCAP_PROTO_GREP} ${result_path}${TEST_NAME}_${PCAP_FILE_EXT}.xml
    Operating System.Append To File    ${PCAP_TEMP_PATH}${TEST_NAME}.xml    ${temp_pcap_xml}
    ${file_one}=    OperatingSystem.Get File    ${PCAP_TEMP_PATH}${TEST_NAME}.xml    encoding=UTF-8
    ${file_two}=    OperatingSystem.Get File    ${PCAP_EXP_PATH}${TEST_NAME}.xml    encoding=UTF-8
    @{linesone}=    String.Split To Lines    ${file_one}
    @{linestwo}=    String.Split To Lines    ${file_two}
    ${linesone_count}=    BuiltIn.Get Length    ${linesone}
    ${linestwo_count}=    BuiltIn.Get Length    ${linestwo}
    FOR    ${i}    IN RANGE    ${linesone_count}
    ${rc}=    Run Keyword And Return Status    Should Be Equal As Strings    ${linesone}[${i}]    ${linestwo}[${i}]
    ${rc}=    Run Keyword If    ${rc}==${True}    Set Variable    ${1}
    ...    ELSE    Set Variable    ${0}
    BuiltIn.Run Keyword If    ${rc}==${0}    BuiltIn.Run Keyword    PROTO_LOGGING    ${linesone}[${i}]
    BuiltIn.Run Keyword If    ${rc}==${0}    BuiltIn.Run Keyword    PROTO_LOGGING    ${linestwo}[${i}]
    Append To List    ${proto_status}    ${rc}
    END
    ${proto_status_flag}=    Count Values In List    ${proto_status}    ${0}
    ${proto_status_flag}=    Run Keyword If    ${proto_status_flag}==${0}    Set Variable    PASS
    ...    ELSE    Set Variable    FAIL
    [Return]    ${proto_status_flag}

TEST PROTOCOL VALIDATION
    [Documentation]    PCAP PROTOCOL SPECIFIC FILE LEVEL VALIDATION
    [Timeout]    2 minute 01 seconds
    Set Test Variable    @{PROTO_STATUS_LIST}    @{EMPTY}
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${PCAP_TEMP_PATH}
    ${temp_pcap_xml}=    Run    ${PCAP_PROTO_GREP} ${result_path}${TEST_NAME}_${PCAP_FILE_EXT}.xml
    @{proto_line}=    String.Split To Lines    ${temp_pcap_xml}
    ${count}=    String.Get Line Count    ${temp_pcap_xml}
    FOR    ${i}    IN RANGE    ${count}    
    ${file2}=    Operating System.Grep File    ${PCAP_EXP_PATH}${TEST_NAME}.xml    ${proto_line}[${i}]
    ${status}=    Get Length    ${file2}
    BuiltIn.Run Keyword If    ${status}==${0}    BuiltIn.Run Keyword    PROTO_LOGGING    ${lines}
    Append To List    ${PROTO_STATUS_LIST}    ${status}
    END
    ${proto_flag}=    Count Values In List    ${PROTO_STATUS_LIST}   ${0}
    ${proto_status}=    Run Keyword If    ${proto_flag}>${0}    Set Variable    ${FAIL}
    ...    ELSE    Set Variable    ${PASS}
    [Return]    ${proto_status}

PCAP PROTOCOL VALIDATION
    [Documentation]    CHECK PROTOCOL VALIDATION
    ${rc}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${result_path}${TEST_NAME}_${PCAP_FILE_EXT}.xml
    ${rc}=    Run Keyword If    ${rc}==${True}    PCAP PROTOCOL REF FILE VALIDATION
    ...    ELSE    Set Variable    ${NONE}
    [Return]    ${rc}

PCAP PROTOCOL REF FILE VALIDATION
    [Documentation]    CHECK PROTOCOL VALIDATION
    ${rc}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${PCAP_EXP_PATH}${TEST_NAME}.xml
    ${rc}=    Run Keyword If    ${rc}==${True}    PROTOCOL VALIDATION
    ...    ELSE    Set Variable    ${NONE}
    [Return]    ${rc}

PROTOCOL VALIDATION
    [Documentation]    PCAP PROTOCOL SPECIFIC FILE LEVEL VALIDATION
    [Timeout]    2 minute 01 seconds
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Empty Directory    ${PCAP_TEMP_PATH}
    ${temp_pcap_xml}=    Run    ${PCAP_PROTO_GREP} ${result_path}${TEST_NAME}_${PCAP_FILE_EXT}.xml ${PCAP_PROTO_GREP_END_STRING}
    Operating System.Append To File    ${PCAP_TEMP_PATH}${TEST_NAME}.xml    ${temp_pcap_xml}
    ${rc}    ${output}=    Run Keyword If    ${PROTOCOL_VALIDATION_TYPE}==0    Run And Return Rc And Output    diff -b ${PCAP_TEMP_PATH}${TEST_NAME}.xml ${PCAP_EXP_PATH}${TEST_NAME}.xml
    ...    ELSE    Run Keyword If    ${PROTOCOL_VALIDATION_TYPE}==1    PROTOCOL VALIDATION TYPE TWO
    ${proto_status}=    Run Keyword If    ${rc}==${0}    Set Variable    PASS
    ...    ELSE    Set Variable    FAIL
    BuiltIn.Run Keyword If    ${rc}>${0}    BuiltIn.Run Keyword    PROTO_LOGGING    ${output}
    Copy File   ${PCAP_TEMP_PATH}${TEST_NAME}.xml   ${result_path}/${TEST_NAME}_PROTOCOL_VALIDATION_ACTUAL_RESULT.xml 
    [Return]    ${proto_status}

PROTOCOL VALIDATION TYPE TWO
    [Documentation]    PCAP PROTOCOL SPECIFIC FILE LEVEL VALIDATION
    [Timeout]    2 minute 01 seconds
    ${rc}    ${test_one}=    Run And Return Rc And Output    sort ${PCAP_TEMP_PATH}${TEST_NAME}.xml
    Operating System.Append To File    ${PCAP_TEMP_PATH}temp1.xml    ${test_one}
    ${rc}    ${test_two}=    Run And Return Rc And Output    sort ${PCAP_EXP_PATH}${TEST_NAME}.xml
    Operating System.Append To File    ${PCAP_TEMP_PATH}temp2.xml    ${test_two}
    ${rc}    ${output}=    Run And Return Rc And Output    diff -b ${PCAP_TEMP_PATH}temp1.xml ${PCAP_TEMP_PATH}temp2.xml
    [Return]    ${rc}    ${output}


PROTO_LOGGING
    [Arguments]    ${line}
    [Documentation]    This Keyword is used to log the PCAP XML Messages for which Test Case Fails
    ${file}=    Set Variable    ${result_path}/PROTO_FAILURE_${TEST_NAME}_${PCAP_FILE_EXT}.txt
    Append To File    ${file}    ${line}
    Append To File    ${file}    ${\n}
