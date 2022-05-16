	.arch armv8-a
//A*(B-C)+A*(D-E)+F*(G+H)
	.data
mes1:
	.string	"Matrix:\n"
mes2:
	.string	"%lf"
mes21:
	.string "Element = %lf\n"
mes:
	.string "%d"
mes0:
	.string "Size of matrixes = %d\n"
mes3:
	.string	"%.5lf "
mes4:
	.string	"\n"
modeopen:
	.string "r"
open_error_msg:
	.string "\nError with opening file \"%s\"\n"
open_success_msg:
	.string "\nFile \"%s\" was opened successfully\n"
arg_error_msg:
	.string "\nError! Number of parameters of command line = %d does not enough!\n"
close_error_msg:
	.string "\nError with closing file\n"
size_error_msg:
	.string "\nSize of matrixes can not be = %d\n"
data_error_msg:
	.string "\nData in file are in incorrect form\n"
empty_file_msg:
	.string "\nFile is empty\n"
eof_msg:
	.string "\nEOF reached\n"
msg1:
	.string "\n//B-C\n"
msg2:
	.string "\n//A*(B-C)\n"
msg3:
	.string "\n//D-E\n"
msg4:
	.string "\n//A*(D-E)\n"
msg5:
	.string "\n//A*(B-C)+A*(D-E)\n"
msg6:
	.string "\n//G+H\n"
msg7:
	.string "\n//F*(G+H)\n"
msg8:
	.string "\n//A*(B-C)+A*(D-E)+F*(G+H)\n"
A:
	.skip 3200
B:
	.skip 3200
C:
	.skip 3200
D:
	.skip 3200
E:
	.skip 3200
F:
	.skip 3200
G:
	.skip 3200
H:
	.skip 3200
buf_matrix1:
	.skip 3200
buf_matrix2:
	.skip 3200
buf_matrix3:
	.skip 3200	
				
	.text
	.align	2

	.global mul_matrix
	.type	mul_matrix, %function
mul_matrix:
	//x3 - size, x1 - address of Matrix1, x2 - address of Matrix2, x0 - address of result Matrix
	mov x10, #-1 //line number
0:	
	add x10, x10, #1 //i
	mov x11, #0 //column number //j
	cmp x10, x3
	bge 2f
	mul x12, x10, x3
	lsl x12, x12, #3
1:
	cmp x11, x3
	bge 0b
	
	//fmov d0, #0.0
	movi d0, #0
	mov x13, #0 //k
3:
	cmp x13, x3
	bge 4f
	add x14, x12, x13, lsl #3 //a[i][k]
	ldr d1, [x1, x14]
	mul x15, x13, x3
	lsl x15, x15, #3
	add x15, x15, x11, lsl #3 //b[k][j]
	ldr d2, [x2, x15]
	fmul d3, d1, d2
	fadd d0, d0, d3
	add x13, x13, #1
	b 3b
4:
	add x12, x12, x11, lsl #3
	str d0, [x0, x12]
	add x11, x11, #1
	b 1b
2:
	ret	
	.size	mul_matrix, .-mul_matrix


	.global sum_matrix
	.type	sum_matrix, %function
sum_matrix:	
	//x3 - size, x1 - address of Matrix1, x2 - address of Matrix2, x0 - address of result Matrix 
	mov x10, #-1 //line number
0:	
	add x10, x10, #1
	mov x11, #0 //column number
	cmp x10, x3
	bge 2f
	mul x12, x10, x3
	lsl x12, x12, #3
1:
	cmp x11, x3
	bge 0b
	add x12, x12, x11, lsl #3
	ldr d1, [x1, x12]
	ldr d2, [x2, x12]
	fadd d0, d1, d2
	str d0, [x0, x12]
	add x11, x11, #1
	b 1b
2:
	ret	
	.size	sum_matrix, .-sum_matrix


	.global sub_matrix
	.type	sub_matrix, %function
sub_matrix:
	//x3 - size, x1 - address of Matrix1, x2 - address of Matrix2, x0 - address of result Matrix 
	mov x10, #-1 //line number
0:	
	add x10, x10, #1
	mov x11, #0 //column number
	cmp x10, x3
	bge 2f
	mul x12, x10, x3
	lsl x12, x12, #3
1:
	cmp x11, x3
	bge 0b
	add x12, x12, x11, lsl #3
	ldr d1, [x1, x12]
	ldr d2, [x2, x12]
	fsub d0, d1, d2
	str d0, [x0, x12]
	add x11, x11, #1
	b 1b
2:	
	ret	
	.size	sub_matrix, .-sub_matrix		


	.global make_matrix
	.type	make_matrix, %function
	.equ	x, 16
	.equ	y, 24
	.equ	z, 32
	.equ	e, 40
	.equ	a, 48
	.equ	b, 56
make_matrix:
	//x0 - address of result Matrix, x1 - size, x2 - fd
	stp	x29, x30, [sp, #-64]!
	mov	x29, sp
	stp x20, x21, [x29, x]
	str x22, [x29, z]
	stp x25, x26, [x29, a]
	mov x20, x0
	mov x21, x1
	mov x22, x2
	//get elements of matrixes
	mov x25, #0 
	mul x26, x21, x21 //count of elements in matrix
0:	
	cmp x25, x26
	bge 5f
	mov x0, x22
	adr x1, mes2
	add x2, x29, e
	bl fscanf 
	mov x1, #0xffffffff
	cmp x0, x1
	beq 2f
	cmp x0, #0
	beq 3f	
	
	ldr d0, [x29, e] //element
	str d0, [x20, x25, lsl #3]
	add x25, x25, #1
	b 0b
	
2:	//empty file
	mov x0, #-1
	b 4f
3:	//data_error	
	mov x0, #0
	b 4f
5:
	mov x0, x20		
4:	
	ldp x20, x21, [x29, x]
	ldr x22, [x29, z]
	ldp x25, x26, [x29, a]
	ldp	x29, x30, [sp], #64
	ret
	.size	make_matrix, .-make_matrix


	.global print_matrix
	.type	print_matrix, %function
	.equ	x, 16
	.equ	y, 24
	.equ	a, 32
	.equ	b, 40
print_matrix:
	//x0 - address of result Matrix, x1 - size
	stp	x29, x30, [sp, #-48]!
	mov	x29, sp
	stp	x20, x21, [x29, x]
	stp x22, x23, [x29, a]
	mov x20, x0
	mov x21, x1
	adr x0, mes1
	bl printf 
	
	mov x22, #-1 //line number
0:	
	add x22, x22, #1
	cmp x22, x21
	bge 4f
	mov x23, #0 //column number
1:
	cmp x23, x21
	bge 2f
	mul x12, x22, x21
	lsl x12, x12, #3
	add x12, x12, x23, lsl #3
	ldr d0, [x20, x12]
	adr x0, mes3
	bl printf //element
	add x23, x23, #1
	b 1b
2:
	adr x0, mes4
	bl printf
	b 0b
4:
	mov x0, #0
	ldp	x20, x21, [x29, x]
	ldp x22, x23, [x29, a]
	ldp	x29, x30, [sp], #48
	ret
	.size	print_matrix, .-print_matrix


	.global	main
	.type	main, %function
	.equ	x, 16
	.equ	y, 24
main:
	stp	x29, x30, [sp, #-32]!
	mov	x29, sp
	
	//finding filename from command line parameters
	mov x24, x0 //count of argv
	cmp x24, #1
	ble arg_error		
	ldr x0, [x1, #8] //address of filename or 0
	cmp x0, #0
	beq arg_error
	mov x20, x0 //store filename
	//open file
	adr x1, modeopen
	bl fopen
	mov x1, x20 
	cmp x0, #0 //!=NULL
	beq error_open
	mov x21, x0 //store fd
	
	//success_message
	adr x0, open_success_msg
	mov x1, x20
	bl printf

	//get size of matrixes
	mov x0, x21
	adr x1, mes
	add x2, x29, x
	bl fscanf
	mov x1, #0xffffffff
	cmp x0, x1
	beq empty_file
	cmp x0, #0
	beq data_error
	
	ldr x3, [x29, x]
	mov x1, x3
	cmp x3, #0
	ble error_size
	cmp x3, #20
	bgt error_size

	//print size
	adr x0, mes0
	mov x1, x3
	bl printf

	//make matrix
	//x0 - address of result Matrix, x1 - size, x2 - fd
	adr x0, A
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error

	adr x0, B
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error
	
	adr x0, C
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error		

	adr x0, D
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error

	adr x0, E
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error

	adr x0, F
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error	

	adr x0, G
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error

	adr x0, H
	ldr x1, [x29, x]
	mov x2, x21
	bl make_matrix
	cmp x0, #-1
	beq eof 
	cmp x0, #0
	beq data_error

	
	//B-C
	adr x0, msg1
	bl printf
	//x3 - size, x1 - address of Matrix1, x2 - address of Matrix2, x0 - address of result Matrix
	ldr x3, [x29, x]	
	adr x0, buf_matrix2
	adr x1, B
	adr x2, C
	bl sub_matrix
	ldrsw x1, [x29, x]
	bl print_matrix
		
	//A*(B-C)
	adr x0, msg2
	bl printf
	ldr x3, [x29, x]	
	adr x0, buf_matrix1  //A*(B-C)
	adr x1, A
	adr x2, buf_matrix2
	bl mul_matrix
	ldrsw x1, [x29, x]
	bl print_matrix	

	//D-E
	adr x0, msg3
	bl printf
	ldr x3, [x29, x]	
	adr x0, buf_matrix2
	adr x1, D
	adr x2, E
	bl sub_matrix
	ldrsw x1, [x29, x]
	bl print_matrix	

	//A*(D-E)
	adr x0, msg4
	bl printf
	ldr x3, [x29, x]	
	adr x0, buf_matrix3 //A*(D-E)
	adr x1, A
	adr x2, buf_matrix2
	bl mul_matrix
	ldrsw x1, [x29, x]
	bl print_matrix	

	//A*(B-C)+A*(D-E)
	adr x0, msg5
	bl printf
	ldr x3, [x29, x]	
	adr x0, buf_matrix1 //A*(B-C)+A*(D-E)
	adr x1, buf_matrix1
	adr x2, buf_matrix3
	bl sum_matrix
	ldrsw x1, [x29, x]
	bl print_matrix	

	//G+H
	adr x0, msg6
	bl printf
	ldr x3, [x29, x]	
	adr x0, buf_matrix2
	adr x1, G
	adr x2, H
	bl sum_matrix
	ldrsw x1, [x29, x]
	bl print_matrix	

	//F*(G+H)
	adr x0, msg7
	bl printf
	ldr x3, [x29, x]	
	adr x0, buf_matrix3 //F*(G+H)
	adr x1, F
	adr x2, buf_matrix2
	bl mul_matrix
	ldrsw x1, [x29, x]
	bl print_matrix	

	//A*(B-C)+A*(D-E)+F*(G+H)
	adr x0, msg8
	bl printf
	ldr x3, [x29, x]	
	adr x0, buf_matrix1 //A*(B-C)+A*(D-E)+F*(G+H)
	adr x1, buf_matrix1
	adr x2, buf_matrix3
	bl sum_matrix
	//in x0 - address of matrix, x1 - size
	ldrsw x1, [x29, x]
	bl print_matrix
	
	//closing file
	mov x0, x21
	bl fclose
	cbnz x0, error_close
	
	mov	w0, #0
quit:
	ldp	x29, x30, [sp], #32
	ret
eof:
	adr x0, eof_msg
	bl printf
	mov w0, #1
	b quit
arg_error:
	adr x0, arg_error_msg
	mov x1, x24
	bl printf
	mov w0, #1
	b quit
data_error:
	adr x0, data_error_msg
	bl printf
	mov w0, #1
	b quit
error_open:
	adr x0, open_error_msg
	bl printf
	mov w0, #1
	b quit
error_close:
	adr x0, close_error_msg
	bl printf
	mov w0, #1
	b quit
error_size:
	adr x0, size_error_msg
	bl printf
	mov w0, #1
	b quit
empty_file:
	adr x0, empty_file_msg
	bl printf
	mov w0, #1
	b quit		
	.size	main, .-main
