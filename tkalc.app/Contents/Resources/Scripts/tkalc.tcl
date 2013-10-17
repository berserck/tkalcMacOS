#!/bin/sh
#
# $Id: tkalc.tcl,v 1.4 2001/01/11 13:35:43 boris Exp $

# tkalc - Programmer's almighty pocket calculator 
# Copyright (C) 2000  Boris Folgmann
 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# the next line restarts using wish \
exec /System/Library/Frameworks/Tk.framework/Versions/8.5/Resources/Wish.app/Contents/MacOS/wish "$0" "$@"

# Globals
set expression  ""
set VERSION     "tkalc 1.0.2"
set decimal     "Welcome to tkalc!"
set hexadecimal "Enter expression and press return."
set octal       "Press Esc to close window."
set binary      "Alt+C for Clear and so on"
set ascii       "Tab to change widget, space to push button"
set ip          "Check out http://www.folgmann.de"
set bool        "Email: boris@folgmann.de"        
set errormsg    "tkalc (c) 2000-2001 by Boris Folgmann"
# I use this as a constant for the widget width in characters
set WIDTH       38

# Set window title
# . is always the toplevel widget
wm title   . $VERSION
wm grid    . 45 20 10 10
wm minsize . 45 20
wm resizable . 1 0

# Set defaults
. config -borderwidth 3

# Make main frame
set m [frame .main]
grid columnconf $m 1 -weight 1
# Make buttons frame
set b [frame .buttons]
# Center at top
grid $m $b -sticky new
# Use 5:1 for output against buttons
grid columnconf . 0 -weight 5
grid columnconf . 1 -weight 1

# expression entry
label $m.lexpression -text Expr -padx 0
# The increased borderwidth is needed so that the ridge border is as thick as the sunken border.
entry $m.expression  -width $WIDTH -relief ridge -borderwidth 3 -background white -textvariable expression
grid  $m.lexpression $m.expression -padx 3 -pady 1 -sticky news

# Decimal       
label $m.ldec -text Dec -padx 0
label $m.dec  -width $WIDTH -relief sunken -textvariable decimal
grid  $m.ldec $m.dec  -padx 3 -pady 1 -sticky news
# Use sticky west for left centered labels!
# -sticky w

# Hex
label $m.lhex -text Hex -padx 0
label $m.hex -width $WIDTH -relief sunken -textvariable hexadecimal
grid  $m.lhex $m.hex -padx 3 -pady 1 -sticky news

# Oct
label $m.loct -text Oct -padx 0
label $m.oct -width $WIDTH -relief sunken -textvariable octal
grid  $m.loct $m.oct -padx 3 -pady 1 -sticky news

# Bin
label $m.lbin -text Bin -padx 0
label $m.bin -width $WIDTH -relief sunken -textvariable binary
grid  $m.lbin $m.bin -padx 3 -pady 1 -sticky news

# ASCII
label $m.lascii -text ASCII -padx 0
label $m.ascii -width $WIDTH -relief sunken -textvariable ascii
grid  $m.lascii $m.ascii  -padx 3 -pady 1 -sticky news

# IP
label $m.lip -text IP -padx 0
label $m.ip -width $WIDTH -relief sunken -textvariable ip
grid  $m.lip $m.ip  -padx 3 -pady 1 -sticky news

# Bool
label $m.lbool -text Bool -padx 0
label $m.bool  -width $WIDTH -relief sunken -textvariable bool
grid  $m.lbool $m.bool -padx 3 -pady 1 -sticky news

# Error
label $m.lerr -text  Status -padx 0
label $m.err  -width $WIDTH -relief sunken -textvariable errormsg
grid  $m.lerr $m.err -padx 3 -pady 1 -sticky news

# buttons
button $b.eval  -text Evaluate  -underline 0 -command Eval
button $b.clear -text Clear     -underline 0 -command Clear
button $b.nums  -text Numbers   -underline 0 -command Nums
button $b.ops   -text Operators -underline 0 -command Ops
button $b.funcs -text Functions -underline 0 -command Funcs
button $b.about -text About     -underline 0 -command About 
button $b.quit  -text Quit      -underline 0 -command exit
# Stick all to left and right edge, so they have the same width!
grid columnconf $b 0 -weight 1
grid $b.eval  -sticky new 
grid $b.clear -sticky new 
grid $b.nums  -sticky new
grid $b.ops   -sticky new
grid $b.funcs -sticky new
grid $b.about -sticky new
grid $b.quit  -sticky new

# Set keybindings and inital focus
bind  . <Escape> exit
bind  . <Alt-e>  Eval
bind  . <Alt-c>  Clear
bind  . <Alt-n>  Nums
bind  . <Alt-o>  Ops
bind  . <Alt-f>  Funcs
bind  . <Alt-a>  About
bind  . <Alt-q>  exit
bind  $m.expression <Return> Eval
# We need -force here, otherwise the main windows doesn't get active
# when running on Win98
focus -force $m.expression

# Procedures starting here
proc Clear {} {
    global expression
    set expression ""
}

proc ip {ip} {
    if {[regexp "(\[^.\]+)\\\.(\[^.\]+)\\\.(\[^.\]+)\\\.(\[^.\]+)" $ip m a b c d]} {
	if {[string equal "$ip" "$m"]} {
	    if {[expr {$a > 255 || $b > 255 || $c > 255 || $d > 255}]} {
		error "max component size of IP address is 255"
	    }	    
	    return [expr {$a << 24 | $b << 16 | $c << 8 | $d}]
	}
    }
    error "not a valid IP address"
}

proc bin {bin} {
    set result 0

    for {set i 0} {$i < [string length $bin]} {incr i} {
	set digit [string index $bin $i]
	
	if {$digit == 0 || $digit == 1} {
	    set result [expr {$result << 1 | $digit}]
	} elseif {$digit == "."} {
	    #ignore
	} else {
	    error "not a valid binary digit"
	}
    }

    return $result
}


# Evaluate expression
proc Eval {} {
    # say what global vars you want to use
    # if you forget it here, you will use a local var
    global expression decimal hexadecimal octal binary ascii ip bool
    global errormsg m m.err

    if {[SafeExpr $expression]} {
        set decimal $result
	if {[SafeExpr int($result)]} {
	    set hexadecimal [format "%#010x" [expr {$result}]]
	    set octal       [format "%#o"    [expr {$result}]]
	    set binary      [DecToBin        [expr {$result}]]
	    set ascii       [format "\"%s%s%s%s\""\
		                 [Char [expr {$result} >> 24 & 0xff]]\
				 [Char [expr {$result} >> 16 & 0xff]]\
				 [Char [expr {$result} >>  8 & 0xff]]\
				 [Char [expr {$result}       & 0xff]]]
	    set ip          [format "%s.%s.%s.%s"\
		                 [expr {$result} >> 24 & 0xff]\
				 [expr {$result} >> 16 & 0xff]\
				 [expr {$result} >>  8 & 0xff]\
				 [expr {$result}       & 0xff]]
	    
	    if {int($result)} {
		set bool "True" 
	    } else {
		set bool "False"
	    }
	}
    } else {
	set decimal ""
    }
  
}

proc SafeExpr {exp} {
    global expression decimal hexadecimal octal binary ascii ip bool
    global errormsg m m.err

    # uplevel is used to access callers result variable!
    if {[catch {uplevel "set result [expr $exp]"} errormsg]} {
	#catch returns non-zero on error
	$m.err config -foreground red
	bell
	set hexadecimal ""
	set octal ""
	set binary ""
	set ascii ""
	set ip ""
	set bool ""
	return 0
    } else {
	#catch returns zero on success
	set errormsg "Ok"
	#default would be better than black!
	$m.err config -foreground black
	return 1
    }
}

proc Char {byte} {
    if {$byte >= 32 && $byte <= 126} {
	return [format "%c" $byte]
    } else {
	return "."
    }
}

proc ByteToBin {byte} {
    for {set i 0} {$i < 8} {incr i} {
	append result [format "%d" [expr {($byte & 0x80) >> 7}]]
	set byte [expr {$byte << 1}]
    }
    return $result
}

proc DecToBin {dec} {
    append result     [ByteToBin [expr {$dec >> 24 & 0xff}]]\
	          "." [ByteToBin [expr {$dec >> 16 & 0xff}]]\
	          "." [ByteToBin [expr {$dec >>  8 & 0xff}]]\
		  "." [ByteToBin [expr {$dec       & 0xff}]]

    return $result
}

proc About {} {
    global tcl_platform
    set title "About"
    set text  "tkalc (c) 2000 by Boris Folgmann. 
Released under the GPL (General Public License)
For latest version check out http://www.folgmann.de
Send bug reports and suggestions to: boris@folgmann.de
"
    switch $tcl_platform(platform) {
	unix {
	    DisplayText $title $text
	}
	windows {
	    set choice [tk_messageBox -title "tkalc: About" -message $text]
	}
    }
}

proc DisplayText {name text} {
    global tcl_platform m
# the w prefix is randomly choosen!
    if {[winfo exists .w$name]} {
	wm deiconify .w$name
	focus .w$name
	return
    }
    set       numlines [regsub -all \n $text {} ignore]

    switch $tcl_platform(platform) {
	unix {
	    set       font {fixed}
	}
	windows {
	    set       font {systemfixed}
	}
    }

    set       w [toplevel .w$name -borderwidth 3]
    append    title "tkcalc: " $name
    wm title  $w $title
    focus     .w$name
    bind      $w <Escape> {destroy %W}
    bind      $w <Destroy> {focus -force $m.expression}
    # Create connected text and scrollbar widget
    scrollbar $w.yscroll -command "$w.text yview" -orient vertical
    text      $w.text -yscrollcommand "$w.yscroll set" -wrap word -font $font -width 54 -height $numlines

    # Pack scrollbar first! Otherwise its clipped for small windows
    pack      $w.yscroll -side right -fill y
    pack      $w.text    -side left  -fill both -expand true

    # set read only text
    $w.text   config -state normal
    $w.text   insert end $text
    $w.text   config -state disabled
}


proc Nums {} {
    DisplayText "Numbers" "Valid numbers are:
Description\tExample
Decimal\t\t42
Float\t\t34.235
Scientific\t45.12e5
Hex\t\t0xdeadbeef
Octal\t\t0774 (leading zero)
Binary\t\t\[bin 1000.1111] (place dots at will)
IP address\t\[ip 192.168.41.1]
"
}

proc Ops {} {
    DisplayText "Operators" "Operators from highest to lowest precedence:
* ~ !\t\tUnary minus, bitwise NOT, logical NOT
* / %\t\tMultiply, divide, remainder
+ -\t\tAdd, subtract
<< >>\t\tLeft shift, right shift
< > <= >=\tLess, greater, less or equal,
\t\tgreater or equal
== !=\t\tEqual, not equal
&\t\tBitwise AND
^\t\tBitwise XOR
|\t\tBitwise OR
&&\t\tLogical AND
||\t\tLogical OR
x?y:z\t\tIf x then y else z
"
}

proc Funcs {} {
    DisplayText "Functions" "Available functions are:
acos(x)
asin(x)
atan(x)
atan2(y,x)
ceil(x)
cos(x)
cosh(x)
exp(x)
floor(x)
fmod(x,y)
hypot(x,y)
log(x)
log10(x)
pow(x,y)
sin(x)
sinh(x)
sqrt(x)
tan(x)
tanh(x)
abs(x)
double(x)
int(x)
round(x)
rand()
srand(x)
"
}
