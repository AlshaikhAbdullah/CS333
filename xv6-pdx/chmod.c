#ifdef CS333_P5
#include "types.h"
#include "user.h"
#include "fs.h"
#include "stat.h"
int
atoi8(const char * s)
{
    int n, sign;

    n =0;
    while(*s == ' ') s++;
    sign = (*s == '-') ? -1 : 1;
    if(*s == '+' || *s == '-')
        s++;
    while('0' <= *s && *s <= '9')
        n = n*8 + *s++ - '0';
    return sign * n;
}

int
main(int argc, char * argv[])
{
    if(argc != 3)
    {
        printf(1,"Incorrect Arguments\n");
        exit();
    }
    chmod(argv[2], atoi8(argv[1]));
    exit();
}
#else
#include "type.h"
#include "user.h"
int
main(void)
{
  printf(1, "Not imlpemented yet.\n");
  exit();
}

#endif
