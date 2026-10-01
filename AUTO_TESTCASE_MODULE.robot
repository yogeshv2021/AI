*** Settings ***
Library           Collections
Library           SSHLibrary    5min
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process

*** Variables ***

*** Keyword ***
TEST START
    [Documentation]    START OF TEST CASE
    [Timeout]    4 minute 50 seconds
    ${framework_log}=    Set Variable    ${result_file_name}/${suite_name}/${TEST_NAME}/FRAMEWORK_LOG.txt
    Set Test Variable    ${framework_log_file}    ${framework_log}
    ${test_filelen}=    READ TEST FILE
    Set Test Variable    ${test_file_length}    ${test_filelen}
    Set Test Variable    ${result_path}    ${result_file_name}/${suite_name}/${TEST_NAME}/
    Create Directory    ${result_path}

TEST STOP
    [Documentation]    This Keyword Used for Test be test teardown for documenting Test case failues & reason for failure
    Set Test Variable    ${TEST STATUS}    ${TESTCASE_RESULT}
    Set Test Message    ${\n}TC_RESULT=${TESTCASE_RESULT} | RESTART=${TESTCASE_SHELLPRE_STATUS} | SCENARIO_RESULT=${TESTCASE_SCEN_STATUS} | ONCALL_RESTART=${TESTCASE_SHELLON_STATUS} | DB_RESULT=${TESTCASE_POSTDB_STATUS} | CDR_RESULT=${TESTCASE_CDR_STATUS} | PCAP_RESULT=${TESTCASE_PCAP_STATUS} | POST_RESTART=${TESTCASE_SHELLPOST_STATUS} | HTTP_RESULT=${TESTCASE_HTTP_STATUS} | PROTOCOL_RESULT=${TESTCASE_PROTOCOL_STATUS} | SEAGULL_STATUS=${TESTCASE_SEAGULL_STATUS}   append=yes 
    Append To File    ${RESULT_FILES}    ${\n}TESTSUITE=${suite_name} TESTCASE=${TEST_NAME}: TC_RESULT=${TESTCASE_RESULT} | RESTART=${TESTCASE_SHELLPRE_STATUS} | SCENARIO_RESULT=${TESTCASE_SCEN_STATUS} | ONCALL_RESTART=${TESTCASE_SHELLON_STATUS} | DB_RESULT=${TESTCASE_POSTDB_STATUS} | CDR_RESULT=${TESTCASE_CDR_STATUS} | PCAP_RESULT=${TESTCASE_PCAP_STATUS} | POST_RESTART=${TESTCASE_SHELLPOST_STATUS} | PROTOCOL_RESULT=${TESTCASE_PROTOCOL_STATUS} | SEAGULL_STATUS=${TESTCASE_SEAGULL_STATUS}