.section .data
str1: .string "%d "
str2: .string "%d\n"
stack: .space 360000
arr: .space 360000
res: .space 360000

.section .text
.globl main
.extern atoi
.extern printf

main:
    # Save registers and align stack
    addi sp, sp, -48
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)
    sd s3, 32(sp)
    sd s4, 40(sp) 

    mv s0, a0        #s0 = argc
    mv s1, a1        #s1 = argv
    
    # Command Line Arguments
    li s2, 1         #i=1 (skip exec file name)
    la s4, arr       #s4 -> arr
    li s3, 0         #offset
    
input_handle:
          bge s2, s0, init_res
          slli t1, s2, 3   # offset=8 for argv
          add t1, s1, t1
          ld a0, 0(t1)     # Load string
          
          call atoi      
          
          add t2, s4, s3
          sw a0, 0(t2)     # int(arr[i-1]) 
          
          addi s3, s3, 4   #offset+=4
          addi s2, s2, 1   #i++
          jal x0, input_handle

init_res:
          addi s0, s0, -1  # s0 = n
          li t0, 0 
          li t1, -1
          la t2, res #t2->res

res_fill:
          bge t0, s0, start #start the algorithm after filling the res array
          slli t3, t0, 2
          add t3, t3, t2
          sw t1, 0(t3)     #result[i]=-1
          addi t0, t0, 1
          jal x0, res_fill

start:
          la s1, stack     #s1->stack
          la s3, res       #s3->res
          addi s2, s0, -1  #s2=i=n-1 (Outer loop index)
          li t2, -1        #t2=stack.top

outer_loop:
          blt s2, x0, print_start
          
          slli t3, s2, 2
          add t3, t3, s4   #t3->*(arr+s2*4)
          lw t4, 0(t3)     #t4 = arr[i]

inner_loop:
          li t5, -1
          beq t2, t5, after_inner  # if stack empty, break
          
          slli t1, t2, 2
          add t1, t1, s1
          lw t6, 0(t1)     # t6 = index at stack top
          
          slli t0, t6, 2
          add t0, t0, s4
          lw t0, 0(t0)     # t0 = arr[stack.top()]

          bgt t0, t4, after_inner  # if arr[stack.top]>arr[i], break
          
          addi t2, t2, -1  # stack.pop()
          jal x0, inner_loop

after_inner:
    # If stack not empty, result[i] = stack.top()
    li t5, -1
    beq t2, t5, push_stack
    
    slli t1, t2, 2
    add t1, t1, s1
    lw t6, 0(t1)     # index of next greater
    
    slli t3, s2, 2
    add t3, t3, s3
    sw t6, 0(t3)     # res[i] = next greater index

push_stack:
    addi t2, t2, 1   # stack.push(i)
    slli t1, t2, 2
    add t1, t1, s1
    sw s2, 0(t1)
    
    addi s2, s2, -1  # Progress outer loop index i--
    jal x0, outer_loop

    # 3. Print Results
print_start:
    li s2, 0         # i = 0
    addi s0, s0, -1  # Stop at n-1 for formatted printing
    
    #Single element
    blt s0, x0, finish 
    beq s0, x0, final_print

print_loop:
    bge s2, s0, final_print
    slli t0, s2, 2
    add t0, t0, s3
    lw a1, 0(t0)
    la a0, str1
    call printf #printf("%d ",res[i]);
    
    addi s2, s2, 1
    jal x0, print_loop

final_print:
    slli t0, s2, 2
    add t0, t0, s3
    lw a1, 0(t0)
    la a0, str2      # "%d\n"
    call printf

finish:
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    ld s4, 40(sp)
    addi sp, sp, 48
    ret