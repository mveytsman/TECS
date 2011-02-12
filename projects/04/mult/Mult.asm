//clear out R2
@R2
M=0


//we are going to be naive here
(LOOP)
@R1
D=M
@END
D;JEQ //jump to end if R1==0

//add R0 to R2
@R0
D=M
@R2
M=M+D

//decriment R1
@R1
M=M-1

//loop
@LOOP
0;JMP

(END)
//infinite loop
@END
0;JMP



