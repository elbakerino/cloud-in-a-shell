#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

conffile=/etc/haproxy/haproxy.cfg

# todo: check if multiple backends doesn't get mixed up

(echo "show backend" | socat stdio /var/run/haproxy.sock) |
  while read backend; do
    if ! echo "${backend}" | grep -q "#"; then
      if ! test -z "${backend}"; then
        echo " Backend:         ${backend}"
        backed_info=$(awk "/^backend ${backend}/,/#----/" ${conffile})

        if echo "${backed_info}" | grep -q "default-server.*"; then
          echo "   Defaults:      $(echo "${backed_info}" | grep -e "default-server.*" | sed 's/  */ /g' | cut -f3- -d" ")"
        fi

        if echo "${backed_info}" | grep -q "^    server .*"; then
          echo "   Servers:"
        else
          echo ""
        fi
        echo "${backed_info}" | grep -oE "^    server .*" |
        while read server; do
          serverinfo="$(echo "${server}" | grep -P -o -e "server .*")"
          serverinfo="$(echo "${server}" | sed 's/  */ /g')"
          echo "     Name:        $(echo "${serverinfo}" | cut -f2 -d" ")"
          echo "     IP:Port:     $(echo "${serverinfo}" | cut -f3 -d" ")"
          # todo: add options per server support
          echo ""
        done

        if echo "${backed_info}" | grep -q "^    server-template .*"; then
          echo "   Server Tpls:"
        else
          echo ""
        fi
        echo "${backed_info}" | grep -oE "^    server-template .*" |
        while read server; do
          serverinfo="$(echo "${server}" | grep -P -o -e "server-template .*")"
          serverinfo="$(echo "${server}" | sed 's/  */ /g')"
          SERV_NAME=$(echo "${serverinfo}" | cut -f2 -d" ")
          echo "     Name:        ${SERV_NAME}"
          echo "     Range:       $(echo "${serverinfo}" | cut -f3 -d" ")"
          echo "     IP:Port:     $(echo "${serverinfo}" | cut -f4 -d" ")"
          # todo: add options per server support
          RANGE_START=$(echo "${serverinfo}" | cut -f3 -d" " | cut -f1 -d"-")
          RANGE_END=$(echo "${serverinfo}" | cut -f3 -d" " | cut -f2 -d"-")

          echo "     Active Servers:"
          printf "       "
          printf "%-$(expr length "${SERV_NAME}${RANGE_END} ")s" "name"
          printf "%-$(expr length "000.0.0.0:255 ")s" "addr:port"
          #printf "%-$(expr length "state ")s" "state"
          #printf "%-$(expr length "check_health ")s" "check_health"
          #printf "%-$(expr length "check_state ")s" "check_state"
          printf "%-$(expr length "status ")s" "status"
          printf "%-$(expr length "check ")s" "check"
          printf "%-$(expr length "total ")s" "total"
          #printf "%-$(expr length "rate ")s" "rate"
          printf "%-$(expr length "lastsess ")s" "lastsess"
          printf "%-$(expr length "last_chk ")s" "last_chk"
          #printf "%-$(expr length "agent_health ")s" "agent_health"
          printf "\n"
          I_INACTIVE=0
          for i in $(seq ${RANGE_START} ${RANGE_END});
          do
            DYN_SERV_INFO=$(echo "show servers state ${backend}" | socat stdio /var/run/haproxy.sock | grep -e "${SERV_NAME}${i} ")
            # be_id be_name srv_id srv_name srv_addr srv_op_state srv_admin_state srv_uweight srv_iweight srv_time_since_last_change srv_check_status srv_check_result srv_check_health srv_check_state srv_agent_state bk_f_forced_id srv_f_forced_id srv_fqdn srv_port srvrecord

            srv_admin_state=$(echo "${DYN_SERV_INFO}" | cut -f7 -d" ") # srv_admin_state, 5 = init, 4=ready

            if [ ${srv_admin_state} = 4 ] || [ ${srv_admin_state} = 12 ]; then
              srv_op_state=$(echo "${DYN_SERV_INFO}" | cut -f6 -d" ") # srv_op_state, 5 = init
              srv_name=$(echo "${DYN_SERV_INFO}" | cut -f4 -d" ") # srv_name
              srv_addr=$(echo "${DYN_SERV_INFO}" | cut -f5 -d" ") # srv_addr
              srv_check_health=$(echo "${DYN_SERV_INFO}" | cut -f13 -d" ") # srv_check_health
              srv_check_state=$(echo "${DYN_SERV_INFO}" | cut -f14 -d" ") # srv_check_state
              srv_port=$(echo "${DYN_SERV_INFO}" | cut -f19 -d" ") # srv_port
              printf "       "
              printf "%-$(expr length "${SERV_NAME}${RANGE_END} ")s" "${srv_name}"
              printf "%-$(expr length "000.0.0.0:255 ")s" "${srv_addr}:${srv_port}"
              #if [ ${srv_admin_state} = 4 ]; then
              #  printf "%-$(expr length "state ")s" "ready"
              #elif [ ${srv_admin_state} = 12 ]; then
              #  printf "%-$(expr length "state ")s" "drain"
              #fi
              #printf "%-$(expr length "check_health ")s" "${srv_check_health}"
              #printf "%-$(expr length "check_state ")s" "${srv_check_state}"
              DYN_SERV_STATS=$(echo "show stat" | socat stdio /var/run/haproxy.sock | grep -F "${backend},${SERV_NAME}${i},")
              # pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,ses_tot,cli_abrt,srv_abrt,comp_in,comp_out,comp_byp,comp_rsp,lastsess,last_chk,last_agt,qtime,ctime,rtime,ttime,agent_status,agent_code,agent_duration,check_desc,agent_desc,check_rise,check_fall,check_health,agent_rise,agent_fall,agent_health,addr,cookie,mode,algo,conn_rate,conn_rate_max,conn_tot,intercepted,dcon,dses,
              # todo: check nums, already checked in bash but isn't the same as the headers
              status=$(echo "${DYN_SERV_STATS}" | cut -f18 -d",")
              check_status=$(echo "${DYN_SERV_STATS}" | cut -f37 -d",")
              #check_code=$(echo "${DYN_SERV_STATS}" | cut -f38 -d",")
              ses_tot=$(echo "${DYN_SERV_STATS}" | cut -f31 -d",")
              req_rate=$(echo "${DYN_SERV_STATS}" | cut -f50 -d",")
              lastsess=$(echo "${DYN_SERV_STATS}" | cut -f56 -d",")
              last_chk=$(echo "${DYN_SERV_STATS}" | cut -f57 -d",")
              #agent_health=$(echo "${DYN_SERV_STATS}" | cut -f77 -d",")
              printf "%-$(expr length "status ")s" "${status}"
              printf "%-$(expr length "check ")s" "${check_status}"
              printf "%-$(expr length "total ")s" "${ses_tot}"
              #printf "%-$(expr length "rate ")s" "${req_rate}"
              printf "%-$(expr length "lastsess ")s" "${lastsess}"
              printf "%-$(expr length "      ")s" "${last_chk}"
              #printf "%-$(expr length "agent_health ")s" "${agent_health}"
              printf "\n"
            elif [ ${srv_admin_state} = 5 ]; then
              I_INACTIVE=$(expr ${I_INACTIVE} '+' 1)
            else
              echo "  !> unkown admin_state: ${srv_admin_state}"
            fi
          done
          echo "     Server Inactive: ${I_INACTIVE}"
        done
        echo ""
      fi
    fi
  done

echo " Stats:"
STATS_PORT=$(cat ${conffile} | grep -A1 "listen stats.*" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' | sed 's/  */ /g' | cut -f2 -d":" | cut -f1 -d" ")
STATS_PATH=$(cat ${conffile} | grep -o "stats uri.*" | cut -f3 -d" ")
echo "   Server:        $(ip route get 8.8.8.8 | awk '{print $7}'):${STATS_PORT}${STATS_PATH}"

echo "   Auth User:     $(cat ${conffile} | grep -o "stats auth.*" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' | sed 's/  */ /g' | cut -f3- -d" " | cut -f1 -d":")"

# insecure?
echo "   Auth Pass:     $(cat ${conffile} | grep -o "stats auth.*" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' | sed 's/  */ /g' | cut -f3 -d" " | cut -f2 -d":")"

if firewall-cmd --list-all | grep -qe "ports.*.${STATS_PORT}"; then
  echo "   Firewall Rule: ✓"
else
  echo "   Firewall Rule: X"
  read -p "    Create Public Firewall Rule? y/N " create_fw

  if test -z "${create_fw}" || [[ ${create_fw} = "n" ]] || [[ ${create_fw} = "N" ]]; then
    echo "    skipping firewall rule creation."
  else
    if [[ ${create_fw} = "y" ]] || [[ ${create_fw} = "Y" ]]; then
      echo "    creating firewall rule.."
      firewall-cmd --zone=public --add-port=${STATS_PORT}/tcp --permanent
      firewall-cmd --reload
      if firewall-cmd --list-all | grep -q " port=\"${STATS_PORT}\""; then
        echo "    Stats Firewall Rule: ✓"
      else
        echo "    Stats Firewall Rule: X"
      fi
    else
      echo "    skipping firewall rule creation."
    fi
  fi
fi

echo ""
