.global main
.func main
   
main:

    BL  _prompt             @ branch to prompt procedure with return
    BL  _scanf              @ branch to scanf procedure with return
    MOV R5, R0 				@int n
   
    BL	_prompt
    BL	_scanf2
    MOV R6, R0 				@int m
    
    CMP R6,R5
    BLGT _exit
    BL	alu
    MOV R1, R0
    MOV R2, R5
    MOV R3, R6
    BL 	_printf            @ branch to print procedure with return
    B   main               @ branch to exit procedure with no return

alu:
	PUSH {LR}
	CMP R5, #0
	MOVEQ R0, #1
	POPEQ {PC}
	
	MOVLT R0,#0
	POPLT {PC}
	
	CMP R6, #0
	MOVEQ R0, #0
	POPEQ {PC}
	
	PUSH {R5}
	SUB R5,R5,R6
	BL alu
	POP {R5}
	
	
	PUSH {R6}
	PUSH {R0}
	SUB R6,R6,#1
	BL alu
	POP {R1}
	POP {R6}
	
	
	ADD R0,R0,R1
	POP {PC}	

_eh:
    MOV R8, LR              @ store LR since printf call overwrites
    LDR R0, =format_str     @ R0 contains formatted string address
    BL printf               @ call printf
    MOV PC, R8              @ return

_exit:  
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #21             @ print string length
    LDR R1, =exit_str       @ string at label exit_str:
    SWI 0                   @ execute syscall
    MOV R7, #1              @ terminate syscall, 1
    SWI 0                   @ execute syscall

_prompt:
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #31             @ print string length
    LDR R1, =prompt_str     @ string at label prompt_str:
    SWI 0                   @ execute syscall
    MOV PC, LR              @ return
       
_printf:
    MOV R4, LR              @ store LR since printf call overwrites
    LDR R0, =printf_str     @ R0 contains formatted string address
    MOV R1, R1              @ R1 contains printf argument (redundant line)
    BL printf               @ call printf
    MOV PC, R4              @ return
    
_scanf:
    PUSH {LR}                @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                 @ return

_scanf2:
    PUSH {LR}                @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                 @ return

.data
format_str:     .asciz      "%d"
prompt_str:     .asciz      "Type a number and press enter: "
printf_str:     .asciz      "There are %d partitions of %d using integers up to %d.\n"
exit_str:       .ascii      "Terminating program.\n"
