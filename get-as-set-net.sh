#!/bin/bash

#as-set or asnum (AS-SET/ASNUM)
ASOBJECT=$1
BASE=`whois -h whois.radb.net $ASOBJECT | egrep "(aut-name|as-name|org|status)"`

varasset=`echo $ASOBJECT | grep -P "AS\-"`
varasnum=`echo $ASOBJECT | grep -P "AS\d"`

SCF="["
SCB="]"

ARG=""
ARG=$2

TMP="/tmp/"

############################################################################FUNCTION#############################################################################

help () {
       echo -e "В качестве аргумента используем объект ASSET или ASNUM, без параметров будет отображаться общая информация по AS-NUM или вложения для ASSET"
       echo ""
       echo "ПАРАМЕТРЫ: "
       echo -e "\t1) --net = Вывод списка подсетей ipv4, описанных в route object"
       echo -e "\t2) --net6 = Вывод списка подсетей ipv6, описанных в route6 object"
       echo -e "\t3) --netsrc = Вывод списка подсетей ipv4 и на каком RIR зарегистрирована"
       echo ""
	}

main () {
	echo -e "\e[41mTYPE: $TYPE\e[0m"
	echo -e "\e[41mASOBJECT: $ASOBJECT\e[0m"
	echo "$BASE"
	echo ""
	}

partyrun () {
        whois -h whois.radb.net $ASOBJECT |  awk '/members\:/ {print $2}' > $TMP$ASOBJECT
        echo -e "\e[41m$SCF $ASOBJECT $SCB\e[0m"
        cat $TMP$ASOBJECT | while read ASOBJECT
        do
                varasset=`echo $ASOBJECT | grep -P "[aA][sS]\-"`
                varasnum=`echo $ASOBJECT | grep -P "[aA][sS]\d"`
                [ -n "$varasset" ] && TYPE="ASSET"
                [ -n "$varasnum" ] && TYPE="ASNUM"
                if [ "$TYPE" == "ASSET" ]
                then
                        SCF=$SCF
                        SCB=$SCB
                        echo ""
                        partyrun
                else
                        echo " --"$SCF $ASOBJECT $SCB"--"

                    if [ "$ARG" == "--net" ]; then
				echo ""
				echo -e "\e[41m#####NETWORK FOR IPv4#####\e[0m"
                                whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/route:/ {print " "$2}'
                                echo ""
                    elif [ "$ARG" == "--net6" ]; then
				echo ""
				echo -e "\e[41m#####NETWORK FOR IPv6#####\e[0m"
				whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/route6:/ {print " "$2}'
				echo ""
		    elif [ "$ARG" == "--netsrc" ]; then
				echo ""
				echo -e "\e[41m##########SOURCE FOR NETWORK##########\e[0m"
				num=1
				for network in `whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/route:/ {print " "$2}'`
					do
						source=`whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/source:/ {print " "$2}' | sed -n "${num}p"`
						echo -e "$network is described by$source"
						echo ""
						num=$(($num + 1))
					done
                   fi

                fi
        done
        echo ""
        rm -f $TMP$ASOBJECT
	}

###############################################################################END######################################################################################


[ -n "$varasset" ] && TYPE="ASSET"
[ -n "$varasnum" ] && TYPE="ASNUM"

if [ -z "$ASOBJECT" -o "$ASOBJECT" == "--help" ]
then
	echo ""
        echo -e "\e[41m***Указываем объект для WHOIS***\e[0m" >&2
        help >&2

elif [ -n "$ASOBJECT" -a "$TYPE" == "ASSET" ]; then
	if [ "$ARG" == "--help" ]; then
	help
	else main && partyrun
	fi
elif [ -n "$ASOBJECT" -a "$TYPE" == "ASNUM" ]; then
	case "$ARG" in
--net)		echo ""
		echo -e "\e[41m#####NETWORK FOR IPv4#####\e[0m"
                whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/route:/ {print " "$2}'
                echo ""
;;
--net6)
		echo ""
		echo -e "\e[41m#####NETWORK FOR IPv6#####\e[0m"
                whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/route6:/ {print " "$2}'
                echo ""
;;
--netsrc)
				echo ""
				echo -e "\e[41m##########SOURCE FOR NETWORK##########\e[0m"
                                num=1
                                for network in `whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/route:/ {print " "$2}'`
                                        do
                                                source=`whois -h whois.radb.net -r -i origin $ASOBJECT | awk '/source:/ {print " "$2}' | sed -n "${num}p"`
                                                echo -e "$network is described by$source"
						echo ""
                                                num=$(($num + 1))
					done
;;
--help)
       		 help
        	 exit
;;
*)
	         main
;;
	esac
fi
