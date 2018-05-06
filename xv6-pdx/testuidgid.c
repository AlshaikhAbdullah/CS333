#ifdef  CS333_P2
#include "types.h"
#include "user.h"
int
testuidgid(uint val1, uint val2){

    uint uid, gid, ppid;

    uid = getuid();
    printf(2,"Current UID is: %d\n",uid);
    printf(2,"Setting UID to %d\n", val1);
   
    if(!setuid(val1))
        printf(2,"UID is Valid\n");
    else
        printf(2,"UID is not valid\n");
    uid = getuid();
    printf(2,"Current UID is: %d\n",uid);

    gid = getgid();
    printf(2,"Current GID is: %d\n",gid);
    printf(2,"Setting GID to %d\n",val2);

    if(!setgid(val2))
        printf(2,"GID is valid\n");
    else
        printf(2,"GID is not valid\n");
    gid = getgid();
    printf(2,"Current GID is: %d\n",gid);

    ppid = getppid();
    printf(2,"My parent process is: %d\n", ppid);
    printf(2,"DONE\n");
    return 0;
}
 
int
main(int argc, char * argv[]) {

    int value1, value2;
    if(argc> 1){
        value1 = atoi(argv[1]);
        value2 = atoi(argv[2]);
    }
    testuidgid(value1, value2);
    exit();
}
#endif
   
