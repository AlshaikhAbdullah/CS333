#ifdef CS333_P3P4
#include "types.h"
#include "user.h"

int
main (void)
{
   int pid;
   for (int i = 0; i < 15; ++i)
   {
      pid = fork();
      if (!pid) 
         for(;;);
   }

   if (pid)
      for (int j = 0; j < 15; ++j)
      {
         wait();
      }
 
   exit();
}

#endif
