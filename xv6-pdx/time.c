#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char *argv[])
{
  int start_time = uptime(); // for ticks
  int final_time;
  int time_diff;
  int result;
  int reminder;
  int knife = fork(); // to check fork

  if (knife < 0) // knife value negative
  {
     printf(1, "error FAIL\n");
     exit();
  }

  if (knife == 0) // knife is zero
  {
     if (argc == 1) 
        exit();
     ++argv; 
     if (exec(argv[0], argv)) 
     {
        printf(1, "error FAIL\n");
        exit();
     }
  }
  wait();
  final_time = uptime(); // get time
  time_diff = final_time - start_time; // get the difference 
  result = time_diff/1000; // get the result
  reminder = time_diff%1000; // get the reminder
  
  if(argv[1] != 0)
     printf(1, "%s ran in %d.%d seconds.\n", argv[1], result, reminder); // displayin
  else
     printf(1, "ran in %d.%d seconds.\n", result, reminder); 
  exit();
}

#endif
