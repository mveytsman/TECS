(LOOP1)
//loop untill keyboard is pressed
@KBD
D=M
@LOOP1
D;JEQ

(FILL)
@8191
D=A
@R0
M=D

(FILLLOOP)
//store pixel location in R1
@SCREEN
D=A
@R0
A=D+M
M=-1


//decrement counter
@R0
M=M-1
D=M

//exit loop
@LOOP2
D;JLT

//keep looping
@FILLLOOP
0;JMP


(LOOP2)
//loop untill keyboard is NOT  pressed
@KBD
D=M
@CLEAR
D;JEQ

@LOOP2
0;JMP

(CLEAR)
@8191
D=A
@R0
M=D

(CLEARLOOP)
//store pixel location in R1
@SCREEN
D=A
@R0
A=D+M
M=0

//decrement counter
@R0
M=M-1
D=M

//exit loop
@LOOP1
D;JLT

//keep looping
@CLEARLOOP
0;JMP

