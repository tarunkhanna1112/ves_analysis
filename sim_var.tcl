# tclsh sim_var.tcl no_temp temp(s) var repeat_no

set output [lindex $::argv [expr { 1 + (2 * [lindex $::argv 0]) }]]
set index [lindex $::argv [expr { 2 + (2 * [lindex $::argv 0]) }]]
set f [open "$index.$output" "w"]
set j 0

set k1 0
while { $k1 < [lindex $::argv 0] } {
	set num_file [lindex $::argv [expr { $k1 + 1 + [lindex $::argv 0] }]]
	for {set i 1 } {$i <= $num_file} {incr i} {
		set temp [lindex $::argv [expr { 1 + $k1 }]]
		puts "				#### FILE $i TEMP = $temp ####"
		set g [open "$i.Prod1_test_$temp.out" "r"]
		set data1 [read $g]
		close $g

		set term [string first "NSTEP" $data1 ]

		set data [string range $data1 $term [string length $data1]]

		set k 0
		set old_step 0
		while { $k < [llength $data] } {
			if { [lindex $data $k] == "NSTEP" } {
				set step [lindex $data [expr { $k + 2 }]]
				if { $old_step == $step } {
					set k [llength $data]
				}
			}
			if { [lindex $data $k] == "$output" } {
				set poten [lindex $data [expr { $k + 2 }]]
				puts $f "$j $poten"
				incr j
				set old_step $step
			}
			incr k
		}
	}
	incr k1
}
puts "				#### NO OF TERMS == $j ####"
close $f
