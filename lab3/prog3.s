	.arch armv8-a
//find length of each word in string
	.data
mes1:
	.ascii "\nEnter string: "
	.equ len, .-mes1
str:
	.skip 1024
mes2:
	.ascii "Result: '"
newstr:
	.skip 1024*2
number:
	.skip 4 //4 - maximum length of number
mes_write:
	.ascii "Data successfully written in "
	.equ write_len, .-mes_write
file:
	.string "1.txt"
err_mes1:
	.ascii "Error with entering string\n"
	.equ err_len1, .-err_mes1
err_mes2:
	.ascii "Environment variable with filename is not found\n"
	.equ err_len2, .-err_mes2
err_mes3:
	.ascii "Error with opening the file\n"
	.equ err_len3, .-err_mes3
err_mes4:
	.ascii "Error with writing in file\n"
	.equ err_len4, .-err_mes4
err_mes5:
	.ascii "Error with closing the file\n"
	.equ err_len5, .-err_mes5

	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	//print "Enter string: " on screen
	mov x0, #1
	adr x1, mes1
	mov x2, len
	mov x8, #64
	svc #0

	//get string
	mov x0, #0
	adr x1, str
	mov x2, #1023
	mov x8, #63
	svc #0
	
	//check for EOF or error
	cmp x0, #0
	beq quit
	cmp x0, #0
	blt error_entering
	
	//put \0 instead of \n in the string  
	adr x1, str
	sub x0, x0, #1
	strb wzr, [x1, x0]
	
	adr x3, newstr
	mov x4, x3

0:
	//reading each symbol in string, deleting odd spaces and tabs
	ldrb w0, [x1], #1
	cbz w0, 5f
	cmp w0, ' '
	beq 0b
	cmp w0, '\t'
	beq 0b
	cmp x4, x3
	beq 1f   //first word in string
	//else
	mov w0, ' '
	strb w0, [x3], #1
1:
	sub x2, x1, #1 //address of start of word in string
2:
	ldrb w0, [x1], #1
	cbz w0, 3f
	cmp w0, ' '
	beq 3f
	cmp w0, '\t'
	beq 3f
	b 2b
3:
	sub x5, x1, #1	//address of symbol that is next after symbol of word end
	mov x1, x5
	sub x6, x5, x2 //length of word
4:
	ldrb w0, [x2], #1
	strb w0, [x3], #1
	cmp x2, x5
	blt 4b

	mov w0, ' ' //space before number
	strb w0, [x3], #1
	
	//length to string
	adr x7, number
	mov x8, x7
	//x6 - number, x10 - divider, x9 - result, x11 - remainder
	mov x10, #10
number1:
	udiv x9, x6, x10
	//x11 = x6 - x9*x10
	msub x11, x9, x10, x6
	mov w0, '0'
	add w0, w0, w11
	strb w0, [x8], #1
	mov x6, x9
	cmp x6, #0
	beq number2
	b number1
number2:
	//writing number in newstr
	ldrb w0, [x8, #-1]!
	strb w0, [x3], #1
	cmp x7, x8
	blt number2
	b 0b		

5:
	//end of rhe string
	mov w0, '\''
	strb w0, [x3], #1
	mov w0, '\n'
	strb w0, [x3], #1
	
	adr x1, mes2
	sub x20, x3, x1 //length of newstr
	
	/*mov x0, #1
	adr x1, mes2
	sub x2, x3, x1
	mov x8, #64
	svc #0*/

	//finding filename from env variables
	ldr x24, [sp] //count of argv
	add x24, x24, #2 //index of first env variable
	
7:	
	ldr x1, [sp, x24, lsl #3] //address of env variable or 0
	cmp x1, #0 //our variable with filename is not found
	beq error_env
	add x24, x24, #1

8:
	ldrb w0, [x1], #1
	cmp w0, 'F'
	bne 7b
	ldrb w0, [x1], #1
	cmp w0, '='
	bne 7b
	//in x1 - address of filename
	mov x2, x1
filename:
	ldrb w0, [x2], #1
	cbnz w0, filename
store_filename:
	mov x23, x1 //address of filename
	sub x24, x2, x1 //length of filename
9:	
	//open file
	mov x0, #-100
	//adr x1, file  //filename is in already found 
	mov x2, #1
	add x2, x2, #0x40
	add x2, x2, #0x400
	mov x3, #0600
	mov x8, #56
	svc #0
	
	cmp x0, #0
	blt error_open
	mov x21, x0 //store fd to close file after
	
	//write in file
	adr x1, mes2
	mov x2, x20
	mov x8, #64
	svc #0
	cmp x0, #0
	ble error_write

	//success message
	mov x0, #1
	adr x1, mes_write
	mov x2, write_len
	mov x8, #64
	svc #0
	mov x0, #1
	mov x1, x23
	mov x2, x24
	mov x8, #64
	svc #0
	
	//close file
	mov x0, x21
	mov x8, #57

	cmp x0, #0
	blt error_close

	b _start

error_entering:
	mov x0, #2
	adr x1, err_mes1
	mov x2, err_len1
	mov x8, #64
	svc #0
	b error_quit

error_env:
	mov x0, #2
	adr x1, err_mes2
	mov x2, err_len2
	mov x8, #64
	svc #0
	b error_quit	

error_open:
	mov x0, #2
	adr x1, err_mes3
	mov x2, err_len3
	mov x8, #64
	svc #0
	b error_quit

error_write:
	mov x0, #2
	adr x1, err_mes4
	mov x2, err_len4
	mov x8, #64
	svc #0
	b error_quit

error_close:
	mov x0, #2
	adr x1, err_mes5
	mov x2, err_len5
	mov x8, #64
	svc #0
	b error_quit

error_quit:
	mov x0, #1
	mov x8, #93
	svc #0
	
quit:
	mov x0, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
