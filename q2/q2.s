.section .data
str1: .string "%d "
str2: .string "%d\n"
stack: .space 4000
arr: .space 4000
res: .space 4000
.section .text
.globl main
.extern atoi
.extern printf

main:
     addi sp, sp, -40
     sd ra, 0(sp)
     sd s0, 8(sp)
     sd s1, 16(sp)
     sd s2, 24(sp)
     sd s3, 32(sp) #s2, s3 for printing results 
     mv s0, a0 #s0=argc
     mv s1, a1 #s1=argv
     li t0, 1 #i=1
     li t1, 0 #offset for argv
     li t3, 0 #offset for arr
     la t5, arr #calcs final address for storing
init:
     bge t0, s0, next
     add t2, s1, t1 

     ld a0, 0(t2)
     call atoi

     add t4, t5, t3 
     sw a0, 0(t4) #arr[i]=a0

     addi t3, t3, 4
     addi t0, t0, 1
     addi t1, t1, 8

     jal x0, init

next:
     li t0, 0 #i=0
     li t3, 0 #offset for res
     la t6, res #storage for address
     li t1, -1 #for storing -1

res_init:
         bge t0, s0, func
         add t5, t6, t3 #t5 calcs final address

         sw t1, 0(t5)
         addi t0, t0, 1
         addi t3, t3, 4

         jal x0, res_init

func:
     la a0, arr
     la a1, stack
     la a2, res

     addi t0, s0, -2  #i=argc-2
     li t2, -1 #stack.top

loop_out: #used: t0, t1, t2, t4 / t3, t5 can be used for intermediate calc
         blt t0, x0, end_print
         slli t3, t0, 2
         add t4, t3, a0 #t4->arr[i]

         slli t5, t2, 2
         add t1, a1, t5 #t1->stack.top()

         jal x0, loop_in #jump to inner loop

loop_out_nxt:
             addi t2, t2, 1
             slli t5, t2, 2
             add t1, a1, t5 #t1->stack.top() for insertion
             
             sw t0, 0(t1)
             addi t0, t0, -1
             jal x0, loop_out

loop_in:
        li t3, -1
        ble t2, t3, goback #if stack.top()==-1, go back
        
        lw t6, 0(t1) #t6=stack.top()
        slli t5, t6, 2
        add t6, t5, a0 #t6->arr[stack.top()]

        lw t6, 0(t6) #t1=arr[stack.top()]
        lw t5, 0(t4) #t5=arr[i]

        bgt t6, t5, goback 

        addi t2, t2, -1 #top--;

        slli t5, t2, 2
        add  t1, a1, t5 #recomputation of t1

        jal x0, loop_in

goback:
       bge t2, x0, non_emp_goback #top>=0 

       jal x0, loop_out_nxt

non_emp_goback:
               slli t5, t0, 2
               add t3, a2, t5 #t3->res[i]

               slli t5, t2, 2
               add t1, a1, t5 #t1->stack.top()
               lw t5, 0(t1) #t5=stack.top()

               sw t5, 0(t3) #res[i]=t5

               jal x0, loop_out_nxt

end_print:
          addi s3, s0, -2 #s3=argc-1
          mv s2, x0 #s2=i=0 

end_loop:
         beq s2, s3, finish
         slli t0, s2, 2 #t0=offset
         la a3, res
         addi t1, a3, t0 #t1->res[i]
         la a0, str1 #a0->"%d "
         lw t2, 0(t1)  #t2=res[i]
         mv a1, t2
         call printf
         addi s2, s2, 1
         jal x0, end_loop

finish:
       slli t0, s2, 2 #t0=offset
       la a3, res
       addi t1, a3, t0 #t1->res[i]
       lw t2, 0(t1)  #t2=res[i]
       la a0, str2 #a0->"%d "
       mv a1, t2
       call printf

       ld ra, 0(sp)
       ld s0, 8(sp)
       ld s1, 16(sp)
       ld s2, 24(sp)
       ld s3, 32(sp) 
       addi sp, sp, 40
       ret