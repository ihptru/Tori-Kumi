#!/usr/bin/python
# -*- coding: utf-8 -*-

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

import sys
import time
from translate import Translator

translate = Translator().translate

languages=['af','sq','ar','be','bg','ca','zh-CN','hr','cs','da','nl','en','et','tl','fi','fr','gl','de','el','iw','hi','hu','is','id','ga','it','ja','ko','lv','lt','mk','ml','mt','no','fa','pl','ro','ru','sr','sk','sl','es','sw','sv','th','tr','uk','vi','cy','yi']

langs=['Afrikaans','Albanian','Arabic','Belarusian','Bulgarian','Catalan','Chinese_Simplified','Croatian','Czech','Danish','Dutch','English','Estonian','Filipino','Finnish','French','Galician','German','Greek','Hebrew','Hindi','Hungarian','Icelandic','Indonesian','Irish','Italian','Japanese','Korean','Latvian','Lithuanian','Macedonian','Malay','Maltese','Norwegian','Persian','Polish','Romanian','Russian','Serbian','Slovak','Slovenian','Spanish','Swahili','Swedish','Thai','Turkish','Ukrainian','Vietnamese','Welsh','Yiddish']

while True:
	line=sys.stdin.readline()
	line=line.rstrip()	#remove \n and space from right side
	lst=line.split(' ')	#got list of args
	if lst[0] == 'INVALID_COMMAND':
		who=lst[2]
		if lst[1] == '/translate':
	                elements=len(lst)       #number of args
                        if elements == 5:       #print usage then
                                to_file='PLAYER_MESSAGE "'+who+'" "0xc6ff00Translate a message and post it in public\\n0xff3c00Usage: 0x0078ff/translate <from> <to> <text>\\n0xff3c00In 0x0078ff<from> 0xff3c00and 0x0078ff<to> 0xff3c00sections you have to use shortnames of languages\\n0xff3c00To get a list of shortnames use: 0x0078ff/langs"\n'   
                                filename = "/var/svr/ws/cmds.txt"
                                file = open(filename, 'a')
                                file.write(to_file)
                                file.close()
                        else:   
                                t_from=lst[5]
                                if elements == 6:
                                        if t_from in languages:
                                                to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Error: missing arguments"\n'
                                                filename = "/var/svr/ws/cmds.txt"
                                                file = open(filename, 'a')
                                                file.write(to_file)
                                                file.close()
                                        else:   
                                                to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Language in 0x0078ff<from> 0xff3c00section is incorrect"\n'
                                                filename = "/var/svr/ws/cmds.txt"
                                                file = open(filename, 'a')
                                                file.write(to_file)
                                                file.close()
                                elif elements == 7:
                                        t_to=lst[6]
                                        if t_to in languages:
                                                to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Error: missing arguments"\n'
                                                filename = "/var/svr/ws/cmds.txt"
                                                file = open(filename, 'a')
                                                file.write(to_file)
                                                file.close()
                                        else:
                                                to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Language in 0x0078ff<to> 0xff3c00section is incorrect"\n'
                                                filename = "/var/svr/ws/cmds.txt"
                                                file = open(filename, 'a')
                                                file.write(to_file)
                                                file.close()
                                else:
                                        t_to=lst[6]
                                        if t_from in languages:
                                                if t_to in languages:
							out_from=languages.index(t_from)	#position of element
							lang_from=langs[out_from]
						
							out_to=languages.index(t_to)
							lang_to=langs[out_to]

                                                        length_lst=len(lst)     #got position of the last word
                                                        text=lst[7:length_lst]  #got the whole message as list
                                                        b=''
                                                        for a in text:
                                                                b=b+' '+a
                                                        text=b.lstrip()         #got the whole message :)
                                                        output=translate(text, lang_to=t_to, lang_from=t_from).encode('utf-8')
                                                        to_file='CONSOLE_MESSAGE 0xff3c00Translated from 0x0078ff'+lang_from+' 0xff3c00to 0x0078ff'+lang_to+'0xff3c00:\\n0x0078ff'+who+'0xff3c00: 0xc6ff00'+output+'\n'
                                                        filename = "/var/svr/ws/cmds.txt"
                                                        file = open(filename, 'a')
                                                        file.write(to_file)
                                                        file.close()
                                                else:
                                                        to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Language in 0x0078ff<to> 0xff3c00section is incorrect"\n'
                                                        filename = "/var/svr/ws/cmds.txt"
                                                        file = open(filename, 'a')
                                                        file.write(to_file)
					else:
                                                to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Language in 0x0078ff<from> 0xff3c00section is incorrect"\n'
                                                filename = "/var/svr/ws/cmds.txt"
                                                file = open(filename, 'a')
                                                file.write(to_file)
                                                file.close()
		if lst[1] == '/translate_me':
                        elements=len(lst)       #number of args
		        if elements == 5:       #print usage then
				to_file='PLAYER_MESSAGE "'+who+'" "0xc6ff00Translate a message for yourself (nobody will read it)\\n0xff3c00Usage: 0x0078ff/translate_me <from> <to> <text>\\n0xff3c00In 0x0078ff<from> 0xff3c00and 0x0078ff<to> 0xff3c00sections you have to use shortnames of languages\\n0xff3c00To get a list of shortnames use: 0x0078ff/langs"\n'
                                filename = "/var/svr/ws/cmds.txt"
                                file = open(filename, 'a')
                                file.write(to_file)
                                file.close()
			else:
				t_from=lst[5]
				if elements == 6:
					if t_from in languages:
                                      		to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Error: missing arguments"\n'
                                      		filename = "/var/svr/ws/cmds.txt"
                                       		file = open(filename, 'a')
                                       		file.write(to_file)
                                       		file.close()
					else:
						to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Language in 0x0078ff<from> 0xff3c00section is incorrect"\n'
                                        	filename = "/var/svr/ws/cmds.txt"
                                        	file = open(filename, 'a')
                                        	file.write(to_file)
                                        	file.close()
                               	elif elements == 7:
					t_to=lst[6]
					if t_to in languages:
                                       		to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Error: missing arguments"\n'
                                       		filename = "/var/svr/ws/cmds.txt"
                                      		file = open(filename, 'a')
                                      		file.write(to_file)
                                       		file.close()
					else:
						to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Language in 0x0078ff<to> 0xff3c00section is incorrect"\n'
                                                filename = "/var/svr/ws/cmds.txt"
                                                file = open(filename, 'a')
                                                file.write(to_file)
                                                file.close()
                        	else:
					t_to=lst[6]
					if t_from in languages:
						if t_to in languages:
							out_from=languages.index(t_from)	#position of element
							lang_from=langs[out_from]
							
							out_to=languages.index(t_to)	#position of element
							lang_to=langs[out_to]

							length_lst=len(lst)     #got position of the last word
                                        		text=lst[7:length_lst]  #got the whole message as list
                                        		b=''
                                        		for a in text:
                                  				b=b+' '+a
                                       			text=b.lstrip()         #got the whole message :)
                                       			output=translate(text, lang_to=t_to, lang_from=t_from).encode('utf-8')
	                                		to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Translated for you from 0x0078ff'+lang_from+' 0xff3c00to 0x0078ff'+lang_to+'0xff3c00:\\n0xc6ff00'+output+'"\n'
         	                        		filename = "/var/svr/ws/cmds.txt"
                                        		file = open(filename, 'a')
                                        		file.write(to_file)
                                        		file.close()
						else:
							to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00Language in 0x0078ff<to> 0xff3c00section is incorrect"\n'
                                                	filename = "/var/svr/ws/cmds.txt"
                                                	file = open(filename, 'a')
                                                	file.write(to_file)
                                                	file.close()
					else:
						to_file='PLAYER_MESSAGE "'+who+'" "0xff3c00fLanguage in 0x0078ff<from> 0xff3c00section is incorrect"\n'
                                        	filename = "/var/svr/ws/cmds.txt"
                                        	file = open(filename, 'a')
                                        	file.write(to_file)
                                        	file.close()
		if lst[1] == '/langs':
			elements=len(lst)
			if elements == 5:
				b=0
				output1=''
				for i in languages:
					a1_short=languages[b]
					a1_index=languages.index(a1_short)	#index to get full languages name
					a1_name=langs[a1_index]	#got name
					a1_short=a1_short.ljust(8)
					a1_name=a1_name.ljust(20)
					b=b+1
					a2_short=languages[b]
					a2_index=languages.index(a2_short)	#index to get full languages name
					a2_name=langs[a2_index]	#got name
					a2_short=a2_short.ljust(8)
					a2_name=a2_name.ljust(20)
					b=b+1	
					output1=output1+'0xffffff|  0xff3c00'+a1_short+'0xc6ff00'+a1_name+'0xffffff|  0xff3c00'+a2_short+'0xc6ff00'+a2_name+'    0xffffff|\\n'
					#b=b+1
					if b == 10:
						break
				b=10
                                output2=''
                                for i in languages:
                                        a1_short=languages[b]
                                        a1_index=languages.index(a1_short)      #index to get full languages name
                                        a1_name=langs[a1_index] #got name
                                        a1_short=a1_short.ljust(8)
                                        a1_name=a1_name.ljust(20)
                                        b=b+1
                                        a2_short=languages[b]
                                        a2_index=languages.index(a2_short)      #index to get full languages name
                                        a2_name=langs[a2_index] #got name
                                        a2_short=a2_short.ljust(8)
                                        a2_name=a2_name.ljust(20)
                                        b=b+1
                                        output2=output2+'0xffffff|  0xff3c00'+a1_short+'0xc6ff00'+a1_name+'0xffffff|  0xff3c00'+a2_short+'0xc6ff00'+a2_name+'    0xffffff|\\n'
                                        #b=b+1
                                        if b == 20:
                                                break
				b=20
                                output3=''
                                for i in languages:
                                        a1_short=languages[b]
                                        a1_index=languages.index(a1_short)      #index to get full languages name
                                        a1_name=langs[a1_index] #got name
                                        a1_short=a1_short.ljust(8)
                                        a1_name=a1_name.ljust(20)
                                        b=b+1
                                        a2_short=languages[b]
                                        a2_index=languages.index(a2_short)      #index to get full languages name
                                        a2_name=langs[a2_index] #got name
                                        a2_short=a2_short.ljust(8)
                                        a2_name=a2_name.ljust(20)
                                        b=b+1
                                        output3=output3+'0xffffff|  0xff3c00'+a1_short+'0xc6ff00'+a1_name+'0xffffff|  0xff3c00'+a2_short+'0xc6ff00'+a2_name+'    0xffffff|\\n'
                                        #b=b+1
                                        if b == 30:
                                                break
				b=30
                                output4=''
                                for i in languages:
                                        a1_short=languages[b]
                                        a1_index=languages.index(a1_short)      #index to get full languages name
                                        a1_name=langs[a1_index] #got name
                                        a1_short=a1_short.ljust(8)
                                        a1_name=a1_name.ljust(20)
                                        b=b+1
                                        a2_short=languages[b]
                                        a2_index=languages.index(a2_short)      #index to get full languages name
                                        a2_name=langs[a2_index] #got name
                                        a2_short=a2_short.ljust(8)
                                        a2_name=a2_name.ljust(20)
                                        b=b+1
                                        output4=output4+'0xffffff|  0xff3c00'+a1_short+'0xc6ff00'+a1_name+'0xffffff|  0xff3c00'+a2_short+'0xc6ff00'+a2_name+'    0xffffff|\\n'
                                        #b=b+1
                                        if b == 40:
                                                break
				b=40
                                output5=''
                                for i in languages:
                                        a1_short=languages[b]
                                        a1_index=languages.index(a1_short)      #index to get full languages name
                                        a1_name=langs[a1_index] #got name
                                        a1_short=a1_short.ljust(8)
                                        a1_name=a1_name.ljust(20)
                                        b=b+1
                                        a2_short=languages[b]
                                        a2_index=languages.index(a2_short)      #index to get full languages name
                                        a2_name=langs[a2_index] #got name
                                        a2_short=a2_short.ljust(8)
                                        a2_name=a2_name.ljust(20)
                                        b=b+1
                                        output5=output5+'0xffffff|  0xff3c00'+a1_short+'0xc6ff00'+a1_name+'0xffffff|  0xff3c00'+a2_short+'0xc6ff00'+a2_name+'    0xffffff|\\n'
                                        #b=b+1
                                        if b == 50:
                                                break
				filename = "/var/svr/ws/cmds.txt"
				file = open(filename, 'a')
				to_file1='PLAYER_MESSAGE "'+who+'" "+------------------------------+----------------------------------+\\n'+output1+'"\n'
				file.write(to_file1)
				to_file2='PLAYER_MESSAGE "'+who+'" "'+output2+'"\n'
				file.write(to_file2)
				to_file3='PLAYER_MESSAGE "'+who+'" "'+output3+'"\n'
				file.write(to_file3)
				to_file4='PLAYER_MESSAGE "'+who+'" "'+output4+'"\n'
				file.write(to_file4)
				to_file5='PLAYER_MESSAGE "'+who+'" "'+output5+'"\n'
				file.write(to_file5)
				file.close()
				time.sleep(1)
				file = open(filename, 'a')
				to_file6='PLAYER_MESSAGE "'+who+'" "\\n0x0078ffLanguages with poor support or without support at all: 0xff3c00sq ar be bg ca zh-CN hr cs el iw hi hu is ga ja ko lt mk mt fa pl ro ru sr sk es sv th uk vi yi"\n'
				file.write(to_file6)
				file.close()
