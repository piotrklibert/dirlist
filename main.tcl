proc ls { p } {
    return [glob -dir $p *]
}


proc desc {p} {
    set v ""
    if { [catch {set v [ls $p] } ] } {
        return [list $p]
    } {
        set res [list]
        foreach a $v { set res [concat $res [desc $a]]}
        return [concat [list $p] $res ]
    }
}


foreach a [lsort [desc [exec pwd]]] {
    puts $a
}
