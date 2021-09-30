.loadtable "data/flyover-table.tbl"

// Does 09 work for linebreaks? Existing bin used the system here

db      02h, 00h
db      01h, 44h 
.strn   "The palace of \cpoo"
db      02h, 04h
db      01h, 50h
.str    "The Crown Prince\n"