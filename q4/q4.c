#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dlfcn.h>

int main()
{
    while(1)
    {
        char op[10];
        char libr[20];
        strcpy(libr,"lib");
        int a,b;
        if(scanf("%s %d %d",op,&a,&b)==3)
        {
            strcat(libr,op);
            strcat(libr,".so");

            void* lptr=dlopen(libr,RTLD_LAZY);

            int (*fun)(int, int);
            *(void **)(&fun)=dlsym(lptr,op);
            printf("%d\n",fun(a,b));

            dlclose(lptr);
        }
        else break;
    }
}