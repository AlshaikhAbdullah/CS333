#include "types.h"
#include "user.h"


int
main(int argc, char *argv[])
{
   int val; 
   int val2; 
   int rc; 
   if(argv[1] > 0)
      val = atoi(argv[1]); 
   if (argv[2] > 0)
      val2 = atoi(argv[2]);
   rc = setpriority(val, val2);
   if (rc == -1)
      printf(1,"INVALID PID/PRIORITY\n");
   exit();
}

