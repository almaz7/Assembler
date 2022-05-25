	.arch armv8-a
//find length of each word in string
	.data
mes1:
	.ascii "\nEnter string: "
	.equ mes1_len, .-mes1

	.equ bufsize, 4
str:
	.skip bufsize+1
mes2:
	.ascii "Result: '"
	.equ mes2_len, .-mes2
newstr:
	.skip (bufsize+1)*2
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
res:
	.skip 8
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	//print "Enter string: " on screen
	mov x0, #1
	adr x1, mes1
	mov x2, mes1_len
	mov x8, #64
	svc #0

	mov x25, #0 //previous length was written
	mov x26, #0 //start of the string
	mov x27, #0 //buffer enough
	mov x28, #0 //length of word
	mov x29, #0 //first word of string is not written in file
		
get_string:
	//get string
	mov x0, #0
	adr x1, str
	mov x2, bufsize
	mov x8, #63
	svc #0
	
	//check for EOF or error
	cmp x0, #0
	beq quit
	cmp x0, #0
	blt error_entering
	
	
	adr x1, str

	cmp x27, #1
	bne checking_buffer
	cmp x28, #0
	beq checking_buffer
	//previous word was not written fully
	ldrb w5, [x1]
	cmp w5, ' '
	beq prev_length
	cmp w5, '\t'
	beq prev_length
	cmp w5, '\n'
	beq prev_length
	b checking_buffer
	
prev_length:
	adr x3, newstr
	mov x4, x3
	mov x25, #1  //show that previous length need be written
 	b writing_num
	
checking_buffer:	
	//checking buffer (enough or not)	
	sub x0, x0, #1
	ldrb w5, [x1, x0]
	cmp w5, '\n'
	beq buf_enough
	//not_enough
	strb wzr, [x1, bufsize] //put \0 in the end of string
	mov x27, #1

	cbz x25, adr_newstr
	b 0f
		
buf_enough:
	strb wzr, [x1, x0] //put \0 instead of \n in the string
	mov x27, #0
	cbz x25, adr_newstr
	b 0f	
	
adr_newstr:
	adr x3, newstr
	mov x4, x3

0:
	mov x25, #0
	//reading each symbol in string, deleting odd spaces and tabs
	ldrb w0, [x1], #1
	cbz w0, 5f
	cmp w0, ' '
	beq 0b
	cmp w0, '\t'
	beq 0b
	cmp x4, x3
	beq first_word   //first word in string
	//else
	mov w0, ' '
	strb w0, [x3], #1
	b 1f
	
first_word:
	cmp x29, #0
	beq 1f
	cmp x28, #0
	bne 1f
	
	//not start of string
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
	sub x6, x5, x2 //local length of word
	add x28, x28, x6 //global length of word
4:
	ldrb w0, [x2], #1
	strb w0, [x3], #1
	cmp x2, x5
	blt 4b

	ldrb w0, [x1]
	cbnz w0, writing_num //word is not last in the string
	//else 
	cbz x27, writing_num //last word was placed in buffer
	//else
	b 5f
	
writing_num:	
	mov w5, ' ' //space before number
	strb w5, [x3], #1
	
	//length to string
	adr x7, number
	mov x8, x7
	//x28 - number, x10 - divider, x9 - result, x11 - remainder
	mov x10, #10
number1:
	udiv x9, x28, x10
	//x11 = x28 - x9*x10
	msub x11, x9, x10, x28
	mov w5, '0'
	add w5, w5, w11
	strb w5, [x8], #1
	mov x28, x9
	cmp x28, #0
	beq number2
	b number1
number2:
	//writing number in newstr
	ldrb w5, [x8, #-1]!
	strb w5, [x3], #1
	cmp x7, x8
	blt number2
	mov x28, #0 //number is written

	cbnz x25, checking_buffer
	b 0b		

5:
	cbnz x27, not_end_string //buffer is not enough
	
	mov w0, '\''
	strb w0, [x3], #1
	mov w0, '\n'
	strb w0, [x3], #1
	
not_end_string:
	adr x1, newstr
	sub x20, x3, x1 //length of newstr

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
	//adr x1, file  //filename is already found 
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
	cbnz x26, not_start //not start of the string 
	adr x1, mes2
	mov x2, mes2_len
	mov x8, #64
	svc #0
	cmp x0, #0
	ble error_write
	mov x26, #1

not_start:
	cmp x20, #0 //length of string
	ble success
	
	mov x0, x21
	adr x1, newstr
	mov x2, x20
	mov x8, #64
	svc #0
	cmp x0, #0
	ble error_write
	mov x29, #1
	
success:
	cbnz x27, close_file
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

close_file:	
	//close file
	mov x0, x21
	mov x8, #57
	svc #0
	cmp x0, #0
	blt error_close

	cbz x27, _start 
	b get_string

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
	adr x1, res
	str x0, [x1]
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
