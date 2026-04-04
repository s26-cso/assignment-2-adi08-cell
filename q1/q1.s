.section .text
.extern malloc
.globl make_node
.globl insert
.globl get
.globl getAtMost

#creation of node
make_node:
          addi sp, sp, -16
          sd ra, 0(sp)
          sd s0, 8(sp)
 
          add s0, x0, a0 #storing a0 for val
          add a0, x0, 24 #storing size of struct in a0 for malloc
          call malloc

          sw s0, 0(a0) #val=s0
          sd x0, 8(a0) #left=null
          sd x0, 16(a0) #right=null

          ld ra, 0(sp)
          ld s0, 8(sp)
          addi sp, sp, 16
          ret

#insertion of a node into bst
insert:
       addi sp, sp, -24
       sd ra, 0(sp)
       sd s0, 8(sp)
       sd s1, 16(sp)

       beq a0, x0, insert_base_case #root==NULL
       mv s0, x0 #s0=parent of root. Setting it to null
       mv s1, a0 #s1=root
       mv t1, x0 #For offset from s0 after reaching non_zero
while1:
      beq a0, x0, insert_nonzero #if root=null
      mv s0, a0
             
      lw t0, 0(a0) #t0=root->val
             
      blt a1, t0, insert_go_left
      bge a1, t0, insert_go_right

 #if root==null
insert_base_case:
                 mv a0, a1
                 jal ra, make_node
                 
                 ld ra, 0(sp)
                 ld s0, 8(sp)
                 ld s1, 16(sp)
                 addi sp, sp, 24
                 ret

insert_nonzero:
               mv a0, a1
               jal ra, make_node
               add t2, s0, t1
               sd a0, 0(t2)

               add a0, s1, x0 #restoring root
               ld ra, 0(sp)
               ld s0, 8(sp)
               ld s1, 16(sp)
               addi sp, sp, 24
               ret

insert_go_left:
               ld a0, 8(a0) #a0=a0->left
               addi t1, x0, 8 #Offset 8 for ->left
               jal x0, while1

insert_go_right:
                ld a0, 16(a0) #a0=a0->right
                addi t1, x0, 16 #Offset 16 for ->right
                jal x0, while1

#getting a value
get:
    addi sp, sp, -8
    sd ra, 0(sp)

    beq a0, x0, get_base_case #root==NULL

while2:
       beq a0, x0, get_base_case #root==NULL
       lw t1, 0(a0) #t1=root->val
       beq t1, a1, get_base_case #if root->val==val
             
       blt a1, t1, get_go_left
       bgt a1, t1, get_go_right

 #if root==null
get_base_case:
              ld ra, 0(sp)
              addi sp, sp, 8
              ret

get_go_left:
            ld a0, 8(a0) #a0=a0->left
            jal x0, while2

get_go_right:
            ld a0, 16(a0) #a0=a0->right
            jal x0, while2
               
#getting a value which is <=req val
getAtMost: #a0->val, a1->root
    addi sp, sp, -8
    sd ra, 0(sp)

    li t0, -1 #Default -1. Will change if we get some value <=val
while3:
       beq a1, x0, getAtMost_base_case #root==NULL
       lw t1, 0(a1) #t1=root->val
             
       blt a0, t1, getAtMost_go_left
       bge a0, t1, getAtMost_go_right

 #if root==null
getAtMost_base_case:
                    mv a0, t0
                    ld ra, 0(sp)
                    addi sp, sp, 8
                    ret

getAtMost_go_left:
                  ld a1, 8(a1) #a1=a1->left
                  jal x0, while3

getAtMost_go_right:
                   mv t0, t1
                   ld a1, 16(a1) #a1=a1->right
                   jal x0, while3