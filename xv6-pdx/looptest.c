#include "types.h"
#include "user.h"


int
main(void)
{
   int pid = fork();
   if (pid == 0)
      while (1);
   exit ();
}

