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

set sql "select id, name from season group by id"
db eval $sql {
	puts "$id --> $name"
	set sql1 "update drafts set id='$id' where player='$name'"
	puts $sql1
	db eval $sql1
}

db close
