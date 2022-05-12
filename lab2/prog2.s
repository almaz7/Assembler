	.arch armv8-a
	//sorting columns of matrix by min elements
	.data
	.align 3
n:
	.word 6
m:
	.word 4
matrix:
	.quad 1, 3, 4, 5
	.quad 0, 5, 2, 1
	.quad -4, 7, 4, -20
	.quad 3, 6, 4, 1
	.quad 2, -10, -6, 1
	.quad -1, -2, -3, -4
new_matrix:
	.skip 192
index:     //vector of indexes
	.skip 32	 
mins:
	.skip 32
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	adr x0, n
	ldr w0, [x0]
	adr x1, m                                                                                                                                                                                                                                                                                                                                   
	ldr w1, [x1]
	adr x2, matrix
	adr x11, index
	adr x12, new_matrix 
	adr x3, mins
	mov x4, #0 //column number
0:
	//find smallest elements in column
	cmp x4, x1
	bge 3f 
	mov x5, #0 //line number
	lsl x6, x4, #3
	ldr x7, [x2, x6] //element of matrix
1:
	add x5, x5, #1
	cmp x5, x0
	bge 2f
	add x6, x6, x1, lsl #3
	ldr x8, [x2, x6] //another element of matrix
	cmp x7, x8
	ble 1b
	mov x7, x8 //x7 - smallest element in column
	b 1b
2:
	str x7, [x3, x4, lsl #3]
	str x4, [x11, x4, lsl #3] //index saving
	add x4, x4, #1
	b 0b //smallest elements in column is founded
3:
    //gnome sort
    mov x4, #1 //index of current element
4:
    cmp x4, x1
    bge 7f //quit
    cbnz x4, 5f
    mov x4, #1
5:
    sub x5, x4, #1
    ldr x7, [x3, x5, lsl #3] //previous element
    ldr x8, [x3, x4, lsl #3] //current element
    cmp x7, x8

.ifdef reverse
	blt 6f
.else
    bgt 6f
.endif

    add x4, x4, #1
    b 4b
6:
    //swap in vector of min elements and in vector of indexes
    str x8, [x3, x5, lsl #3]
    str x7, [x3, x4, lsl #3]
	ldr x7, [x11, x4, lsl #3]
	ldr x8, [x11, x5, lsl #3]
	str x8, [x11, x4, lsl #3]
	str x7, [x11, x5, lsl #3]
    sub x4, x4, #1
    b 4b
    //forming new matrix
7:
	mov x4, #0
8:	cmp x4, x1
	bge 11f
	mov x5, #0
	ldr x6, [x11, x4, lsl #3] //index of column in matrix
	add x7, x12, x4, lsl #3 //position of first column element in new_matrix
	add x8, x2, x6, lsl #3 //position of first column element in matrix
9:	
	cmp x5, x0
	bge 10f
	ldr x9, [x8]
	str x9, [x7]
	add x7, x7, x1, lsl #3
	add x8, x8, x1, lsl #3
	add x5, x5, #1
	b 9b
10:
	add x4, x4, #1
	b 8b	
11:    
	mov x0, #0
    mov x8, #93
    svc #0
    .size _start, .-_start
