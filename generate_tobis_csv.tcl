#
#  Autor: Uwe Berger; 2016
#  -----------------------
#
# ======================================================================
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
# ======================================================================

package require sqlite3

set db_name nba.sqlite
sqlite3 db $db_name

# ****************************************
# ****************************************
# ****************************************

# CSV-Header (Spaltennamen) schreiben
	puts -nonewline	"Name,"
	puts -nonewline	"ID,"
	puts -nonewline	"Season,"
	puts -nonewline	"Pos,"
	puts -nonewline	"Age,"
	puts -nonewline	"Tm,"
	puts -nonewline	"G,"
	puts -nonewline	"MP,"
	puts -nonewline	"PER,"
	puts -nonewline	"TS%,"
	puts -nonewline	"3PAr,"
	puts -nonewline	"FTr,"
	puts -nonewline	"ORB%,"
	puts -nonewline	"DRB%,"
	puts -nonewline	"TRB%,"
	puts -nonewline	"AST%,"
	puts -nonewline	"STL%,"
	puts -nonewline	"BLK%,"
	puts -nonewline	"TOV%,"
	puts -nonewline	"USG%,"	
	puts -nonewline	"OWS,"
	puts -nonewline	"DWS,"
	puts -nonewline	"WS,"
	puts -nonewline	"WS/48,"	
	puts -nonewline	"OBPM,"
	puts -nonewline	"DBPM,"
	puts -nonewline	"BPM,"
	puts -nonewline	"VORP,"
	puts -nonewline	"Draftteam,"
	puts -nonewline	"Draftposition,"
	puts -nonewline	"Draftyear,"
	puts -nonewline	"Salary"
	puts ""

# DB auslutschen...
#set sql "select * from season where id like 'am%' order by id, year"
set sql "select * from season order by id, year"
db eval $sql {
	# Draft-Daten zum Spieler
	set d_year ""
	set d_tm ""
	set d_pk "undrafted"
	set sql1 "select year as d_year, tm as d_tm, pk as d_pk from drafts where id='$id'" 
	db eval $sql1 {
		set d_year $d_year
		set d_tm $d_tm
		set d_pk $d_pk
	}
	# Salary-Daten zum Spieler und Saison
	set a_salary ""
	set sql1 "select sum(salary) as a_salary from salary where id='$id' and year=$year" 
	db eval $sql1 {
		set a_salary $a_salary
	}
	# CSV-Zeile generieren
	puts -nonewline	"$name,"
	puts -nonewline	"$id,"
	puts -nonewline	"$year,"	
	puts -nonewline	"$pos,"
	puts -nonewline	"$age,"
	puts -nonewline	"$tm,"
	puts -nonewline	"$g,"
	puts -nonewline	"$mp,"
	puts -nonewline	"$per,"
	puts -nonewline	"$ts,"
	puts -nonewline	"$_3par,"
	puts -nonewline	"$ftr,"
	puts -nonewline	"$orb,"
	puts -nonewline	"$drb,"
	puts -nonewline	"$trb,"
	puts -nonewline	"$ast,"
	puts -nonewline	"$stl,"
	puts -nonewline	"$blk,"
	puts -nonewline	"$tov,"
	puts -nonewline	"$usg,"
	puts -nonewline	"$ows,"
	puts -nonewline	"$dws,"
	puts -nonewline	"$ws,"
	puts -nonewline	"$ws_48,"	
	puts -nonewline	"$obpm,"
	puts -nonewline	"$dbpm,"
	puts -nonewline	"$bpm,"
	puts -nonewline	"$vorp,"
	puts -nonewline	"$d_tm,"
	puts -nonewline	"$d_pk,"
	puts -nonewline	"$d_year,"
	puts -nonewline	"$a_salary"
	puts ""
}

db close

# Tobis Felder|DB-Felder
#
#Tabelle season:
#---------------
# Name  name
# ID    id
# Season year
# Pos   pos
# Age   age
# Tm    tm
# G     g
# MP    mp
# PER   per
# TS%   ts
# 3PAr  _3par
# FTr   ftr
# ORB%  orb
# DRB%  drb
# TRB%  trb
# AST%  ast
# STL%  stl
# BLK%  blk
# TOV%  tov
# USG%  usg	
# OWS   ows
# DWS   dws
# WS    ws
# WS/48 ws_48	
# OBPM  obpm
# DBPM  dbpm
# BPM   bpm
# VORP  vorp
#
#Tabelle draft:
#--------------
# Draftteam     tm
# Draftposition pk
# Draftyear     year
#
#Tabelle salary:
#---------------
# Salary salary
# 
