#ifdef CS333_P5
#include "types.h"
#include "user.h"
#include "fs.h"
//#include "defs.h" // maybe
#include "stat.h"


int
main (int argc, char *argv[])
{
   if (argc != 3)
   {
      printf(1, "Incorrect Arguments\n");
      exit();
   }
   chown(argv[2], atoi(argv[1]));
   exit();
}
#else
#include "types.h"
#include "user.h"
int
main(void)
{
  printf(1, "Not imlpemented yet.\n");
  exit();
}

#endif
