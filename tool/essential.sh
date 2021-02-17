#!/bin/bash
#############################################
#Essentials - beautified basic script functions
#############################################

essentials_load(){
    essentials_timestamp="$(stat -c %Y "$(dirname $0)/$(basename $0)" | awk '{print strftime("%d.%m.%Y %H:%M", $1)}')"
    essentials_success="[\e[32m ✓ \e[0m]"
    essentials_info="[\e[33m i \e[0m]"
    essentials_error="[\e[31m X \e[0m]"
    essentials_time
}

essentials_time(){
    essentials_time_epoch=$(date +%s)
    essentials_time_second=$(date +%S)
    essentials_time_minute=$(date +%M)
    essentials_time_hour=$(date +%H)
    essentials_time_day=$(date +%d)
    essentials_time_month=$(date +%m)
    essentials_time_year=$(date +%Y)
    essentials_time_full=$(date '+%Y-%m-%d_%H%M%S')
    essentials_time_fancy=$(date '+%d.%m.%Y %H:%M:%S')
}

essentials_file_timestamp(){
  essentials_file_timestamp_path=$1
  case "${2}" in
  "second")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%S", $1)}')"
	;;
	"minute")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%M", $1)}')"
	;;
  "hour")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%H", $1)}')"
	;;
  "day")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%d", $1)}')"
	;;
  "month")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%m", $1)}')"
	;;
	"year")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%Y", $1)}')"
	;;
	"full")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%Y-%m-%d_%H%M%S", $1)}')"
	;;
	"fancy")
    essentials_file_timestamp_return="$(stat -c %Y "${essentials_file_timestamp_path}" | awk '{print strftime("%d.%m.%Y %H:%M:%S", $1)}')"
	;;
    esac

    echo -e "${essentials_file_timestamp_return}"
}

essentials_sudo_check(){
  if [[ "${EUID}" -ne 0 ]];then
        [[ "${1}" == "exit" ]]; echo -e "${essentials_error} please run as root! :("; exit
        return 0
  else
        return 1
  fi
}

essentials_text_green(){
    echo -e "\e[32m${1}\e[0m"
}

essentials_text_yellow(){
    echo -e "\e[33m${1}\e[0m"
}

essentials_text_red(){
    echo -e "\e[31m${1}\e[0m"
}

essentials_text_darkgray(){
    echo -e "\e[90m${1}\e[0m"
}

essentials_text_lightmagenta(){
    echo -e "\e[95m${1}\e[0m"
}

essentials_text_lightcyan(){
    echo -e "\e[36m${1}\e[0m"
}

essentials_text_spacer() {
    echo -e "$(essentials_text_darkgray "======================================================")"
}

essentials_text_uppercase() {
    echo -e "${1^^}"
}

essentials_text_lowercase() {
    echo -e "${1,,}"
}
essentials_update(){
    echo -e "${essentials_info} updating global essentials version in $(essentials_text_yellow "/usr/bin").."
    cp $(basename "$0") /usr/bin
}

essentials_mail(){
    echo -e "${essentials_mail_body}" | sed 's/$/<br>/' | mail \
    -a "From: ${essentials_mail_from}" \
    -a "MIME-Version: 1.0" \
    -a "Content-Type: text/html" \
    -s "${essentials_mail_subject}" \
    ${essentials_mail_to}
}

essentials_info(){
    clear
    essentials_load
    echo -e "IMPLEMENTATION"
    echo
    echo -e "\tadd $(essentials_text_yellow "source $(basename "$0")") below your shebang line to implement essentials"
    echo
    echo -e "VARIABLES"
    echo
    echo -e "\texample usage: $(essentials_text_yellow "[echo (-e)] \\${varname}")"
    echo
    echo -e "\tVARIABLE NAME\t\t\t\t| OUTPUT"
    echo -e "\tessentials_time_epoch\t\t\t| ${essentials_time_epoch}"
    echo -e "\tessentials_time_second\t\t\t| ${essentials_time_second}"
    echo -e "\tessentials_time_minute\t\t\t| ${essentials_time_minute}"
    echo -e "\tessentials_time_hour\t\t\t| ${essentials_time_hour}"
    echo -e "\tessentials_time_day\t\t\t| ${essentials_time_day}"
    echo -e "\tessentials_time_month\t\t\t| ${essentials_time_month}"
    echo -e "\tessentials_time_year\t\t\t| ${essentials_time_year}"
    echo -e "\tessentials_time_full\t\t\t| ${essentials_time_full}"
    echo -e "\tessentials_time_fancy\t\t\t| ${essentials_time_fancy}"
    echo -e "\tessentials_success\t\t\t| ${essentials_success}"
    echo -e "\tessentials_info\t\t\t\t| ${essentials_info}"
    echo -e "\tessentials_error\t\t\t| ${essentials_error}"
    echo
    echo -e "FUNCTIONS"
    echo
    echo -e "\texample usage: $(essentials_text_yellow "\$(essentials_function \"<value>\")")"
    echo
    echo -e "\tBASIC FUNCTIONS\t\t\t\t| OUTPUT"
    echo -e "\t$(essentials_text_green "essentials_text_green")\t\t\t| $(essentials_text_green "example")"
    echo -e "\t$(essentials_text_green "essentials_text_yellow")\t\t\t| $(essentials_text_yellow "example")"
    echo -e "\t$(essentials_text_green "essentials_text_red")\t\t\t| $(essentials_text_red "example")"
    echo -e "\t$(essentials_text_green "essentials_text_darkgray")\t\t| $(essentials_text_darkgray "example")"
    echo -e "\t$(essentials_text_green "essentials_text_lightcyan")\t\t| $(essentials_text_lightcyan "example")"
    echo -e "\t$(essentials_text_green "essentials_text_lightmagenta")\t\t| $(essentials_text_lightmagenta "example")"
    echo -e "\t$(essentials_text_green "essentials_text_spacer")\t\t\t| $(essentials_text_spacer)"
    echo -e "\t$(essentials_text_green "essentials_text_uppercase")\t\t| $(essentials_text_uppercase example)"
    echo -e "\t$(essentials_text_green "essentials_text_lowercase")\t\t| $(essentials_text_lowercase example)"
    echo -e "\t$(essentials_text_green "essentials_sudo_check") $(essentials_text_yellow "[exit]")\t\t| $(essentials_sudo_check)$? (read returncode via \$?)"
    echo
    echo
    echo -e "\tFILE TIMESTAMP\t\t\t\t| OUTPUT"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> second\t| $(essentials_file_timestamp $0 second)"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> minute\t| $(essentials_file_timestamp $0 minute)"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> hour\t| $(essentials_file_timestamp $0 hour)"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> day\t| $(essentials_file_timestamp $0 day)"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> month\t| $(essentials_file_timestamp $0 month)"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> year\t| $(essentials_file_timestamp $0 year)"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> full\t| $(essentials_file_timestamp $0 full)"
    echo -e "\t$(essentials_text_green "essentials_file_timestamp") <file> fancy\t| $(essentials_file_timestamp $0 fancy)"
    echo
    echo -e "\tMAIL USAGE"
    echo -e "\tvars to fill:"
    echo -e "\t$(essentials_text_yellow "essentials_mail_from") $(essentials_text_darkgray "#essentials_mail_from=\"address@host.tld\"")"
    echo -e "\t$(essentials_text_yellow "essentials_mail_to") $(essentials_text_darkgray "#essentials_mail_to=\"recipient@host.tld\" - use comma separation for multiple recipients")"
    echo -e "\t$(essentials_text_yellow "essentials_mail_body") $(essentials_text_darkgray "#essentials_mail_body=\"<b>Text</b>\" - html allowed")"
    echo -e "\t$(essentials_text_yellow "essentials_mail_subject") $(essentials_text_darkgray "#essentials_mail_subject\"sample subject\"")"
    echo -e "\tcall function:"
    echo -e "\t$(essentials_text_green "essentials_mail") $(essentials_text_darkgray "#send mail")"
}

essentials_load;
#TODO better update/deploy
if [[ "${1}" == "core" ]];then
    if [[ "${2}" == "info" ]];then
        essentials_info;
    elif [[ "${2}" == "update" ]];then
        essentials_update
    fi
fi
