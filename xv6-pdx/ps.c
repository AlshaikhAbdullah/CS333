#ifdef CS333_P2
#include "types.h"
#include "user.h"
#include "uproc.h"
#define MAX 32

int
main(void)
{
   uint max = MAX;
   int result;
   int reminder;
   struct uproc* table = malloc (max * sizeof(struct uproc)); 
   int procforeal = getprocs(max, table); 

   printf(1, "\nMAX = %d\n", max); 
#ifdef CS333_P3P4
   printf(1, "PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\n");
#else
   printf(1, "PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n"); 
#endif

   for(int i = 0; i < procforeal; ++i)
   {
      printf(1, "%d\t%s\t%d\t%d\t%d\t", table[i].pid, table[i].name, table[i].uid, table[i].gid, table[i].ppid); 
#ifdef CS333_P3P4
      printf(1,"%d\t",table[i].priority);
#endif
      result = table[i].elapsed_ticks/1000; 
      reminder = table[i].elapsed_ticks%1000; 
      printf(1, "%d.%d\t", result,reminder);
    

      result = table[i].CPU_total_ticks/1000; // find result
      reminder = table[i].CPU_total_ticks%1000; // find the reminder 

      printf(1, "%d.%d\t", result,reminder); 
    printf(1, "%s\t%d\n", table[i].state, table[i].size); // display state and size
   }
   exit();
}
#endif
