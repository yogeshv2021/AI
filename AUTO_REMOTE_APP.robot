*** Settings ***
Library           Collections
Library           SSHLibrary
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           DateTime
Library           Collections



*** Variables ***



*** Keyword ***
START REMOTE APP
    [Arguments]    ${alias}
    ${app_product}=    Get From Dictionary    ${alias_script_map}    ${alias}
    ${framework_log_file}=    Set Variable    ${AUTOMATION_TEMP_PATH}/FRAMEWORK_LOG.txt
    FOR    ${i}    IN    @{app_product}
    START APP    ${i}
    END
    Sleep    ${SLEEP_TIME}S


IS APPLICATION ALIVE
    ${binaries}=    Get Dictionary Keys    ${PRODUCT_SERVER_DICTIONARY}
    FOR    ${i}    IN    @{binaries}
    CHECK REMOTE APP    ${i}
    END


KILL ALL APPLICATION
    ${binaries}=    Get Dictionary Keys    ${PRODUCT_SERVER_DICTIONARY}
    ${framework_log_file}=    Set Variable    ${AUTOMATION_TEMP_PATH}/FRAMEWORK_LOG.txt
    FOR    ${i}    IN    @{binaries}
    KILL REMOTE APP    ${i}
    END
    Remove File    ${AUTOMATION_TEMP_PATH}/FRAMEWORK_LOG.txt


CHECK REMOTE APP
    [Arguments]    ${product}
    ${alias}=    Get From Dictionary    ${PRODUCT_SERVER_DICTIONARY}    ${product}
    Switch Connection    ${alias}
    ${cmd}=    Set Variable    ps -ef | grep ${product} | grep -v grep | awk '{print $2}'
    ${pid}=    SSHLibrary.Execute Command    ${cmd}
    ${pid_length}=    Get Length    ${pid}
    ${app_script}=    Run Keyword If    ${pid_length}==${0}    Get From Dictionary    ${PRODUCT_SCRIPT_DICTIONARY}    ${product}
    ${path}    ${sh_file}=    Run Keyword If    ${pid_length}==${0}       Split String From Right    ${app_script}    :    1
    Run Keyword If    ${pid_length}==${0}       SSHLibrary.Start Command    cd ${path};${sh_file}
    Run Keyword If    ${pid_length}==${0}    Sleep    ${SLEEP_TIME}S

START APP
    [Arguments]    ${product}
    ${alias}=    Get From Dictionary    ${PRODUCT_SERVER_DICTIONARY}    ${product}
    Switch Connection    ${alias}
    Append To File    ${framework_log_file}    connected to server ${alias} and starting ${product}\n
    ${app_script}=    Get From Dictionary    ${PRODUCT_SCRIPT_DICTIONARY}    ${product}
    ${path}    ${sh_file}=    Split String From Right    ${app_script}    :    1
    SSHLibrary.Start Command    cd ${path};${sh_file}
    Sleep    ${1}S

REMOTE COMMAND EXECUTE
    [Arguments]    ${alias}    ${cmd}
    Switch Connection    ${alias}
    SSHLibrary.Execute Command    ${cmd}

KILL REMOTE APP
    [Arguments]    ${product}
    ${alias}=    Get From Dictionary    ${PRODUCT_SERVER_DICTIONARY}    ${product}
    Switch Connection    ${alias}
    Append To File    ${framework_log_file}    connected to server ${alias} and killing ${product}\n
    ${cmd}=    Set Variable    sudo ps -ef | grep -w ${product} | grep -v grep | awk '{print $2}' | sudo xargs kill -9
    SSHLibrary.Execute Command    ${cmd}
    Sleep    ${SLEEP_TIME}S

KILL REMOTE APPS
    [Arguments]    ${product}
    @{products}=    Split String    ${product}    ${SPACE}
    FOR    ${i}    IN    @{products}
    ${alias}=    Get From Dictionary    ${PRODUCT_SERVER_DICTIONARY}    ${i}
    Switch Connection    ${alias}
    Append To File    ${framework_log_file}    connected to server ${alias} and killing ${i}\n
    ${cmd}=    Set Variable    ps -ef | grep -w ${i} | grep -v grep | awk '{print $2}' | xargs kill -9
    SSHLibrary.Execute Command    ${cmd}
    END
    Sleep    ${SLEEP_TIME}S

GRACE EXIT REMOTE APP
    [Arguments]    ${product}    ${sleeptime}
    ${alias}=    Get From Dictionary    ${PRODUCT_SERVER_DICTIONARY}    ${product}
    ${kill_signal}=    Get From Dictionary    ${GRACE_EXIT_DICTIONARY}    ${product}
    Switch Connection    ${alias}
    Append To File    ${framework_log_file}    connected to server ${alias} and killing gracefully ${product}\n
    ${cmd}=    Set Variable    ps -ef | grep -w ${product} | grep -v grep | awk '{print $2}' | xargs ${kill_signal}
    SSHLibrary.Execute Command    ${cmd}
    Sleep    ${sleeptime}S

RESTART REMOTE APP
    [Arguments]    ${product}
    KILL REMOTE APP    ${product}
    START APP    ${product}

RESTART REMOTE APP GRACEFULLY
    [Arguments]    ${product}    ${sleeptime}
    GRACE EXIT REMOTE APP    ${product}    ${sleeptime}
    START APP    ${product}

