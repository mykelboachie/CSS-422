#include <stdio.h>

int main()
{
    int number = 1;
    for (int i=0; i<=10;i++){
        printf( "%d",number);
        printf("\n");
        number = number * 2;
    }
    return 0;
}