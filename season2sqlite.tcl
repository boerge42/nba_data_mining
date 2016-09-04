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

set year_begin 2000
set year_end   2016

#
# SQL-Tabellen (Spaltenname Type Index)
#
set tab(season) {
			year integer 0
			id text 1
			name text 2
	 		pos text 3
	 		age text 4
	 		tm text 5
	 		g text 6
	 		mp text 7
	 		per text 8
	 		ts text 9
			_3par text 10
			ftr text 11
			orb text 12
			drb text 13
			trb text 14
			ast text 15
			stl text 16
			blk text 17
			tov text 18
			usg text 19
			xxx text 20
			ows text 21
			dws text 22
			ws text 23
			ws_48 text 24
			yyy text 25
			obpm text 26
			dbpm text 27
			bpm text 28
			vorp text 29
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
	set count [$t size $n]
	#puts "--> $count"
	if {$count == 0} {return "-"}
	if {$count == 1} {return [$t get [$t children $n] data]}
	if {$count == 2} {
		return [$t get [$t children $n] data]
	}
}

# ***************************************************************
proc get_player_of_saison {year} {
	global t
	
	set fname "data/player_saison_$year.txt"
	set fd [open $fname r]
	set data [read $fd [file size $fname]]
	close $fd	
	
	htmlparse::2tree $data $t
    htmlparse::removeVisualFluff $t
    htmlparse::removeFormDefs $t
	foreach n [$t nodes] {
		if {[$t keyexists $n data]} {
			if {([$t get $n data] == "class=\"full_table\"")} {
				set l {}
				foreach c [$t children  $n] {
					if {[$t size $c]<3} {
						set l [linsert $l end [get_node_value $c]]
						if {[$t size $c]==2} {
							set l [linsert $l end [get_node_value [$t children $c]]]
						}
					} else {
						foreach c1 [$t children $c] {
							if {[$t size $c1] > 0} {
								set l [linsert $l end [$t get $c1 data]]
								set l [linsert $l end [get_node_value $c1]]
							}
						}
					}
					
				}
				# puts $l
				set href [string range [lindex [split [lindex $l 1] =] 1] 1 end-1]
				set player [lindex [split [lindex [file split $href] end] .] 0]
				#puts $player
				#puts $l
				# Liste noch fertig manipulieren
				# ...0.Element ersetzen mit Jahr
				set l [lreplace $l 0 0 $year]
				# ...1.Element ersetzen mit SpielerID
				set l [lreplace $l 1 1 $player]
				# ...2.Element (Name) anpassem
				set name [lindex $l 2]
				set name [string map {' " "} $name]
				set l [lreplace $l 2 2 $name]
				# ...5.Element raus
				set l [lreplace $l 5 5]
				# ... wenn nur 29 Elemente, dann an 5.Stelle TOT einfuegen
				if {[llength $l]==29} {set l [linsert $l 5 "TOT"]}
				# puts $l
				insert_table "season" $l
			}
		}
	}
}


# **********************************************
# **********************************************
# **********************************************

sqlite3 db $db_name
create_table season

# ...alle Jahre
for {set i $year_begin} {$i<=$year_end} {incr i} {
	set t [::struct::tree]
	get_player_of_saison $i
	$t destroy
}
