.section .data 

.section .text.init 
.global _start 
_start: 
	# li sp, 2044
	la sp, _sp0
	la ra, _run_prog 
	jal main

_run_prog: 
	la ra, _endloop
	jalr a0 

_endloop:
	j _endloop