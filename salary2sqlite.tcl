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

package require htmlparse
package require struct
package require sqlite3

set db_name nba.sqlite

set tab(salary) {
			id text 0
			year integer 3
			season text 1
	 		tm text 2
	 		salary text 4
}

# **********************************************
proc create_table {table} {
	global tab
	# create table zusammenbauen und absetzen
	set c ""
	set sql "create table if not exists $table ("
	foreach {col type idx} $tab($table) {
		set sql "$sql$c $col $type"
		set c ","
	}
	set sql "$sql)"
	db eval $sql
}

# **********************************************
proc insert_table {table l} {
	global tab
	# insert into zusammenbauen und absetzen
	set c ""
	set sql "insert into $table values ("
	foreach {col type idx} $tab($table) {
		if {$type == "text"} {set a "'"} else {set a ""}
		set sql "$sql$c$a[lindex $l $idx]$a"
		set c ","	
	}
	set sql "$sql)"
	puts $sql
	db eval $sql
}

# *********************************************************
proc get_node_value {n} {
	global t
	set data [$t get [$t children  $n] data]
	if {[$t get [$t children  $n] type]=="PCDATA"} {
		return $data
	}
	# Team (href="/teams/DAL/2005.html") --> Team
	if {[string match */teams/* $data]} {
		set l [split $data =]
		set l [lindex $l 1]
		set l [split $l /]
		set data [lindex $l 2]
		return $data	
	}
	# Liga (href="/leagues/NBA_2004.html") --> Jahr
	if {[string match */leagues/* $data]} {
		set l [split $data =]
		set l [lindex $l 1]
		set l [split $l /]
		set l [lindex $l 2]
		set l [split $l .]
		set l [lindex $l 0]
		set l [split $l _]
		set data [lindex $l 1]
		return $data	
	}
}

# **********************************************
proc get_salary_of_player {fname} {
	global t
	set fd [open $fname r]
	set data [read $fd [file size $fname]]
	close $fd	
	
	htmlparse::2tree $data $t
    htmlparse::removeVisualFluff $t
    htmlparse::removeFormDefs $t

	# player aus fname (data/players/abdulta01.txt)
	set player [split $fname /]
	set player [lindex $player 2]
	set player [split $player .]
	set player [lindex $player 0]

	foreach n [$t nodes] {
		if {[$t keyexists $n data]} {
			if {([$t get $n data] == "class=\"sortable  stats_table\" id=\"salaries\"")} {
				foreach c [$t children  $n] {
					if {[$t get $c type]=="tbody"} {
						foreach c1 [$t children  $c] {
							set l {}
							foreach c2 [$t children  $c1] {
								set l [linsert $l end [get_node_value $c2]]
							}
							# player hinzufuegen
							set l [linsert $l 0 $player]
							# ...salary (4.Element) formatieren
							set salary [string map {$ "" , ""} [lindex $l 4]]
							set l [lreplace $l 4 4 $salary]
							#puts $l
							insert_table salary $l
							#puts "-----------------------------"
						}
					}
				}
			}
		}
	}
}

# **********************************************
# **********************************************
# **********************************************

sqlite3 db $db_name
create_table salary

set files [glob -nocomplain -directory data/players/ *.txt]
set files [lsort -ascii $files]
puts $files

foreach fname $files {
	puts $fname
	set t [::struct::tree]
	catch {get_salary_of_player $fname}
	$t destroy
}
