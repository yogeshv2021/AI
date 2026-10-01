*** Settings ***
Library           Collections
Library           SSHLibrary    5min
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Process
Library           XML
Library           /opt/product/Automation_Softwares/ROBOT_FRAMEWORK_SUPPORTING_LIB/robotframework-requests-master/src/RequestsLibrary/RequestsKeywords.py

*** Variables ***

*** Keyword ***
XML
    Set Test Variable    @{xml_results}    @{EMPTY}
    ${num_of_xml}=    Get Length    ${XML_VALIDATE_PATH}
    FOR    ${i}    IN RANGE    ${num_of_xml}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${XML_ALIAS}[${i}]_XML_REQ
    Run Keyword If    "${count}"!="${0}"    WRITE LATEST REF FILE    ${current_content}\n
    ${xml_parsed_flag}=    Run Keyword If    "${count}"!="${0}"    XML REQUEST PARSE    ${i}    ${TCP_SERVER}[${i}]    ${TCP_PORT}[${i}]    @{result}
    Append To List    ${xml_results}    ${xml_parsed_flag}
    END
    ${xml_flag}=    Count Values In List    ${xml_results}   ${0}
    ${xml_flag}=    Run Keyword If    ${xml_flag}>${0}    Set Variable    ${Fail}
    ...    ELSE    Set Variable    ${Pass}
    [Return]    ${xml_flag}


Define example protocol
    [Arguments]    ${name}=Example
    New protocol    ${name}
    u16    length    # Empty on purpose, the length is pdu length
    pdu    length-8
    End protocol


XML REQUEST PARSE
    [Arguments]    ${index}    ${ip}    ${port}    @{result}
    Set Test Variable    @{xml_parsed_results}    @{EMPTY}
    Define example protocol
    log many    ${ip}    ${port}
    Start TCP client    protocol=Example
    connect    ${ip}    ${port}
    FOR    ${i}    IN    @{result}
    ${xml_request}    ${xml_values_array}=    Split String    ${i}    ,    1
    ${is_value_present}=    Get Length    ${xml_values_array}
    ${xml_way_flag}    ${xml_values_array}=    Run Keyword If    ${is_value_present}>${0}    Split String    ${xml_values_array}    ,    1
    ${is_value_present}=    Get Length    ${xml_values_array}
    ${file_content}=    Run Keyword If    ${is_value_present}>${0}    XML VALUE REPLACE    ${index}    ${xml_request}    ${xml_values_array}
    ${file_content}=    Run Keyword If    ${is_value_present}>${0}    XML DEFAULT VALUE FILL    ${xml_request}    ${file_content}    ${index}
    log    ${file_content}
    ${resp}=    Run Keyword If    ${xml_way_flag}==${1}    XML SEND RECEIVE    ${is_value_present}    ${file_content}
    ...    ELSE IF    ${xml_way_flag}==${2}    XML SEND    ${is_value_present}    ${file_content}
    ...    ELSE    XML RECEIVE
    ${xml_resp_flag}=    Run Keyword If    ${xml_way_flag}!=${2}    Run Keyword If    ${is_value_present}>${0}    XML RESPONSE VALIDATE    ${index}    ${xml_request}    ${resp}
    Run Keyword If    ${xml_way_flag}!=${2}    Append To List    ${xml_parsed_results}    ${xml_resp_flag}
    END
    ${xml_parsed_flag}=    Count Values In List    ${xml_parsed_results}   ${0}
    ${xml_parsed_flag}=    Run Keyword If    ${xml_parsed_flag}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    [Return]    ${xml_parsed_flag}

XML SEND RECEIVE
    [Arguments]    ${is_value_present}    ${string}
    ${binary}=    Run Keyword If    ${is_value_present}>${0}    STRING TO HEX    ${string}
    ${binary}=    Run Keyword If    ${is_value_present}>${0}    Hex to bin    0x${binary}
    Client sends binary    ${binary}
    ${resp}=    Client receives binary
    log    ${resp}
    ${resp}=    Get Substring    ${resp}    9
    log    ${resp}
    [Return]    ${resp}

XML SEND
    [Arguments]    ${is_value_present}    ${string}
    ${binary}=    Run Keyword If    ${is_value_present}>${0}    STRING TO HEX    ${string}
    ${binary}=    Run Keyword If    ${is_value_present}>${0}    Hex to bin    0x${binary}
    Client sends binary    ${binary}
    [Return]    ${1}

XML RECEIVE
    ${resp}=    Client receives binary
    [Return]    ${resp}

XML VALUE REPLACE
    [Arguments]    ${index}    ${xml_request}    ${xml_values_array}
    ${file_content}=    OperatingSystem.Get File    ${XML_VALIDATE_PATH}[${index}]${xml_request}_TEMPLATE.xml
    @{values}=    Split String    ${xml_values_array}    ,
    FOR    ${i}    IN    @{values}
    ${place_holder}    ${value}=    Split String    ${i}    ::    1
    ${file_content}=    Replace String    ${file_content}    ${place_holder}    ${value}
    END
    [Return]    ${file_content}


XML RESPONSE VALIDATE
    [Arguments]    ${index}    ${xml_request}    ${resp}
    Set Test Variable    @{xml_response_results}    @{EMPTY}
    Set Test Variable    ${XML}    ${EMPTY}
    ${count}    ${current_content}    @{result}=    INPUT FILE PROCESSING    ${XML_ALIAS}[${index}]_${xml_request}
    @{file_outputs}=     Split String    ${result}[${0}]    ,
    ${root}=    PARSE XML    ${resp}
    log    ${root.tag}
    ${ele}=    Get Element    ${resp}    ${root.tag}/ERROR_CODE
    log    ${ele}
    FOR    ${i}    IN    @{file_outputs}
    @{temp}=    Split String    ${i}    ::
    log many    @{temp}
    ${value}=    Run Keyword If    ${temp}[2]==0    BuiltIn.Run Keyword And Continue On Failure    XML VALUE CHECK    ${root}    ${temp}[1]    ${temp}[0]
    ...    ELSE    BuiltIn.Run Keyword And Continue On Failure    XML TYPE CHECK    ${root}    ${temp}[1]    ${temp}[0]
    log    ${value}
    Append To List    ${xml_response_results}    ${value}
    END
    ${xml_resp_flag}=    Count Values In List    ${xml_response_results}   ${False}
    ${xml_resp_flag}=    Run Keyword If    ${xml_resp_flag}>${0}    Set Variable    ${0}
    ...    ELSE    Set Variable    ${1}
    [Return]    ${xml_resp_flag}

XML VALUE CHECK
    [Arguments]    ${root}    ${temp1}    ${temp0}
    ${values}=    Run Keyword And Return Status    Element Text Should Be    ${root}    ${temp1}    ${temp0}
    [Return]    ${values}

XML TYPE CHECK
    [Arguments]    ${root}    ${temp1}    ${temp0}
    ${values}=    Run Keyword And Return Status    Element Text Should Match    ${root}    ${temp1}    ${temp0}
    [Return]    ${values}


XML DEFAULT VALUE FILL
    [Arguments]    ${xml_request}    ${file_content}    ${index}
    ${content}=    OperatingSystem.Get File    ${XML_VALIDATE_PATH}[${index}]${xml_request}_VALUES.txt
    @{lines}=    Split To Lines    ${content}
    ${lines_length}=    Get Length    ${lines}
    FOR    ${i}    IN RANGE    ${lines_length}
    ${place_holder}    ${values}=    Run Keyword    Split String From Right    ${lines}[${i}]    ::
    ${file_content}=    Replace String    ${file_content}    ${place_holder}    ${values}
    END
    [Return]    ${file_content}
 

