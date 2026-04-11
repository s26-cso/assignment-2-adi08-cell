.section .data
file: .string "input.txt"
mode: .string "r"
str1: .string "%s"
str2: .string "No\n"
str3: .string "Yes\n"

.section .text
.globl main
.extern printf
.extern scanf
.extern fopen
.extern fclose
.extern fseek
.extern ftell
.extern fgetc

main:
     addi sp, sp, -32
     sd ra, 0(sp)
     sd s0, 8(sp)
     sd s1, 16(sp)
     sd s2, 24(sp)
     
     la a0, file 
     la a1, mode
     call fopen

     mv s0, a0 #a0=fptr
     
len_:
          mv a0, s0
          li a1, 0
          li a2, 2
          call fseek #fseek(fp,0,seek_end)

          mv a0, s0
          call ftell
          mv s1, a0 #s1=length of string
          li s2, 0 #s2=i=0

loop:
     bge s2, s1, finisheq
     
     mv a0, s0
     mv a1, s2
     li a2, 0
     call fseek

     mv a0, s0
     call fgetc
     mv t0, a0 #left

     addi t2, s1, -1 #t2=len-1
     sub t2, t2, s2  #t2=len-1-i

     
     mv a0, s0
     mv a1, t2
     li a2, 0
     call fseek  #start

     mv a0, s0
     call fgetc
     mv t1, a0 #right

     bne t0, t1, finishneq
     
     addi s2, s2, 1 #i++
     jal x0, loop

finisheq:
         la a0, str3
         call printf
         
         mv a0, s0
         call fclose

         ld ra, 0(sp)
         ld s0, 8(sp)
         ld s1, 16(sp)
         ld s2, 24(sp)
         addi sp, sp, 32
         ret

finishneq:
         la a0, str2
         call printf

         mv a0, s0
         call fclose

         ld ra, 0(sp)
         ld s0, 8(sp)
         ld s1, 16(sp)
         ld s2, 24(sp)
         addi sp, sp, 32
         ret