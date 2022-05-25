	.arch armv8-a
	.text
	.align 2

	.type max, %function
max:
	//w10, w11, w12
	cmp w10, w11
	bgt 0f
	b 1f
0:
	mov w13, w10
	b 2f
1:
	mov w13, w11
2:
	cmp w12, w13
	bgt 3f
	b 4f
3:
	mov w13, w12
4:
	mov w10, w13
	ret
	.size max, .-max


	.type min, %function
min:
	//w10, w11, w12
	cmp w10, w11
	blt 0f
	b 1f
0:
	mov w13, w10
	b 2f
1:
	mov w13, w11
2:
	cmp w12, w13
	blt 3f
	b 4f
3:
	mov w13, w12
4:
	mov w10, w13
	ret
	.size min, .-min	

	
	.global make_grey_asm
	.type make_grey_asm, %function
make_grey_asm:
	//x0 - x(width), x1 - y(height), x2 - channels, x3 - data
	stp x29, x30, [sp, #-16]! //save return address
	cmp x2, #3
	bne 4f
	// i - lines, j - columns
	mov x5, #-1 //i
	 
0:
	add x5, x5, #1
	cmp x5, x1
	bge 5f
	mov x6, #0 //j
	mul x7, x5, x0
	mul x7, x7, x2 
	add x7, x3, x7 //position of first pixel in data
1:
	cmp x6, x0
	bge 0b
	ldrb w10, [x7] //R
	ldrb w11, [x7, #1] //G
	ldrb w12, [x7, #2] //B
	bl min
	mov w15, w10 //min_elem
	ldrb w10, [x7] //R
	ldrb w11, [x7, #1] //G
	ldrb w12, [x7, #2] //B
	bl max
	mov w16, w10 //max_elem
	add w15, w15, w16
	mov w16, #2
	udiv w15, w15, w16 //(max+min)/2
	strb w15, [x7]
	strb w15, [x7, #1]
	strb w15, [x7, #2]
	add x7, x7, #3
	add x6, x6, #1
	b 1b
	
4:
	mov x0, #1
	b 6f	
5:
	mov x0, #0
6:
	ldp x29, x30, [sp], #16
	ret
	.size make_grey_asm, .-make_grey_asm

