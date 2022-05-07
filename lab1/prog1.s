	.arch armv8-a
//res = (a*b*c - c*d*e)/(a/b+c/d)
	.data
	.align 3
res:
	.skip 8
a:
	.short 10
b:
	.short 5
c:
	.short 9
d:
	.short 3
e:
	.short 5
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	adr x0, a
	ldrsh w1, [x0]
	adr x0, b
	ldrsh w2, [x0]
	adr x0, c
	ldrsh w3, [x0]
	adr x0, d
	ldrsh w4, [x0]
	adr x0, e
	ldrsh w5, [x0]
	mul w6, w1, w2
	smull x6, w6, w3
	mul w7, w3, w4
	smull x7, w7, w5
	sub x6, x6, x7
	sdiv w7, w1, w2
	sdiv w8, w3, w4
	add w7, w7, w8

	//mov w7, #0
	cbz w7, L0
	
	sxtw x7, w7
	sdiv x6, x6, x7
	adr x0, res
	str x6, [x0]
	mov x0, #0
	mov x8, #93
	svc #0

L0:
	mov x0, #1
	mov x8, #93
	svc #0
	.size _start, .-_start
