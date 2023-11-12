#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮
# │ R ││ A ││ D ││ I ││ O ││ N │
# ╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯
#A python script written by Christos Angelopoulos, November 2023, under GPL v2
import termios, sys , tty
import mpv
import time
import random

def _getch():
 #as found in https://stackoverflow.com/questions/27750536/python-input-single-character-without-enter
   fd = sys.stdin.fileno()
   old_settings = termios.tcgetattr(fd)
   try:
      tty.setraw(fd)
      ch = sys.stdin.read(1)     #This number represents the length
   finally:
      termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
   return ch

def select_station(TAG_SELECTED, stations_lines):
 tag_selected_name=[]
 tag_selected_url=[]
 tag_selected_len = 0
 x=0
 while x < len(stations_lines):
  line_list = stations_lines[x].split(' ')
  if TAG_SELECTED in stations_lines[x]:
   tag_selected_url.append(line_list[0])
   tag_selected_name.append(line_list[1])
   tag_selected_len += 1
  x += 1
  ########
 LOOP2=0
 while LOOP2 == 0:
  print_menu_2(tag_selected_name,tag_selected_url,tag_selected_len)
  STATION_INDEX = input()
  station_index_check_num = STATION_INDEX.isnumeric()
  station_index_check_alpha = STATION_INDEX.isalpha()
  if station_index_check_alpha == True:
   if STATION_INDEX == "Q" or STATION_INDEX == "q":
    quit()
   elif STATION_INDEX == "X" or STATION_INDEX == "x":
    LOOP2 = 1
  if station_index_check_num == True:
   if int(STATION_INDEX) == 0:
    ran = (random.randrange(0,tag_selected_len-1))
    STATION = tag_selected_name[ran].strip('~')
    STATION = STATION.replace("-", " ")
    STATION_URL = tag_selected_url[ran]
    mpv_PLAY(STATION, STATION_URL)
    LOOP2=1
   if int(STATION_INDEX) > 0 and int(STATION_INDEX) <= tag_selected_len:
    STATION = tag_selected_name[int(STATION_INDEX)-1].strip('~')
    STATION = STATION.replace("-", " ")
    STATION_URL = tag_selected_url[int(STATION_INDEX)-1]
    LOOP2 = 1
    mpv_PLAY(STATION, STATION_URL)

def print_menu_2(sel_name,sel_url,sel_len):
 print("\033c")
 print_logo()
 s=0
 print(B+"   ╭──────────────────────Stations─╮")
 print("   │   "+M+"0"+G+" 😀 Random Station         "+B+"│")
 while s < sel_len:
  sel_name_line = sel_name[s].strip('~')
  SELLINE="   │  "+M+" "+str(s+1)+Y+" "+sel_name_line.replace("-", " ")+"                                  "
  print(SELLINE[:49]+B+"│")
  s +=1
 print("   ├───────────────────────Actions─┤")
 print("   │   "+M+"x"+G+" 👈 Go Back                "+B+"│")
 print("   │   "+M+"Q"+R+" ❌ Quit Radion            "+B+"│")
 print("   ├───────────────────────────────┤")
 print("   │"+G+" Enter number/letter:          "+B+"│")
 print("   ╰───────────────────────────────╯"+M)


def print_menu_1(fav_name,fav_len,TAGS,TAGS_len):
 print_logo()
 f=0
 t=0
 print(B+"   ╭─────────────────────Favorites─╮")
 print("   │   "+M+"0"+G+" 😀 Random Station         "+B+"│")
 while f < fav_len:
  fav_name_line = fav_name[f].strip('~')
  FAVLINE="   │  "+M+" "+str(f+1)+Y+" "+fav_name_line.replace("-", " ")+"                                  "
  print(FAVLINE[:49]+B+"│")
  f +=1

 print(B+"   ├──────────────────────────Tags─┤")
 while t < TAGS_len:
  TAGLINE="   │  "+M+" "+str(t+f+1)+C+" "+TAGS[t].strip("#")+"                                  "
  print(TAGLINE[:49]+B+"│")
  t += 1
 print("   ├───────────────────────Actions─┤")
 print("   │   "+M+"A"+G+" ⭐ All Stations           "+B+"│")
 print("   │   "+M+"Q"+R+" ❌ Quit Radion            "+B+"│")
 print("   ├───────────────────────────────┤")
 print("   │"+G+" Enter number/letter:          "+B+"│")
 print("   ╰───────────────────────────────╯"+M)

def keybindings():
 print("\r"+B+"╭─────┬──────────╮")
 print("\r"+B+"│"+M+"  ␣  "+B+"│"+C+"    Pause "+B+"│")
 print("\r"+B+"├─────┼──────────┤")
 print("\r"+B+"│"+M+" 9 0 "+B+"│"+C+"   ↑↓ Vol "+B+"│")
 print("\r"+B+"├─────┼──────────┤")
 print("\r"+B+"│"+M+"  m  "+B+"│"+C+"     Mute "+B+"│")
 print("\r"+B+"├─────┼──────────┤")
 print("\r"+B+"│"+M+" ← → "+B+"│"+C+" Skip 10\""+B+" │")
 print("\r"+B+"├─────┼──────────┤")
 print("\r"+B+"│"+M+" ↑ ↓ "+B+"│"+C+" Skip 60\""+B+" │")
 print("\r"+B+"├─────┼──────────┤")
 print("\r"+B+"│"+M+"  q  "+B+"│"+R+"     Quit "+B+"│")
 print("\r"+B+"╰─────┴──────────╯"+M)

def print_logo():
 print("\r"+B+"    ╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮")
 print("\r    │ "+Y+"R "+B+"││ "+Y+"A "+B+"││ "+Y+"D "+B+"││ "+Y+"I "+B+"││ "+Y+"O "+B+"││ "+Y+"N "+B+"│")
 print("\r    ╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯"+n)

def mpv_PLAY(STATION, STATION_URL):
# print_play(STATION, STATION_URL)
 player = mpv.MPV()
 player.terminal = True
 player.term_status_msg = '\r\x1b[38;5;60mV:${volume}%  P:${time-pos}/${duration} (${percent-pos}% ${demuxer-cache-duration}\b\b\b\b)    '
 player.input_terminal = False
 player.term_title = "Py-Radion"
 player.play(STATION_URL)
 keybind_loop=0
 while keybind_loop == 0:
  print("\033c")
  @player.property_observer('metadata')
  def metadata_observer(_name, value1):
   try:
    if keybind_loop != 1 :
     print_play(STATION, STATION_URL)
     title = value1.get('icy-title')
     if title == None:
      title = "No Title Available"
     print("\r"+B+"Title   : "+Y+title+n)
   except:
    time.sleep(0.5)
  getch = _getch()
  if getch == 'q' or getch == 'Q':
   keybind_loop=1
   player.terminate()
   print("\033c")
  elif getch == "m" or getch == "M":
   if player.mute == True:
    player.mute =False
   else:
    player.mute = True
  elif getch == "9":
   if player.volume != 0:
    player.volume -= 1
  elif getch == "0":
   if player.volume != 150:
    player.volume += 1
  elif "C" in getch:
   player.seek(10)
  elif "D" in getch:
   player.seek(-10)
  elif "A" in getch:
   player.seek(60)
  elif "B" in getch:
   player.seek(-60)
  elif getch == " ":
   if player.pause == False:
    player.pause = True
   else:
    player.pause = False

def print_play(STATION, STATION_URL):
 print("\033c")
 print_logo()
 keybindings()
 print("\r"+B+"Station : "+Y+STATION+"\n\r"+B+"URL     : "+C+STATION_URL+n)

#########################################
B="\x1b[38;5;60m" #Grid Color
Y="\033[1;33m"    #Yellow
G="\033[1;32m"    #Green
R="\033[1;31m"    #Red
M="\033[1;35m"    #Magenta
C="\033[1;36m"    #Cyan
n="\x1b[0m"     #Normal
stations = open("stations.txt")
stations = stations.read()
stations_lines=stations.split('\n')
stations_lines_len=len(stations_lines)
stations_len = 0
TAGS_len = 0
stations_url = []
stations_name = []
TAGS = []
fav_name = []
fav_url = []
fav_len = 0
tag_selected_name = []
tag_selected_url =[]
x=0
while x < stations_lines_len:
 stations_lines_strip=stations_lines[x].strip()
 comment_check = stations_lines_strip.startswith("//")
 if stations_lines[x] != "" and comment_check != True:
  line_list = stations_lines[x].split(' ')
  stations_url.append(line_list[0])
  stations_name.append(line_list[1])
  stations_len+=1
  if "#Favorites" in stations_lines[x]:
   fav_url.append(line_list[0])
   fav_name.append(line_list[1])
   fav_len += 1
 #TAGS
 tags0 = stations_lines[x].split(" ")
 tags0_len = len(tags0)
 y=0
 while y < tags0_len:
  tag_check = tags0[y].startswith("#")
  if tag_check == True and tags0[y] != "#Favorites":
   TAGS.append(tags0[y])
  y+=1
 x+=1
TAGS = list(dict.fromkeys(TAGS))
TAGS_len = len(TAGS)
##################################
while True:
 print("\033c")
 LOOP1=0
 while LOOP1 == 0:
  print_menu_1(fav_name,fav_len,TAGS,TAGS_len)
  #TAG_INDEX = 0
  TAG_INDEX = input()
  tag_index_check_num = TAG_INDEX.isnumeric()
  tag_index_check_alpha = TAG_INDEX.isalpha()
  if tag_index_check_alpha == True:
   if TAG_INDEX == "Q" or TAG_INDEX == "q":
    quit()
   elif TAG_INDEX == "A" or TAG_INDEX == "a"or TAG_INDEX == "":
    TAG_SELECTED = "#"
    select_station(TAG_SELECTED, stations_lines)
    LOOP1=1
   elif TAG_INDEX == "D" or TAG_INDEX == "d":
    print(Y+"https://www.radio-browser.info/tags"+n)
  if tag_index_check_num == True:
   if int(TAG_INDEX) == 0:
    ran = (random.randrange(0,stations_len-1))
    STATION = stations_name[ran].strip('~')
    STATION = STATION.replace("-", " ")
    STATION_URL = stations_url[ran]
    LOOP1=1
    mpv_PLAY(STATION, STATION_URL)
   if int(TAG_INDEX) > 0 and int(TAG_INDEX) <= fav_len:
    STATION = fav_name[int(TAG_INDEX)-1].strip('~')
    STATION = STATION.replace("-", " ")
    STATION_URL = fav_url[int(TAG_INDEX)-1]
    LOOP1=1
    mpv_PLAY(STATION, STATION_URL)
   if int(TAG_INDEX) > fav_len and int(TAG_INDEX) <= fav_len+TAGS_len:
    TAG_SELECTED = TAGS[int(TAG_INDEX)-fav_len-TAGS_len-1]
    select_station(TAG_SELECTED, stations_lines)
    LOOP1=1
