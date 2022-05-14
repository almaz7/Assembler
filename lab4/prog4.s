	.arch armv8-a
//A*(B-C)+A*(D-E)+F*(G+H)
	.data
mes1:
	.string	"\nMatrix:\n"
mes2:
	.string	"%lf"
mes21:
	.string "Element = %lf\n"
mes:
	.string "%d"
mes0:
	.string "n = %d\n"
mes3:
	.string	"%.5g "
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
	.string "\nSize of matrixes can not be less than 1\n"
data_error_msg:
	.string "\nData in file are in incorrect form\n"
empty_file_msg:
	.string "\nFile is empty\n"
	.text
	.align	2

	.global mul_matrix
	.type	mul_matrix, %function
mul_matrix:
	ret
	.size	mul_matrix, .-mul_matrix


	.global sum_matrix
	.type	sum_matrix, %function
sum_matrix:	
	//x3 - size, x1 - address of Matrix1, x2 - address of Matrix2 
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
	//x3 - size, x1 - address of Matrix1, x2 - address of Matrix2 
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
	
	ldrsw x3, [x29, x]
	//
	adr x0, mes0
	mov x1, x3
	bl printf
	//

	ldrsw x3, [x29, x]
	//mov x0, #0
	cmp x3, #0
	ble error_size

	//get elements of matrixes
	mov x0, x21
	adr x1, mes2
	add x2, x29, y
	bl fscanf 
	mov x1, #0xffffffff
	cmp x0, x1
	beq empty_file
	cmp x0, #0
	beq data_error	

	ldr d0, [x29, y]
	//
	adr x0, mes21
	bl printf
	//

	//closing file
	mov x0, x21
	bl fclose
	cbnz x0, error_close
	
	mov	w0, #0
quit:
	ldp	x29, x30, [sp], #32
	ret

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
