#!/bin/bash
################################################
# Veritas hasum command                        #
# Created: Ottó Király                         #
# Last modification: 2022.11.03                #
################################################
VERSION=1.0004;
case $@ in
   -[cC]*) printf "\nGroup%10s"; for i in `sudo /opt/VRTS/bin/hasys -list`; do printf '%-16s' $i; done; echo -e '\n';
                for i in `sudo /opt/VRTS/bin/hagrp -list | cut -d' ' -f1 | uniq`; do
                        printf "%-15s" $i; OUT='\t';
                        HAGSTATE=$(sudo /opt/VRTS/bin/hagrp -state | tr '\n' '@');
                        for j in `sudo /opt/VRTS/bin/hasys -list`; do
                                var=$(echo $HAGSTATE | tr '@' '\n' | grep -i $i | grep -i $j | awk 'BEGIN {FS=" "}{print $4}' | tr '\n' ' ');
                                case $var in
                                        *ONL*) printf '\e[0;32m%-16s\e[0m' $var;;
                                        *FAU*) printf '\e[1;31m%-16s\e[0m' $var;;
                                        *UNK*) printf '\e[1;33m%-16s\e[0m' $var;;
                                        *) printf '%-16s' $var;;
                                esac
                        done
                        echo -e $OUT;
                done;;
    -[hH?]*) echo 'help';;
    *) printf "\nGroup%5s"; echo -e "\t$(sudo /opt/VRTS/bin/hasys -list | tr '\n' '\t\t')\n";for i in `sudo /opt/VRTS/bin/hagrp -list | cut -d' ' -f1 | uniq`; do printf "%-10s" $i; echo -e "\t$(sudo /opt/VRTS/bin/hagrp -state | grep -i $i | awk 'BEGIN {FS=" "}{print $4}' | tr '\n' '\t\t')"; done;;
esac
