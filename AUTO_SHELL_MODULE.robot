*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           DateTime
Library           DatabaseLibrary



*** Variables ***



*** Keyword ***
CHANGE_CONFIG
    [Arguments]    ${config}    ${place_holder}    ${value}
    [Timeout]    3 minute
    ${config_out}=  Get From Dictionary    ${CONFIG_ALIASES}    ${config}
    ${alias}=    Set Variable    ${config_out}[0]
    ${dest}=    Set Variable    ${config_out}[1]
    ${source}=    Set Variable    ${config_out}[2]
    ${content}=    OperatingSystem.Get File    ${source}
    ${content}=    Replace String    ${content}    ${place_holder}    ${value}
    Create File    ${source}    ${content}
    Append To File    ${framework_log_file}    changing config ${config} tag ${place_holder} with ${value}\n

EXECUTE_REMOTE_COMMAND
    [Arguments]    ${product}    ${command}
    ${alias}=    Get From Dictionary    ${PRODUCT_SERVER_DICTIONARY}    ${product}
    Switch Connection    ${alias}
    SSHLibrary.Execute Command    ${command}


PREPARE CONFIG FILE
    ${aliases}=    Get Dictionary Keys    ${CONFIG_ALIASES}
    FOR    ${i}    IN    @{aliases}
    ${list_out}=    Get From Dictionary    ${CONFIG_ALIASES}    ${i}
    ${source}=    Set Variable    ${list_out}[${3}]
    ${dest}=    Set Variable    ${list_out}[${2}]
    Copy File    ${source}    ${dest}
    END


LOOP EACH CONFIG
    [Arguments]    @{result}
    ${length}=    Get Length    ${result}
    Set Test Variable    @{active_aliases}    @{EMPTY}
    Set Test Variable    ${loop_alias}    NO_VALUE
    FOR    ${i}    IN RANGE    ${length}
    ${str}=    Set Variable    ${result}[${i}]
    @{split}=    Split String    ${str}    ${SPACE}${SPACE}${SPACE}${SPACE}
    Run Keyword    @{split}
    Run Keyword If    "${split}[0]"=="CHANGE_CONFIG"    SET FLAG
    END

LOOP EACH CONFIG POST
    [Arguments]    ${postalias}    @{result}
    ${getshellpostresult}=    Run Keyword    EXECUTE_REMOTE_COMMAND_POST    ${postalias}    ${result}[0]
    ${flag}=    Run Keyword If    "${getshellpostresult}"=="${result}[1]"    Set Variable    ${1}
    ...    ELSE    Set Variable    ${0}
    [Return]    ${flag}

EXECUTE_REMOTE_COMMAND_POST
    [Arguments]    ${product}    ${command}
    ${key_alias}=    Get Dictionary Keys    ${PRODUCT_SERVER_DICTIONARY}
    ${value_alias}=    Get Dictionary Values    ${PRODUCT_SERVER_DICTIONARY}
    ${indexvalue_alias}=    Get Index From List    ${value_alias}    ${product}
    ${getkeyalias}=    Get From List    ${key_alias}    ${indexvalue_alias}
    ${alias}=    Get From Dictionary    ${PRODUCT_SERVER_DICTIONARY}    ${getkeyalias}
    Switch Connection    ${alias}
    ${getpostresult}=    SSHLibrary.Execute Command    ${command}
    [Return]     ${getshellpostresult}

END_CONFIG
    DEFAULT VALUE VALIDATE
    COPY CONFIG

END_CONFIG_ALIAS
    [Arguments]    ${config}
    DEFAULT VALUE VALIDATE ALIAS    ${config}
    COPY CONFIG ALIAS    ${config}

SET FLAG
    ${flag}=    Run Keyword If    "${loop_alias}"!="${split}[1]"    Set Variable    ${1}
    ...    ELSE    Set Variable    ${0}
    ${loop_alias}=    Run Keyword If    ${flag}==${1}    Set Variable    ${split}[1]
    ...    ELSE    Set Variable    ${loop_alias}
    Run Keyword If    ${flag}==${1}    Append To List    ${active_aliases}    ${split}[1]



DEFAULT FILE READ
    [Arguments]    ${config}    ${value_file}
    ${content}=    OperatingSystem.Get File    ${value_file}
    @{lines}=    Split To Lines    ${content}
    ${lines_length}=    Get Length    ${lines}
    Append To File    ${framework_log_file}    updating config ${config} tags with default values\n
    FOR    ${i}    IN RANGE    ${lines_length}
    ${place_holder}    ${values}=    Run Keyword    Split String From Right    ${lines}[${i}]    ::
    CHANGE_CONFIG    ${config}    ${place_holder}    ${values}
    END


DEFAULT VALUE VALIDATE
    ${aliases}=    Get Dictionary Keys    ${CONFIG_ALIASES}
    FOR    ${i}    IN    @{aliases}
    ${list_out}=    Get From Dictionary    ${CONFIG_ALIASES}    ${i}
    ${value_file}=    Set Variable    ${list_out}[${4}]
    DEFAULT FILE READ    ${i}    ${list_out}[${4}]
    END


DEFAULT VALUE VALIDATE ALIAS
    [Arguments]    ${config}
    ${list_out}=    Get From Dictionary    ${CONFIG_ALIASES}     ${config}
    ${value_file}=    Set Variable    ${list_out}[${4}]
    DEFAULT FILE READ    ${config}    ${list_out}[${4}]


COPY CONFIG
    ${num_of_active_aliases}=    Get Length    ${active_aliases}
    ${config}=    Get Dictionary Keys    ${active_aliases}
    FOR    ${i}    IN    @{config}
    ${config_out}=  Get From Dictionary    ${CONFIG_ALIASES}    ${i}
    ${alias}=    Set Variable    ${config_out}[0]
    ${dest}=    Set Variable    ${config_out}[1]
    ${source}=    Set Variable    ${config_out}[2]
    Switch Connection    ${alias}
    SSHLibrary.Put File    ${source}    ${dest}
    END

COPY CONFIG ALIAS
    [Arguments]    ${config}
    ${config_out}=  Get From Dictionary    ${CONFIG_ALIASES}    ${config}
    ${alias}=    Set Variable    ${config_out}[0]
    ${dest}=    Set Variable    ${config_out}[1]
    ${source}=    Set Variable    ${config_out}[2]
    Switch Connection    ${alias}
    SSHLibrary.Put File    ${source}    ${dest}


SHELL PRECONDITION
    [Timeout]    3 minute
    Append To File    ${framework_log_file}    Executing Shell Precondition\n
    ${shell_pre_status}=    BuiltIn.Run Keyword If    ${shell_config_type}==${1}    BuiltIn.Run Keyword    SHELL CONFIG PRECONDITION
    ...    ELSE    BuiltIn.Run Keyword    SHELL TRADITIONAL PRECONDITION
    [Return]    ${shell_pre_status}


SHELL CONFIG PRECONDITION
    [Timeout]    3 minute
    ${shell_config_pre_length}=    Get Length    ${shell_pre_alias}
    Append To File    ${framework_log_file}    Executing Shell Precondition through Keywords\n
    FOR    ${i}    IN RANGE    ${shell_config_pre_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${shell_pre_alias}[${i}]_SHELL_PRE
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    END
    BuiltIn.Run Keyword If    "${count}"!="${0}"    PREPARE CONFIG FILE
    BuiltIn.Run Keyword If    "${count}"!="${0}"    LOOP EACH CONFIG    @{result}
    ${result}=    Run Keyword If    "${count}"!="${0}"    Set Variable    PASS
    ...    ELSE    Set Variable    NONE   
    [Return]    ${result}


SHELL TRADITIONAL PRECONDITION
    [Timeout]    3 minute
    ${shell_pre_length}=    Get Length    ${shell_pre_alias}
    Append To File    ${framework_log_file}    Executing Shell Precondition through Linux Commands\n
    FOR    ${i}    IN RANGE    ${shell_pre_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${shell_pre_alias}[${i}]_SHELL_PRE
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    ${command}=    Run Keyword If    "${count}"!="${0}"    ENCODE TO STRING    ${result}
    Run Keyword If    "${count}"!="${0}"    Switch Connection    ${shell_pre_alias}[${i}]
    Run Keyword If    "${count}"!="${0}"    SSHLibrary.Execute Command    ${command}
    END
    ${result}=    Run Keyword If    "${count}"!="${0}"    Set Variable    PASS
    ...    ELSE    Set Variable    NONE   
    [Return]    ${result}


SHELL ON CALL CONDITION
    [Timeout]    3 minute
    Append To File    ${framework_log_file}    Executing Shell On Call Condition\n
    ${shell_on_status}=    BuiltIn.Run Keyword If    ${shell_config_type}==${1}    BuiltIn.Run Keyword    SHELL CONFIG ON CALL CONDITION
    ...    ELSE    BuiltIn.Run Keyword    SHELL TRADITIONAL ON CALL CONDITION
    [Return]    ${shell_on_status}


SHELL CONFIG ON CALL CONDITION
    [Timeout]    3 minute
    ${shell_config_on_call_length}=    Get Length    ${shell_on_call_alias}
    Append To File    ${framework_log_file}    Executing Shell on call condition through Keywords\n
    FOR    ${i}    IN RANGE    ${shell_config_on_call_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${shell_on_call_alias}[${i}]_SHELL_ON
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    END
    BuiltIn.Run Keyword If    "${count}"!="${0}"    PREPARE CONFIG FILE
    BuiltIn.Run Keyword If    "${count}"!="${0}"    LOOP EACH CONFIG    @{result}
    BuiltIn.Run Keyword If    ${REMOTE_START_TYPE}==${1}    BuiltIn.Run Keyword And Continue On Failure    IS APPLICATION ALIVE
    ${result}=    Run Keyword If    "${count}"!="${0}"    Set Variable    PASS
    ...    ELSE    Set Variable    NONE   
    [Return]    ${result}


SHELL TRADITIONAL ON CALL CONDITION
    [Timeout]    3 minute
    ${shell_on_call_length}=    Get Length    ${shell_on_call_alias}
    Append To File    ${framework_log_file}    Executing Shell on call condition through Linux Commands\n
    FOR    ${i}    IN RANGE    ${shell_on_call_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${shell_on_call_alias}[${i}]_SHELL_ON
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    ${command}=    Run Keyword If    "${count}"!="${0}"    ENCODE TO STRING    ${result}
    Run Keyword If    "${count}"!="${0}"    Switch Connection    ${shell_on_call_alias}[${i}]
    Run Keyword If    "${count}"!="${0}"    SSHLibrary.Execute Command    ${command}
    END
    BuiltIn.Run Keyword If    ${REMOTE_START_TYPE}==${1}    BuiltIn.Run Keyword And Continue On Failure    IS APPLICATION ALIVE
    ${result}=    Run Keyword If    "${count}"!="${0}"    Set Variable    PASS
    ...    ELSE    Set Variable    NONE   
    [Return]    ${result}

SHELL POST CONDITION
    [Timeout]    3 minute
    Set Test Variable    ${get_post_result}    ${EMPTY}
    Append To File    ${framework_log_file}    Executing Shell Post Condition\n
    ${shell_post_status}=    BuiltIn.Run Keyword If    ${shell_config_type}==${1}    BuiltIn.Run Keyword    SHELL CONFIG POST CONDITION
    ...    ELSE    BuiltIn.Run Keyword    SHELL TRADITIONAL POST CONDITION
    ${shell_post_call_status}=    BuiltIn.Run Keyword If    "${shell_post_status}"=="PASS"    Set Variable    PASS
    ...    ELSE IF    "${shell_post_status}"=="${FAIL}"    Set Variable    FAIL
    ...    ELSE    Set Variable    NONE
    [Return]    ${shell_post_call_status}

SHELL POST CONDITION VALIDATE
    [Timeout]    3 minute
    Append To File    ${framework_log_file}    Execute and Validate Shell Post Condition\n
    Set Test Variable    ${shell_post_validate}    ${SHELL_OUTPUT}
    ${shell_post_length}=    Get Length    ${shell_post_alias}
    Append To File    ${framework_log_file}    Executing Shell post condition\n
    FOR    ${i}    IN RANGE    ${shell_post_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${shell_post_alias}[${i}]_SHELL_POST
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    ${command}=    Run Keyword If    "${count}"!="${0}"    ENCODE TO STRING    ${result}
    Run Keyword If    "${count}"!="${0}"    Switch Connection    ${shell_post_alias}[${i}]
    ${get_shell_output}=    Run Keyword If    "${count}"!="${0}"    SSHLibrary.Execute Command    ${command}
    END
    ${result}=    Run Keyword If    "${count}"!="${0}" and "${get_shell_output}"=="${shell_post_validate}"    Set Variable    PASS
    ...    ELSE    Set Variable    FAIL   
    [Return]    ${result}



SHELL CONFIG POST CONDITION
    [Timeout]    3 minute
    ${shell_config_post_length}=    Get Length    ${shell_post_alias}
    Set Test Variable    @{postshelllist}    @{EMPTY}
    Set Test Variable    ${checkpostresult}    ${EMPTY}
    Set Test Variable    ${getshellpostresult}    ${EMPTY}
    Append To File    ${framework_log_file}    Executing Shell on call condition through Keywords\n
    FOR    ${i}    IN RANGE    ${shell_config_post_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${shell_post_alias}[${i}]_SHELL_POST
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    @{split}=    BuiltIn.Run Keyword If    "${count}"!="${0}"    Split String    ${result}[${i}]    ::
    ${length}=    BuiltIn.Run Keyword If    "${count}"!="${0}"    Get Length    ${split}
    BuiltIn.Run Keyword If    "${count}"!="${0}" and "${length}"=="${1}"    LOOP EACH CONFIG    @{split}
    ${postshellresult}=    BuiltIn.Run Keyword If    "${count}"!="${0}" and "${length}"=="${2}"    LOOP EACH CONFIG POST    ${shell_post_alias}[${i}]    @{split}
    Append To List    ${postshelllist}    ${postshellresult}
    END
    Log Many    ${postshelllist}    ${postshellresult}
    BuiltIn.Run Keyword If    "${count}"!="${0}"    PREPARE CONFIG FILE
    ${checkpostresult}=     BuiltIn.Run Keyword If    "${count}"!="${0}" and "${postshellresult}"!="None"    Count Values In List    ${postshelllist}    ${0}
    ${result}=     BuiltIn.Run Keyword If    "${count}"!="${0}" and "${checkpostresult}"!="None" and "${checkpostresult}"=="${0}"    Set Variable    PASS
    ...    ELSE IF    "${count}"!="${0}" and "${checkpostresult}"!="None" and "${checkpostresult}">"${0}"    Set Variable    FAIL
    ...    ELSE    Set Variable    NONE
    [Return]    ${result}


SHELL TRADITIONAL POST CONDITION
    [Timeout]    3 minute
    ${shell_post_length}=    Get Length    ${shell_post_alias}
    Append To File    ${framework_log_file}    Executing Shell post condition\n
    FOR    ${i}    IN RANGE    ${shell_post_length}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${shell_post_alias}[${i}]_SHELL_POST
    BuiltIn.Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    ${command}=    Run Keyword If    "${count}"!="${0}"    ENCODE TO STRING    ${result}
    Run Keyword If    "${count}"!="${0}"    Switch Connection    ${shell_post_alias}[${i}]
    Run Keyword If    "${count}"!="${0}"    SSHLibrary.Execute Command    ${command}
    END
    ${result}=    Run Keyword If    "${count}"!="${0}"    Set Variable    PASS
    ...    ELSE    Set Variable    NONE   
    [Return]    ${result}


ENCODE TO STRING
    [Arguments]    ${result}
    ${string}=    Set Variable    ${EMPTY}
    FOR    ${i}    IN    @{result}
    ${string}=    Set Variable    ${string}${i};
    END
    [Return]    ${string}


SHELL FILE TO ARRAY
    [Arguments]    ${content}
    [Timeout]    3 minute
    ${end}=    Set Variable    ${TEST_NAME}${postfix}
    @{lines}    Split To Lines    ${content}
    ${source}=    Get Index From List    ${lines}    ${TEST_NAME}
    ${dest}=    Get Index From List    ${lines}    ${end}
    ${line}=    Get Slice From List    ${lines}    ${source}    ${dest}
    ${count}=    Get Length    ${line}
    Run Keyword If    "${count}"!="${0}"    Remove From List    ${line}    0
    [Return]    ${count}    @{line}



