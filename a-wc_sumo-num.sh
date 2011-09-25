#!/bin/bash

# Copyright 2011 Popov Igor
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

WAY="./won_matches.txt"  #using won_matches to get id and score; change when scipt path is changed
NUM_OLD="0" #necessary to clear var starting script
NAMEBASE="./namebase.txt" #here namebase is built
NUM_PLAYERS="0"

while true
 do
 line=""
 read line

#size_factor modification

if [ "${line:0:10}" == "NUM_HUMANS" ]
 then
    echo "$line" | awk '{print $2}' > num_humans.txt #in result change size_factor depending on number of players
    NUM=`cat num_humans.txt`
    if [ $NUM -ne $NUM_OLD ]
     then
        if [ $NUM -le 3 ]
	 then
	    echo "SIZE_FACTOR -2"
	 elif [ $NUM -eq 4 ]
	  then
	    echo "SIZE_FACTOR -1"
	 else
	    echo "SIZE_FACTOR 0"
	fi
	NUM_OLD=`echo $NUM`
    fi
fi

#build name base and show players's won matches position

if [ "${line:0:14}" == "PLAYER_RENAMED" ]
 then
    echo "$line" | awk '{print $3}' | grep "@" > /dev/null 2>&1
    if [ $? -eq 0 ]
     then
	WORDS=`echo "$line" | wc -w` #generate cut range step 1
	CUT_WORDS=`seq 6 $WORDS` #generate cut range step 2
	CUT_WORDS=`echo $CUT_WORDS | sed 's/ /,/g'` #generate cut range step 3
	echo "$line" | cut -d' ' -f`echo $CUT_WORDS` > namebase_realname # current player name to file
	CURRENT_NAME_G=`cat namebase_realname` # got name from this file with gaps
	CURRENT_NAME=`echo "$CURRENT_NAME_G" | sed 's/ /_/g'` #gaps confuse /rank statistic, get rid of gaps
        SINGLE_ID=`echo "$line" | cut -d' ' -f3` #got GLOBAL_ID
	SINGLE_IP=`echo "$line" | cut -d' ' -f4` #got Player's IP to check with ip_list.txt and show or not to show statistic when PLAYER_RENAMED found in ladderlog
	SERVER_NAME=`echo "$line" | cut -d' ' -f2` #got server name (for player_message)
	ROW_TO_DATABASE=`echo "$SINGLE_ID $CURRENT_NAME"` # THIS is data to NAMEBASE
	cat $NAMEBASE | grep "^$SINGLE_ID" > /dev/null 2>&1 #found ID in name base
	if [ $? -ne 0 ] # if player has never been on server before
         then
    	    echo "$ROW_TO_DATABASE" >> "$NAMEBASE"
    	else 	# if he was here, remove previous record from base and put this with new name
    	    cat $NAMEBASE | grep -v "$SINGLE_ID" | awk '{print $0}' > new_base.txt #got rid of row with the same GLOBAL ID
    	    mv new_base.txt $NAMEBASE
    	    echo "$ROW_TO_DATABASE" >> "$NAMEBASE" # and put new record at the end of name base
	fi
	#show players's statistic on enter and create ip_list.txt for : 1) he just entered so show him welcome message with his won_matches position
	#2) put name with into ip_list.txt for /location command
	cat $WAY | grep "$SINGLE_ID" > /dev/null
	if [ $? -eq 0 ]
	 then
	    cat ip_list.txt | grep "$SINGLE_IP" > /dev/null
	    if [ $? -ne 0 ]
	     then #his ip is NOT in ip_list.txt so show him welcome message
		ENTER_POSITION=`cat -n $WAY | grep "$SINGLE_ID" | awk '{print $1}'` #position
	        echo "PLAYER_MESSAGE \"$SINGLE_ID\" \"0xffffffWelcome 0x00baff${CURRENT_NAME_G}0xffffff! 0xffed44You are at position 0xff4e00$ENTER_POSITION 0xffed44in won multiplayer matches list.\""
	        echo "$SINGLE_IP $SINGLE_ID $CURRENT_NAME_G" >> ip_list.txt #getting players ip in ip_list.txt right after he gets statistic information.... if he try to be renamed more per game statistic message wont be shown
	    fi
	else # he did not win any matches yet but we need his ip and name in ip_list.txt for /location command
		cat ip_list.txt | grep "$SINGLE_IP" > /dev/null
		if [ $? -ne 0 ] # if he is not in ip_list.txt yet
		 then
			echo "$SINGLE_IP $SINGLE_ID $CURRENT_NAME_G" >> ip_list.txt
		fi
	fi
# here is a part of /later, checking incoming messages
        WC_MSG=`cat later.txt | awk '{print $2}' | grep "$SINGLE_ID" | wc -l`
                if [ "$WC_MSG" -eq 1 ]; then
                        message="message"
                elif [ "$WC_MSG" -gt 1 ]; then
                        message="messages"
                fi
        CHECK_ID=`cat later.txt | awk '{print $2}' | grep "$SINGLE_ID" | tail -1`
        if [ "$CHECK_ID" == "$SINGLE_ID" ]; then
                echo "PLAYER_MESSAGE \"$SINGLE_ID\" \"\n0xaaffffYou have 0xffaaff$WC_MSG 0xaaffffnew $message\n0xaaffffUse 0xffaaff/show 0xaaffffto get a list of msgs\n\""
        fi
        # manage won_matches.temp (match_winner; last)
        cat won_matches.temp | grep -v "$SINGLE_ID" > won_matches.temporary
        cat won_matches.temporary > won_matches.temp
        echo "$SINGLE_ID 0 still here" >> won_matches.temp # he renamed (99% means logged in and enered the grid) and write his id, 0 matches and status to won_matches.temp
    fi
fi

#for ip_list clearing its ip  when player left and as a resutl clearing the whole ip_list.txt at the end of game

### if player goes to spectator mode, his IP still in ip_list.txt so in result when he comes back from spec he dont get Welcome Message and rating position

##unsolved##
##no any events in ladderlog when server suddenly crashes so seems to be impossible for players to get statistic information on enter first time after crash, of course if they were on server right in the moment of server's crashing

if [ "${line:0:11}" == "PLAYER_LEFT" ]
 then
    SINGLE_ID=`echo "$line" | awk '{print $2}'`
    PLAYERS_IP_ON_LEFT=`echo $line | awk '{print $3}'`
    cat ip_list.txt | grep "$PLAYERS_IP_ON_LEFT" > /dev/null
    if [ $? -eq 0 ]
     then
        cat ip_list.txt | grep -v "$PLAYERS_IP_ON_LEFT" > ip_list.temp
        cat ip_list.temp > ip_list.txt
    fi
    #mangage won_matches.temp (match_winner; /last)
    WON=`cat won_matches.temp | grep "$SINGLE_ID" | cut -d' ' -f2` #how many matches he won
    cat won_matches.temp | grep -v "$SINGLE_ID" > won_matches.temporary
    cat won_matches.temporary > won_matches.temp
    echo "$SINGLE_ID $WON left" >> won_matches.temp

    #manage /bug section: removed number of messages player already sent
    cat bug.temp | grep "$SINGLE_ID" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
  	 cat bug.temp | grep -v "$SINGLE_ID" > bug.temp2
   	 cat bug.temp2 > bug.temp
    fi
fi

#anyway if some of players who was on server when it crashed is not shown right after, clear ip_list file their ips at the end of the first game
if [ "${line:0:8}" == "GAME_END" ]
 then
    NUM_PLAYERS="0" #game end, clean var with number of players online if someting happened and PLAYER_LEFT did not work properly, for multimode
    if [ -n ip_list.txt ] #if file is not empty
     then
        >ip_list.txt # recreate ip_list.txt
    fi
fi

#welcome message

if [ "${line:0:14}" == "PLAYER_ENTERED" ]
 then
    NUM_PLAYERS=`expr $NUM_PLAYERS + 1` #number of players online for multimode
    NAME=`echo "$line" | cut -d' ' -f4,5`
    echo "PLAYER_MESSAGE \"$NAME\" \"0xeac75d    Login to play\n0xaaffff    View all the available commands   0xffaaff/list\n0xffffff    First of 20 minutes or 45pts wins match\n\"" 
fi

#updating new won_matches.txt every round to keep /rank statistic up-to-date

if [ "${line:0:9}" == "NEW_ROUND" ]
 then
    cat ../../../../../../var/svr/ws/var/won_matches.txt | grep -v "@L_OP" | sed 's/*/_/g' > ./won_matches.txt
    cat ../../../../../../var/svr/ws/var/won_matches.txt | grep -v "@L_OP" | sed 's/-/_/g' > ./won_matches.txt
fi

#match winner

if [ "${line:0:12}" == "MATCH_WINNER" ]
 then
    cat ../../../../../../var/svr/ws/var/won_matches.txt | grep -v "@L_OP" | sed 's/*/_/g' > ./won_matches.txt
    cat ../../../../../../var/svr/ws/var/won_matches.txt | grep -v "@L_OP" | sed 's/-/_/g' > ./won_matches.txt
    echo "$line" | awk '{print $3}' > user_level.txt
    USER_LEVEL=`cat user_level.txt`
    USER_NICK=`cat $NAMEBASE | grep $USER_LEVEL | tail -1 | cut -d' ' -f2,3`
    POSI_SCORE=`cat -n $WAY | grep "$USER_LEVEL" | awk '{print $1 " " $2}'`
    SCORE_OF_FIRST=`head -1 $WAY | awk '{print $1}'`
    POSI=`echo $POSI_SCORE | awk '{print $1}'`
    SCORE=`echo $POSI_SCORE | awk '{print $2}'`
    GZ=`expr $SCORE + 1`
    PREVIOUS=`expr $POSI - 1`
    PREVIOUS_R=`cat -n $WAY | awk '{print $1 " " $2}' | grep "^$PREVIOUS" | awk '{print $2}'`
    LAST=`cat -n $WAY | tail -1 | awk '{print $1}'`
    LAST=`expr $LAST + 1`
    if [ "$POSI" = "1" ]
     then
        WON="and stayed on 0xff4e00top0xffed44!"
        
        ONE_INOUT=`head -2 $WAY | sed '1d'`
        ONE_INOUT_ID=`echo "$ONE_INOUT" | awk '{print $2}'`
        ONE_OUT=`grep "^$ONE_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        ONE_OUT_GZ=`echo "$ONE_INOUT" | awk '{print $1}'`
        
        SECOND_INOUT=`head -3 $WAY | sed '1,2d'`
        SECOND_INOUT_ID=`echo $SECOND_INOUT | awk '{print $2}'`
        SECOND_OUT=`grep "^$SECOND_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        SECOND_OUT_GZ=`echo "$SECOND_INOUT" | awk '{print $1}'`
        
        THIRD_INOUT=`head -4 $WAY | sed '1,3d'`
        THIRD_INOUT_ID=`echo $THIRD_INOUT | awk '{print $2}'`
        THIRD_OUT=`grep "^$THIRD_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        THIRD_OUT_GZ=`echo "$THIRD_INOUT" | awk '{print $1}'`
        
        FORTH_INOUT=`head -5 $WAY | sed '1,4d'`
        FORTH_INOUT_ID=`echo $FORTH_INOUT | awk '{print $2}'`
        FORTH_OUT=`grep "^$FORTH_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        FORTH_OUT_GZ=`echo "$FORTH_INOUT" | awk '{print $1}'`
        
	FIVE_INOUT=`head -6 $WAY | sed '1,5d'`
        FIVE_INOUT_ID=`echo $FIVE_INOUT | awk '{print $2}'`
        FIVE_OUT=`grep "^$FIVE_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        FIVE_OUT_GZ=`echo "$FIVE_INOUT" | awk '{print $1}'`
	
	SIX_INOUT=`head -7 $WAY | sed '1,6d'`
        SIX_INOUT_ID=`echo $SIX_INOUT | awk '{print $2}'`
        SIX_OUT=`grep "^$SIX_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        SIX_OUT_GZ=`echo "$SIX_INOUT" | awk '{print $1}'`
	
	SEVEN_INOUT=`head -8 $WAY | sed '1,7d'`
        SEVEN_INOUT_ID=`echo $SEVEN_INOUT | awk '{print $2}'`
        SEVEN_OUT=`grep "^$SEVEN_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        SEVEN_OUT_GZ=`echo "$SEVEN_INOUT" | awk '{print $1}'`
	
	EIGHT_INOUT=`head -9 $WAY | sed '1,8d'`
        EIGHT_INOUT_ID=`echo $EIGHT_INOUT | awk '{print $2}'`
        EIGHT_OUT=`grep "^$EIGHT_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        EIGHT_OUT_GZ=`echo "$EIGHT_INOUT" | awk '{print $1}'`
	
	NINE_INOUT=`head -10 $WAY | sed '1,9d'`
        NINE_INOUT_ID=`echo $NINE_INOUT | awk '{print $2}'`
        NINE_OUT=`grep "^$NINE_INOUT_ID" $NAMEBASE | awk '{print $2}'`
        NINE_OUT_GZ=`echo "$NINE_INOUT" | awk '{print $1}'`
	
	if [ "${GZ: -2}" != 11 ]
	 then
	    if [ "${GZ: -1}" == 1 ]
	     then
	         matches="match"
	    else
		 matches="matches"
	    fi
	else
	    matches="matches"
	fi
	
	TOP="\n0xffffffTOP 10:"
	SHOW_FIRST="0x00baff   $USER_NICK 0xffed44: 0xff4e00$GZ 0xffed44$matches"
	
	echo "CONSOLE_MESSAGE \n0xff4e00$USER_NICK 0xffed44has already won 0xff4e00$GZ 0xffed44$matches $WON\n$TOP\n$SHOW_FIRST"
	
	for i in ONE SECOND THIRD FORTH FIVE SIX SEVEN EIGHT NINE
	do
	    sleep 0.2
	    SHOW_NAME=`eval echo \\$$i\_OUT`
	    SHOW_SCORE=`eval echo \\$$i\_OUT_GZ`
	    if [ "${SHOW_SCORE: -2}" != 11 ]
	     then
	        if [ "${SHOW_SCORE: -1}" == 1 ]
	         then
	            matches="match"
		else
		    matches="matches"
		fi
	    else
		matches="matches"
	    fi
	    echo "CONSOLE_MESSAGE 0x00baff   $SHOW_NAME 0xffed44: 0xff4e00$SHOW_SCORE 0xffed44$matches"
	done
    elif [ "$PREVIOUS" = "1" -a "$GZ" -gt "$SCORE_OF_FIRST" ]
     then
        WON="and moved to 0xff4e00the first 0xffed44place!"
        ONE_INOUT=`head -2 $WAY | sed '2d'`
    	ONE_INOUT_ID=`echo "$ONE_INOUT" | awk '{print $2}'`
    	ONE_OUT=`grep "^$ONE_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	ONE_OUT_GZ=`echo "$ONE_INOUT" | awk '{print $1}'`
	
	SECOND_INOUT=`head -3 $WAY | sed '1,2d'`
	SECOND_INOUT_ID=`echo $SECOND_INOUT | awk '{print $2}'`
	SECOND_OUT=`grep "^$SECOND_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	SECOND_OUT_GZ=`echo "$SECOND_INOUT" | awk '{print $1}'`
	
	THIRD_INOUT=`head -4 $WAY | sed '1,3d'`
	THIRD_INOUT_ID=`echo $THIRD_INOUT | awk '{print $2}'`
	THIRD_OUT=`grep "^$THIRD_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	THIRD_OUT_GZ=`echo "$THIRD_INOUT" | awk '{print $1}'`
	
	FORTH_INOUT=`head -5 $WAY | sed '1,4d'`
	FORTH_INOUT_ID=`echo $FORTH_INOUT | awk '{print $2}'`
	FORTH_OUT=`grep "^$FORTH_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	FORTH_OUT_GZ=`echo "$FORTH_INOUT" | awk '{print $1}'`
	
	FIVE_INOUT=`head -6 $WAY | sed '1,5d'`
	FIVE_INOUT_ID=`echo $FIVE_INOUT | awk '{print $2}'`
	FIVE_OUT=`grep "^$FIVE_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	FIVE_OUT_GZ=`echo "$FIVE_INOUT" | awk '{print $1}'`
	
	SIX_INOUT=`head -7 $WAY | sed '1,6d'`
	SIX_INOUT_ID=`echo $SIX_INOUT | awk '{print $2}'`
	SIX_OUT=`grep "^$SIX_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	SIX_OUT_GZ=`echo "SIX_INOUT" | awk '{print $1}'`
	
	SEVEN_INOUT=`head -8 $WAY | sed '1,7d'`
	SEVEN_INOUT_ID=`echo $SEVEN_INOUT | awk '{print $2}'`
	SEVEN_OUT=`grep "^$SEVEN_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	SEVEN_OUT_GZ=`echo "SEVEN_INOUT" | awk '{print $1}'`
	
	EIGHT_INOUT=`head -9 $WAY | sed '1,8d'`
	EIGHT_INOUT_ID=`echo $EIGHT_INOUT | awk '{print $2}'`
	EIGHT_OUT=`grep "^$EIGHT_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	EIGHT_OUT_GZ=`echo "EIGHT_INOUT" | awk '{print $1}'`
	
	NINE_INOUT=`head -10 $WAY | sed '1,9d'`
	NINE_INOUT_ID=`echo $NINE_INOUT | awk '{print $2}'`
	NINE_OUT=`grep "^$NINE_INOUT_ID" $NAMEBASE | awk '{print $2}'`
	NINE_OUT_GZ=`echo "NINE_INOUT" | awk '{print $1}'`
	
	if [ "${GZ: -2}" != 11 ]
	 then
	    if [ "${GZ: -1}" == 1 ]
	     then
	         matches="match"
	    else
		 matches="matches"
	    fi
	else
	    matches="matches"
	fi
	
	TOP="\n0xffffffTOP 10:"
	SHOW_FIRST="0x00baff   $USER_NICK 0xffed44: 0xff4e00$GZ 0xffed44$matches"
	
	echo "CONSOLE_MESSAGE \n0xff4e00$USER_NICK 0xffed44has already won 0xff4e00$GZ 0xffed44$matches $WON\n$TOP\n$SHOW_FIRST"
	
	for i in ONE SECOND THIRD FORTH FIVE SIX SEVEN EIGHT NINE
	do
	    sleep 0.1
	    SHOW_NAME=`eval echo \\$$i\_OUT`
	    SHOW_SCORE=`eval echo \\$$i\_OUT_GZ`
	    if [ "${SHOW_SCORE: -2}" != 11 ]
	     then
	        if [ "${SHOW_SCORE: -1}" == 1 ]
	         then
	            matches="match"
		else
		    matches="matches"
		fi
	    else
		matches="matches"
	    fi
	    echo "CONSOLE_MESSAGE 0x00baff   $SHOW_NAME 0xffed44: 0xff4e00$SHOW_SCORE 0xffed44$matches"
	done
    elif [ $GZ -le $PREVIOUS_R ]
     then
        WON="and stayed at position 0xff4e00$POSI"
        if [ "${GZ: -2}" != 11 ]
         then
            if [ "${GZ: -1}" == 1 ]
             then
                matches="match"
    	    else
    	        matches="matches"
    	    fi
    	else
    	    matches="matches"
    	fi
        echo "CONSOLE_MESSAGE \n0xff4e00$USER_NICK 0xffed44has already won 0xff4e00$GZ 0xffed44$matches $WON\n"
    else
        if [ "${GZ: -2}" != 11 ]
    	 then
    	    if [ "${GZ: -1}" == 1 ]
    	     then
    	         matches="match"
    	    else
    		 matches="matches"
    	    fi
    	else
    	    matches="matches"
    	fi
        echo "CONSOLE_MESSAGE \n0xff4e00$USER_NICK 0xffed44has already won 0xff4e00$GZ 0xffed44$matches\n"
    fi

###work with  won_matches.temp for /last command
	WINNER_ID=`echo "$line" | awk '{print $3}'` # got player's ID who won match
        cat won_matches.temp | grep "$WINNER_ID" > /dev/null 2>&1
        if [ $? -eq 0 ]; then           #if player already exist in won_matches.temp do:
        	WHOLE_ROW=`cat won_matches.temp | grep "$WINNER_ID"` #found this player in won_matches.temp and his status and current score
                WON=`echo "$WHOLE_ROW" | cut -d' ' -f2` #how many matches this player won
                WON=`expr $WON + 1` #get increase number of his won matches per session to +1
                WHOLE_ROW=`echo "${WHOLE_ROW/#$PLAYER_WON_ID */$PLAYER_WON_ID $WON still here}"`
                cat won_matches.temp | grep -v "$PLAYER_WON_ID" > won_matches.temporary
                cat won_matches.temporary > won_matches.temp
                echo "$WHOLE_ROW" >> won_matches.temp
        else
                        WHOLE_ROW="0"
                        WHOLE_ROW=`echo "${WHOLE_ROW/#?/$PLAYER_WON_ID 1 still here}"`
                        echo "$WHOLE_ROW" >> won_matches.temp
        fi
fi

# custom commands in order: /rank, /rankme, /location

if [ "${line:0:15}" == "INVALID_COMMAND" ]
 then
    STAT_REQUEST=`echo $line | awk '{print $2 $6}'` # getting players' command
    STAT_ID=`echo $line | awk '{print $3}'` # getting his global id, and server name if player is not logged in
    USER_NICK=`cat $NAMEBASE | grep ^\$STAT_ID | awk '{print $2}' | tail -1` #in-game name
    CUSTOM_COMMAND=`echo $line | awk '{print $2}'` # command without parameters
    PARAM_CHECK=`echo "$line" | awk '{print $6}'`
    if [ "$PARAM_CHECK" != "" ]; then # now we check if command parameter is not empty. If it is empty we dont need to have $CUSTOM_PARAMETER
       WC_PARAMS=`echo $line | wc -w` #generate cut range step 1
       WC_PARAMS=`seq 6 $WC_PARAMS` #generate cut range step 2
       WC_PARAMS=`echo $WC_PARAMS | sed 's/ /,/g'` #generate cut range step 3
       CUSTOM_PARAMETER=`echo $line | cut -d' ' -f\`echo $WC_PARAMS\`` # command's parameter
    fi
    if [ "$STAT_REQUEST" == "/rank" ]
     then
        echo $STAT_ID | grep "@" > /dev/null
        if [ $? -eq 0 ]
         then
    	    K=1
    	    echo "PLAYER_MESSAGE \"$USER_NICK\" \"\n0x378098+--------------------------------------------------+\""
    	    sleep 0.05
    	    echo "PLAYER_MESSAGE \"$USER_NICK\" \"0x388098|0xffffff                      TOP 20                     0x378098 |\""
	    sleep 0.05
	    echo "PLAYER_MESSAGE \"$USER_NICK\" \"0x388098+------+-----------------------+-------+-----------+\""
	    while [ "$K" != "21" ]
	    do
		USER_WON=`cat -n $WAY | awk '{print $1 " : " $2}' | grep "^$K :" | awk -F' : ' '{print $2}'` #how many mantches K player won
		USER_NAME=`cat -n $WAY | awk '{print $1 " : " $3}' | grep "^$K :" | awk -F' : ' '{print $2}'` #his global id
		USER_NAME_NEW=`echo "$USER_NAME" | sed 's/*/./'`
		USER_NAME_SHOW=`cat $NAMEBASE | grep "$USER_NAME_NEW" | awk '{print $2}' | tail -1` #his current name
		POS=`cat -n $WAY | grep "$USER_NAME_NEW" | awk '{print $1}'` #his position
		POS=`echo "${POS}      "`
		USER_NAME_SHOW=`echo "${USER_NAME_SHOW}                         "`
		if [ "${USER_WON: -2}" != 11 ]
	         then
	    	    if [ "${USER_WON: -1}" == 1 ]
	             then
	        	matches="match             "
	    	    else
	    		matches="matches           "
		    fi
		else
		    matches="matches               "
		fi
		USER_WON=`echo "${USER_WON}           "`
		if [ "$USER_NAME" == "$STAT_ID" ]
		 then
		    sleep 0.05
		    echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff|  0xff4e00${POS:0:3} 0xffffff| 0x00ff00  ${USER_NAME_SHOW:0:19} 0xffffff|  0xff4e00${USER_WON:0:4} 0xffffff|  0xffed44${matches:0:8} 0xffffff|\""
		    sleep 0.05
		    echo "PLAYER_MESSAGE \"$USER_NICK\" \"+------+-----------------------+-------+-----------+\""
		else
		    sleep 0.05
		    echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff|  0xff4e00${POS:0:3} 0xffffff| 0x00baff  ${USER_NAME_SHOW:0:19} 0xffffff|  0xff4e00${USER_WON:0:4} 0xffffff|  0xffed44${matches:0:8} 0xffffff|\""
		    sleep 0.05
		    echo "PLAYER_MESSAGE \"$USER_NICK\" \"+------+-----------------------+-------+-----------+\""
		fi
		if [ "$K" != "21" ]
	         then
	    	    K=`expr $K + 1`
		fi
	    done
	    echo ""
	    echo "PLAYER_MESSAGE \"$USER_NICK\" \"----------------------------------------------------\""
	else
	    echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
    elif [ "$STAT_REQUEST" == "/rankme" ] # show statistic only for single player
     then
        echo "$STAT_ID" | grep "@" > /dev/null
        if [ $? -eq 0 ]
         then
		cat $WAY | grep $STAT_ID > /dev/null
		if [ $? -eq 0 ]
		 then
         		USER_WON=`cat $WAY | grep $STAT_ID | awk '{print $1}'` #how many mantches player won 
			POS=`cat -n $WAY | grep $STAT_ID | awk '{print $1}'` #his position
         		if [ "${USER_WON: -2}" != 11 ]
                 	 then
                    		if [ "${USER_WON: -1}" == 1 ]
                     		 then
                        		matches="match"
                    		else
                        	matches="matches"
                    		fi
                	else
                    		matches="matches"
                	fi

			echo "PLAYER_MESSAGE \"$USER_NICK\" \"\""
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0x00ff00   $USER_NICK\""
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff      position: 0xff4e00$POS\n0xff4e00      $USER_WON 0xffed44$matches won\n\""
		else
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffff You don't have any statistic yet\""
		fi
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
     elif [ "$STAT_REQUEST" == "/location" ] #request without parameter, show usage
     then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "PLAYER_MESSAGE \"$USER_NICK\" \"\n0xaaffffGetting approximate players's location\n0xffffff usage: 0xffaaff/location <pattern>\n0xaaffff where <pattern> is a part of player's ingame name or his GLOBAL_ID.\n\""
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
     elif [ "$STAT_REQUEST" == "/bug" ] #request without parameter, show usage
      then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffffSending bug report to admin...\n0xaaffff   usage: 0xffaaff/bug <message>\""
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
     elif [ "$STAT_REQUEST" == "/later" ]; then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffaaMessage Box\n0xaaffffLeaving a private message for player for future read. Only if player is not on server at that moment and you know his/her GLOBAL_ID.\n0xffffaausage: 0xffaaff /later <GLOBAL_ID> <SUBJECT> <MESSAGE>\""
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
     elif [ "$STAT_REQUEST" == "/show" ]; then
	STAT_FILE=`echo "$STAT_ID" | sed -e 's/\//_/g' -e 's/@/_/g'` # global_id as file name without / and @
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1 
	if [ $? -eq 0 ]; then
		echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffaaMESSAGE BOX\n0xaaffffLast messages on top. To check message type 0xffaaff/show <NUMBER>\n0xaaffffAfter checking, message will be removed.\n\""
		cat later.txt | grep "^.*[[:space:]]$STAT_ID" > later/$STAT_FILE
		WC_MSG_ROWS=`cat later/$STAT_FILE | wc -l`
		echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff+--+------------+------+-------------------------+\n|N |  Subject   |      | Mailer                  |\n+--+------------+------+-------------------------+\""
		if [ "$WC_MSG_ROWS" -eq 0 ]; then
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffaaYou don't have any new private messages.\n\""
		elif [ "$WC_MSG_ROWS" -gt 20 ]; then
                        tail -20 later/$STAT_FILE >  later/${STAT_FILE}_temp
                        cat later/${STAT_FILE}_temp > later/$STAT_FILE
                        rm later/${STAT_FILE}_temp
			K="20"
                        for i in `seq 1 20`
                        do
                                FROM=`cat -n later/$STAT_FILE | sed 's/^[[:space:]]\{1,\}//g'| grep "^$K" | awk '{print $2 "                 "}'`
                                SUBJECT=`cat -n later/$STAT_FILE | sed 's/^[[:space:]]\{1,\}//g' | grep "^$K" | awk '{print $4 "             "}'`
				i=`echo "${i}   "`
				sleep 0.02
                                echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff|0xaaffff${i:0:2}0xffffff| 0xffaaff${SUBJECT:0:10} 0xffffff| from | 0xffaaff${FROM:0:23} 0xffffff|\""
                                K=`expr $K - 1`
                        done
                        echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff+--+------------+------+-------------------------+\""
		else
			K=`echo $WC_MSG_ROWS`
			for i in `seq 1 $WC_MSG_ROWS`
			do
				FROM=`cat -n later/$STAT_FILE | sed 's/^[[:space:]]\{1,\}//g'| grep "^$K" | awk '{print $2 "                 "}'`
				SUBJECT=`cat -n later/$STAT_FILE | sed 's/^[[:space:]]\{1,\}//g' | grep "^$K" | awk '{print $4 "             "}'`
				i=`echo "${i}   "`
				sleep 0.02
				echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff|0xaaffff${i:0:2}0xffffff| 0xffaaff${SUBJECT:0:10} 0xffffff| from | 0xffaaff${FROM:0:23} 0xffffff|\""
				K=`expr $K - 1`
			done
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff+--+------------+------+-------------------------+\""
		fi
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
     elif [ "$CUSTOM_COMMAND" == "/show" ]; then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		STAT_FILE=`echo "$STAT_ID" | sed -e 's/\//_/g' -e 's/@/_/g'`
		case "$CUSTOM_PARAMETER" in
			[0-9][0-9]|[0-9])
					WC_MESSAGES=`tail -20 later/$STAT_FILE | wc -l`
					if [ "$CUSTOM_PARAMETER" -gt 20 ]; then
						echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffffError. <number> must be in range 1..20\""
					elif [ "$CUSTOM_PARAMETER" -eq 0 ]; then
						echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffffError. <number> must be in range 1..20\""
					elif [ "$CUSTOM_PARAMETER" -gt "$WC_MESSAGES" ]; then
						echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffffError. Message with number $CUSTOM_PARAMETER does not exist.\""
					else
						RESULT=$(($WC_MESSAGES+1))
						RESULT=$(($RESULT-$CUSTOM_PARAMETER))
						FULL_MSG=`tail -20 later/$STAT_FILE | cat -n | sed 's/^[[:space:]]\{1,\}//g' | grep "^$RESULT" | sed 's/^.\{1,2\}[[:space:]]\{1,\}//g'`
						FROM_WHOM=`echo "$FULL_MSG" | awk '{print $2}'`
						TOPIC=`echo "$FULL_MSG" | awk '{print $3}'` # magic
						MESSAGE=`echo "$FULL_MSG" | awk '{for(k=4; k<=NF; k++) printf $k " " }'`
						echo "PLAYER_MESSAGE \"$USER_NICK\" \"\n0xaaffffMessage from 0xffaaff$FROM_WHOM 0xaaffffwith topic 0xffaaff${TOPIC} \n0xff0000>> 0xffffaa$MESSAGE \n\""
						cat later.txt | grep -v "$FULL_MSG" > later.temp # if player spams with same message: /show <number of message>; /show; now you get all same messages removed. ATM spam with same message should be prevented ty /later
						cat later.temp > later.txt
					fi
					;;
			*) echo "PLAYER_MESSAGE \"$USER_NICK\" \"\n0xaaffffWrong subject number\n0xffffaausage: 0xffaaff/show <number>\"";;
		esac
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
elif [ "$STAT_REQUEST" == "/last" ]; then
        echo "$STAT_ID" | grep "@" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffaaff************************************************\n0xffaaff*0x00baff          Last 15 players played here         0xffaaff*\n0xffaaff************************************************\""
                for i in `seq 1 15`
                do
                        LAST10=`tail -15 "$NAMEBASE" | cat -n | sed 's/^[[:space:]]\{1,\}//g' | grep "^$i[[:space:]]" | awk '{print $3}'`   #reminder: names base does not contain gaps in real names
                        LAST_ID=`tail -15 "$NAMEBASE" | cat -n | sed 's/^[[:space:]]\{1,\}//g' | grep "^$i[[:space:]]" | awk '{print $2}'`   # global ID of player in current iteration
                        LAST10=`echo "${LAST10}                                             "`
                        WHOLE_ROW=`cat won_matches.temp | grep "$LAST_ID"`
                        WON=`echo "$WHOLE_ROW" | cut -d' ' -f2` #score
                        WON=`echo "${WON}   "`
                        STATUS=`echo "$WHOLE_ROW" | cut -d' ' -f3,4` #status
                        STATUS=`echo "${STATUS}          "`
                        echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffaaff*0x3bffa5 ${LAST10:0:14} 0xeac75dwon 0xff4e00${WON:0:2} 0xeac65dmatches and 0xff4e00${STATUS:0:10} 0xffaaff*\"
"
                done
                echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffaaff************************************************\""
        else
                echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
        fi
     elif [ "$STAT_REQUEST" == "/list" ]; then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "PLAYER_MESSAGE \"$USER_NICK\" \"<-------------------->\n<-0x7ce757Available commands0xffffff->\n<-------------------->\n\n0xff4e00/translate0xffffaa     Translate a message and post in publi\n0xff4e00/translate_me0xffffaa  Translate a message for private read\n0xff4e00/rank0xffffaa          Shows Top 20 won matches rating list\n0xff4e00/rankme0xffffaa        Shows your own statistic\n0xff4e00/rankof0xffffaa        Shows statistic of another player\n0xff4e00/location0xffffaa      Shows approximate players's location\n0xff4e00/langs0xffffaa         Language shortcuts for /translate\n0xff4e00/last0xffffaa          Shows last 15 players played on this server\n0xff4e00/bug0xffffaa           File a bug\n0xff4e00/later0xffffaa         Send a PM\n0xff4e00/show0xffffaa          Check new PM\n0xff4e00/outbox0xffffaa        Shows unread messages you sent over /later\n0xff4e00/list0xffffaa          All available commands\n\""
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
     elif [ "$STAT_REQUEST" == "/rankof" ]; then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffffChecking statistic of another player.\n0xffffaausage: 0xffaaff/rankof <Player's GLOBAL_ID>\n\""
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
     elif [ "$CUSTOM_COMMAND" == "/rankof" ]; then
        echo "$STAT_ID" | grep "@" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "$CUSTOM_PARAMETER" | grep "^.*@..*$" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                        REQUESTED_ID=`cat $NAMEBASE | grep "$CUSTOM_PARAMETER" | awk '{print $1}' | tail -1`
                        if [ "$REQUESTED_ID" = "" ]; then
				echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000Not found.\""
			else
				cat $WAY | grep "$REQUESTED_ID" > /dev/null 2>&1
                        	if [ $? -eq 0 ]; then
                                	USER_WON=`cat $WAY | grep "$REQUESTED_ID" | awk '{print $1}'` #how many matches player won
                                	POS=`cat -n $WAY | grep "$REQUESTED_ID" | awk '{print $1}'` #his position
                                	if [ "${USER_WON: -2}" != 11 ]; then
                                        	if [ "${USER_WON: -1}" == 1 ]; then
                                                	matches="match"
                                        	else
                                                	matches="matches"
                                        	fi
                                	else
                                        	matches="matches"
                                	fi
                                	echo "PLAYER_MESSAGE \"$USER_NICK\" \"\n0x00ff00   ${REQUESTED_ID}\""
                                	echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffffff      position: 0xff4e00$POS\n0xff4e00      $USER_WON 0xffed44$matches won\n\""
			    	else
                                	echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffaaff$REQUESTED_ID 0xaaffffdoes not have any statistic yet\""
                        	fi
			fi
                else
                        echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000Wrong GLOBAL_ID.\""
                fi
        else
                echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
        fi
     elif [ "$CUSTOM_COMMAND" == "/location" ]
     then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1 #check if player is logged in
	if [ $? -eq 0 ]; then
		WC=`cat ip_list.txt | grep -i "$CUSTOM_PARAMETER" | wc -l`
		if [ $WC -gt 1 ]
	 	 then
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000Be more specific.\""
		elif [ "$WC" -eq 0 ]
	 	 then
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000No matches.\""
		else
			WCN=`cat ip_list.txt | grep -i "$CUSTOM_PARAMETER" | wc -w` # count words to get player name without ID and IP (step 1 for generate cut range)
			WCN=`seq 3 $WCN` # generate cut range step 2
			WCN=`echo $WCN | sed 's/ /,/g'` #generate cut range step 3
			cat ip_list.txt | grep -i "$CUSTOM_PARAMETER" | cut -d' ' -f`echo $WCN` > whois_name # file contains just a name
			NAME=`cat whois_name`
			PLAYER_IP=`cat ip_list.txt | grep -i "$CUSTOM_PARAMETER" | awk '{print $1}'` # getting IP of found player
			whois "$PLAYER_IP" | grep "^country" > /dev/null #if whois output contains country row, we have country code
			if [ $? -eq 0 ]; then
				COUNTRY=`whois "$PLAYER_IP" | grep "^country" | tail -1 | sed 's/:/ /' | awk '{print $2}'` # country code
				WCNT=`cat country_codes.txt | grep -i ^$COUNTRY | wc -w` #generate cut range step 1
				WCNT=`seq 2 $WCNT` #generate cut range step 2
				WCNT=`echo $WCNT | sed 's/ /,/g'`
				cat country_codes.txt | grep -i ^$COUNTRY | cut -d' ' -f`echo $WCNT` > country_name
				COUNTRY_NAME=`cat country_name`
				echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff4e00$NAME 0xaaffffseems to be in 0xff4e00$COUNTRY_NAME 0xaaffffright now. If you are sure it is wrong information, please make a note for an admin using 0xffaaff/bug <message>\""
			else
				echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffffPlayer's location is not found...\""
			fi
    		fi
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
    elif [ "$CUSTOM_COMMAND" == "/later" ]; then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		MESSAGE_FOR_ID=`echo "$CUSTOM_PARAMETER" | awk '{print $1}'`
		ANTISPAM_WC_MSG=`grep "^$STAT_ID $MESSAGE_FOR_ID" later.txt | wc -l`
		if [ "$ANTISPAM_WC_MSG" -gt 6 ]; then
			echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000SPAM PROTECTION: 0xffffffYou have already sent too many messages to 0xffffaa$MESSAGE_FOR_ID\""
		else
			cat later.txt | grep "$CUSTOM_PARAMETER" > /dev/null 2>&1 # check if he has already sent this message (small spam prevent for similar messages)
			if [ $? -eq 0 ]; then
				echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000You have already sent this message to 0xffffaa$MESSAGE_FOR_ID\""
			else
				grep "$MESSAGE_FOR_ID" namebase.txt > /dev/null 2>&1
				if [ $? -eq 0 ]; then
					if [ "$MESSAGE_FOR_ID" = "$STAT_ID" ]; then
						echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000You can not send a message to yourself.\""
					else
						ARGUMENTS=`echo "$CUSTOM_PARAMETER" | awk '{print $3}'`
						if [ "$ARGUMENTS" = "" ]; then
							echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000Too few arguments.\""
						else
							echo "$STAT_ID $CUSTOM_PARAMETER" >> later.txt
							echo "PLAYER_MESSAGE \"$USER_NICK\" \"\n0xaaffffPlayer 0xffaaff$MESSAGE_FOR_ID 0xaaffffwas found. Your private message 0x00ff00has been sent.\n0xaaffffS/he will get it as soon as s/he returns to the server again.\n\""
						fi
					fi
				else
					echo "PLAYER_MESSAGE \"$USER_NICK\" \"\n0xff2222Player does not exist in db or you made a mistake in player's GLOBAL_ID\n\""
				fi
			fi
		fi
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
    elif [ "$STAT_REQUEST" == "/outbox" ]; then
	echo "$STAT_ID" | grep "@" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"\n0xaaffffOutbox shows unread messages which you sent using 0xffaaff/later 0xaaffffcommand\n\""
		cat later.txt | cut -d' ' -f1 | grep "$STAT_ID" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			NUMBER_OF_MESSAGES=`cat later.txt | cut -d' ' -f1 | grep "$STAT_ID" | wc -l`
			NUMBER="1"
			for i in `seq 1 $NUMBER_OF_MESSAGES`
			do
				cat later.txt | grep "^$STAT_ID" | cat -n | sed 's/^[[:space:]]\{,6\}//g' | grep "^$NUMBER" > outbox.temp
				read JUNK1 JUNK2 WHOM SUBJECT MESSAGE < outbox.temp
				NUMBER=`expr $NUMBER + 1`
				echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xff0000To 0xaaffff${WHOM}0xff0000 with subject 0xaaffff$SUBJECT\n0xff0000>> 0xffffaa$MESSAGE\n\""
			done
		else
			echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xff0000There are no any unread messages\""
		fi
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
    elif [ "$CUSTOM_COMMAND" == "/bug" ]; then
	echo "$STAT_ID" | grep "@" > /dev/null
	if [ $? -eq 0 ]; then
		bug() {
                NUMBER_OF_CHARS=`echo "$CUSTOM_PARAMETER" | wc -m`
                if [ "$NUMBER_OF_CHARS" -ge 16 ]; then
                        PLAYER_IP=`cat ip_list.txt | grep "$STAT_ID" | cut -d' ' -f1`
                        echo -e "`date`\nIP: ${PLAYER_IP}\nGLOBAL_ID: $STAT_ID\nName: $USER_NICK\nmessage:\n$CUSTOM_PARAMETER" > mail.txt
                        ./mailer.sh | sendmail -vt > /dev/null 2>&1
                        echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xaaffff   Sending message...\""

                        cat bug.temp | grep "$STAT_ID" > /dev/null 2>&1
                        if [ $? -eq 0 ]; then
                                BUG_LINE=`cat bug.temp | grep "$STAT_ID"` #got line from bug.temp
                                NMSGS=`echo "$BUG_LINE" | cut -d' ' -f2` #how many messages are already sent by player
                                NMSGS=`expr $NMSGS + 1` # +1 number of messages
                                cat bug.temp | grep -v "$STAT_ID" > bug.temp2
                                cat bug.temp2 > bug.temp
                                echo "$STAT_ID $NMSGS" >> bug.temp
                        else
                        echo "$STAT_ID 1" >> bug.temp
                        fi

                        sleep 1
                        echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xffaaff   Sent. 0xffaaffThanks for your report.\""
                else
                        echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000Too short message! Try again.\""
                fi
                }
                cat bug.temp | grep "$STAT_ID" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                        BUGS=`cat bug.temp | grep "$STAT_ID" | cut -d' ' -f2` #count number of sent messages per session
                        if [ "$BUGS" -ge 3 ]; then
                                echo "PLAYER_MESSAGE \"$USER_NICK\" \"0xff0000SPAM PROTECTION: 0xffffffYou have already sent too many bug messages\""
                        else
                                bug  #function
                        fi
                else
                        bug #funcion
                fi
	else
		echo "PLAYER_MESSAGE \"$STAT_ID\" \"0xaaffffYou're not allowed to perform this command. Please login!\""
	fi
    fi
fi

done
