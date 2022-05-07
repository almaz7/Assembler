	.arch armv8-a
//res = (a*b*c - c*d*e)/(a/b+c/d)
	.data
	.align 3
res:
	.skip 8
ost:
	.skip 8	
a:
	.short 10
b:
	.short 113
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
	udiv w3, w2, w1
	adr x0, res
	str w3, [x0]
	//ost = w2 - w1*w3
	mul w4, w1, w3
	sub w3, w2, w4
	adr x0, ost
	str w3, [x0]  
	mov x0, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
