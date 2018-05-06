#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "uproc.h"



#ifdef CS333_P3P4


static int 
removeFromStateList(struct proc ** sList, struct proc *p);

static int 
addToStateListEnd(struct proc ** sList, struct proc *p);

static int 
addToStateListHead(struct proc ** sList, struct proc *p,enum procstate state);

static void 
assertState(struct proc *p,enum procstate state);







void 
control_r(void);

void 
control_z(void);

void 
contorl_f(void);

void 
contorl_s(void);

int
setpriority(int pid,int priority);

int
travarse(struct proc * temp,int pid,int priority);
int
promoteSR(struct proc ** sLists);

int
promoteRunnable(struct proc ** sList);

#endif

#ifdef CS333_P3P4
struct StateLists {
    struct proc * ready[MAX+1];
    struct proc * free;
    struct proc * sleep;
    struct proc * zombie;
    struct proc * running;
    struct proc * embryo;
};
#endif
struct {
  struct spinlock lock;
  struct proc proc[NPROC];
#ifdef CS333_P3P4
  struct StateLists pLists;
  uint PromoteAtTime;
#endif
} ptable;


static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
#ifdef CS333_P3P4
  int rc;
  p = ptable.pLists.free;
  if(p)
      goto found;
  release (&ptable.lock);
  return 0;
#else
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;
#endif

found:
#ifdef CS333_P3P4
  assertState(p,UNUSED);
  rc = removeFromStateList(&ptable.pLists.free,p);
  
  if(rc == -1)
      panic("Faild To Remove");
  p->state = EMBRYO;
  rc = addToStateListHead(&ptable.pLists.embryo,p,EMBRYO);
#else
  p->state =EMBRYO;
#endif
  //p->state = EMBRYO;
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
#ifndef CS333_P3P4
    p->state = UNUSED;
    //////////////////////////////
#else
    acquire(&ptable.lock);
    removeFromStateList(&ptable.pLists.embryo,p);
    p->state = UNUSED;
    addToStateListHead(&ptable.pLists.free,p,UNUSED);
    release(&ptable.lock);
#endif

    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

#ifdef CS333_P1
  p->start_ticks = (uint)ticks;
#endif

#ifdef CS333_P2
  p->total_ticks_cpu = 0;
  p->ticks_in_cpu = 0;
#endif
  
  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

#ifdef CS333_P3P4
  for(int i =0; i<MAX+1;++i)
    ptable.pLists.ready[i] = 0;

    ptable.pLists.free = 0;
    ptable.pLists.sleep = 0;
    ptable.pLists.zombie = 0;
    ptable.pLists.running = 0;
    ptable.pLists.embryo = 0;

    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; ++p){
        p->state = UNUSED;
        assertState(p,UNUSED);
        addToStateListHead(&ptable.pLists.free,p,UNUSED);
    }
    release(&ptable.lock);
#endif

  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  //p->state = RUNNABLE;
#ifdef CS333_P2
  p->parent = p;
  p->uid = UID;
  p->gid = GID;
#endif
#ifdef CS333_P3P4
   // ptable.pLists.ready = p;
    acquire(&ptable.lock);
    assertState(p,EMBRYO);
    removeFromStateList(&ptable.pLists.embryo,p);
    p->state = RUNNABLE;
    p->priority=0;
    addToStateListEnd(&ptable.pLists.ready[p->priority],p);
    release(&ptable.lock);
#else
    p->state = RUNNABLE;
#endif
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
#ifdef CS333_P3P4
    assertState(np,EMBRYO);
    removeFromStateList(&ptable.pLists.embryo,np);
    np->state = UNUSED;
    addToStateListHead(&ptable.pLists.free,np,EMBRYO);
#else
    np->state = UNUSED;
#endif
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

#ifdef  CS333_P2
  np->uid = np->parent->uid;
  np->gid = np->parent->gid;
#endif
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
#ifdef CS333_P3P4
  assertState(np,EMBRYO);
  removeFromStateList(&ptable.pLists.embryo,np);
  np->state = RUNNABLE;
  np->priority =0;
  addToStateListEnd(&ptable.pLists.ready[np->priority],np);
#else
  np->state = RUNNABLE;
#endif
  release(&ptable.lock);
  
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}
#else
void
exit(void)
{
    struct proc * p;
    int fd;

    if(proc == initproc)
        panic("Exiting");
    for(fd =0; fd < NOFILE; fd++){
        if(proc->ofile[fd]){
            fileclose(proc->ofile[fd]);
                    proc->ofile[fd] = 0;
        }
    }

        begin_op();
        iput(proc->cwd);
        end_op();
        proc->cwd = 0;

        acquire(&ptable.lock);
        wakeup1(proc->parent);

        p = ptable.pLists.running;

        while(p){
            if(p->parent == proc){
                p->parent = initproc;
                    if(p->state == ZOMBIE)
                        wakeup1(initproc);
                }
                p = p->next;
            }
        p = ptable.pLists.sleep;
        while(p){
            if(p->parent == proc){
                p->parent = initproc;
                if(p->state == ZOMBIE)
                    wakeup1(initproc);
            }
            p = p->next;
        }

    for(int i =0;i < MAX+1; ++i)
    {
        p = ptable.pLists.ready[i];
        while(p){
            if(p->parent == proc){
                p->parent = initproc;
                if(p->state == ZOMBIE)
                    wakeup1(initproc);
            }
            p = p->next;
        }
    }

        p = ptable.pLists.zombie;
        while(p){
            if(p->parent == proc){
                p->parent = initproc;
                if(p->state == ZOMBIE)
                    wakeup1(initproc);
            }
            p = p->next;
        }
        p = ptable.pLists.embryo;
        while(p){
            if(p->parent == proc){
                p->parent = initproc;
                if(p->state == ZOMBIE)
                    wakeup1(initproc);
            }
            p = p->next;
        }

        if(removeFromStateList(&ptable.pLists.running,proc) == 0){
            proc->state = ZOMBIE;
            addToStateListHead(&ptable.pLists.zombie,proc,ZOMBIE);
        }
        else
            panic("ERROR!!]n");
        sched();
        panic("Exit Zombie");
}
#endif

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#else
int
wait(void)
{
    struct proc * p_zombie;
    struct proc * p_embryo;
    struct proc * p_ready;
    struct proc * p_running;
    struct proc * p_sleep;

    int pid, havekids;

    acquire(&ptable.lock);
    for(;;){
        havekids = 0;
        p_zombie = ptable.pLists.zombie;
        while(p_zombie){
            if(p_zombie->parent == proc){
                havekids = 1;
                assertState(p_zombie,ZOMBIE);
                int rc = removeFromStateList(&ptable.pLists.zombie,p_zombie);
                if(rc == -1)
                    panic("ERROR(Not In Zombie)");
                pid = p_zombie->pid;
                kfree(p_zombie->kstack);
                p_zombie->kstack =0;
                freevm(p_zombie->pgdir);
                p_zombie->state = UNUSED;
                addToStateListHead(&ptable.pLists.free,p_zombie,UNUSED);
                p_zombie->pid =0;
                p_zombie->parent =0;
                p_zombie->name[0] =0;
                p_zombie->killed =0;
                release(&ptable.lock);
                return pid;
            }
            p_zombie = p_zombie->next;
        }

        p_embryo = ptable.pLists.embryo;
        while(p_embryo){
            if(p_embryo->parent == proc)
                havekids =1;
            p_embryo = p_embryo->next;
        }

    for(int i =0;i< MAX+1; ++i)
    {
        p_ready = ptable.pLists.ready[i];
        while(p_ready){
            if(p_ready->parent == proc)
                havekids =1;
            p_ready = p_ready->next;
        }
    }

        p_running = ptable.pLists.running;
        while(p_running){
            if(p_running->parent == proc)
                havekids =1;
            p_running = p_running->next;
        }
        p_sleep = ptable.pLists.sleep;
        while(p_sleep){
            if(p_sleep->parent == proc)
                havekids =1;
            p_sleep = p_sleep->next;
        }

        if(!havekids || proc->killed){
            release(&ptable.lock);
            return -1;
        }
        sleep(proc,&ptable.lock);
    }

  return 0;  // placeholder
}
#endif

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
      proc = p;
      switchuvm(p);
      p->state = RUNNING;

#ifdef CS333_P2
      //to start the time
        p->ticks_in_cpu = ticks;
#endif
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      break;
        }
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }

}

#else
void
scheduler(void)
{

  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);  
    
    if(ticks >= ptable.PromoteAtTime)
    {
        for(int i=0; i <MAX+1;++i)
        {
            ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
            promoteRunnable(&ptable.pLists.ready[i]);
        }
        promoteSR(&ptable.pLists.sleep);
        promoteSR(&ptable.pLists.running);
    }

    for(int i =0;i<MAX+1;++i)
    {
        if(ptable.pLists.ready[i])
        {
            p = ptable.pLists.ready[i];
            assertState(p,RUNNABLE);
            removeFromStateList(&ptable.pLists.ready[i],p);


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
          idle = 0;  // not idle this timeslice
          proc = p;
          switchuvm(p);
          p->state = RUNNING;
          addToStateListHead(&ptable.pLists.running,p,RUNNING);
          swtch(&cpu->scheduler, proc->context);
          switchkvm();


#ifdef CS333_P2
      //to start the time
            p->ticks_in_cpu = ticks;
#endif
      // Process is done running for now.
      // It should have changed its p->state before coming back.
          proc = 0;
          break;
        }
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
        }
      }


}
#endif

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;


#ifdef CS333_P2
  //to get total running 
  proc->total_ticks_cpu += ticks - proc->ticks_in_cpu;
#endif

  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}
/*
void
sched(void)
{
  
}
*/

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
#ifdef CS333_P3P4
    assertState(proc,RUNNING);
    removeFromStateList(&ptable.pLists.running,proc);
#endif
  proc->state = RUNNABLE;
#ifdef CS333_P3P4
  int subtract = ticks - proc->ticks_in_cpu;
  proc->budget = proc->budget - subtract;
  if(proc->budget <=0)
  {
      proc->budget = BUDGET;
      if(proc->priority < MAX)
          proc->priority+=1;

      addToStateListEnd(&ptable.pLists.ready[proc->priority],proc);
  }
  else
      addToStateListEnd(&ptable.pLists.ready[proc->priority],proc);

#endif
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
    acquire(&ptable.lock);
    if (lk) release(lk);
  }
#ifdef CS333_P3P4
  assertState(proc,RUNNING);
  removeFromStateList(&ptable.pLists.running,proc);
  proc->chan = chan;
  proc->state = SLEEPING;
  addToStateListHead(&ptable.pLists.sleep,proc,SLEEPING);
  int subtract = ticks - proc->ticks_in_cpu;
  proc->budget -=subtract;
  if(proc->budget <= 0&&proc->priority < MAX)
  {
      proc->budget = BUDGET;
      proc->priority =+1;
  }
#else

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
#endif
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
    release(&ptable.lock);
    if (lk) acquire(lk);
  }
}

//PAGEBREAK!
#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{

    int rc;
    struct proc * current = ptable.pLists.sleep;
    struct proc * hold;
    while(current){
        if(current->chan == chan && current ->state ==SLEEPING){
            assertState(current,SLEEPING);
            hold = current->next;

            rc = removeFromStateList(&ptable.pLists.sleep,current);
            if(rc == -1)
                panic ("Wake Up 1\n");
            current ->state = RUNNABLE;
            addToStateListEnd(&ptable.pLists.ready[current->priority],current);
            current = hold;
        }
        else
            current = current->next;
    }
    
}
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
#else

int
kill(int pid)
{
    struct proc * temp_sleep;
    struct proc * temp_ready;
    struct proc * temp_embryo;
    struct proc * temp_running;
    struct proc * temp_zombie;

    int rc;
    //int success =0;
    acquire(&ptable.lock);
    temp_sleep = ptable.pLists.sleep;
    while(temp_sleep){
        if(temp_sleep->pid ==pid){
            temp_sleep->killed = 1;
            if(temp_sleep->state == SLEEPING){
                assertState(temp_sleep,SLEEPING);
                rc = removeFromStateList(&ptable.pLists.sleep,temp_sleep);
                if(rc == -1)
                    panic ("Kill\n");
                temp_sleep->state = RUNNABLE;
                temp_sleep->priority =0;
                addToStateListEnd(&ptable.pLists.ready[temp_sleep->priority],temp_sleep);
                release(&ptable.lock);
                return 0;
            }
        }
        temp_sleep = temp_sleep->next;
    }
    //temp_ready= ptable.pLists.ready;
    temp_embryo = ptable.pLists.embryo;
    temp_running = ptable.pLists.running;
    temp_zombie = ptable.pLists.zombie;
    
for(int i =0; i<MAX+1;++i)
{
    temp_ready = ptable.pLists.ready[i];
    while(temp_ready){
        if(temp_ready->pid == pid){
            temp_ready->killed =1;
            release(&ptable.lock);
            return -1;
        }
        temp_ready = temp_ready->next;
    }
}
    while(temp_embryo){
        if(temp_embryo->pid == pid){
            temp_embryo->killed =1;
             release(&ptable.lock);
            return -1;
        }
        temp_embryo = temp_embryo->next;
    }
    while(temp_running){
        if(temp_running->pid == pid){
            temp_running->killed = 1;
            release(&ptable.lock);
            return -1;
        }
        temp_running = temp_running->next;
    }
    while(temp_zombie){
        if(temp_zombie->pid == pid){
            temp_zombie->killed = 1;
            release(&ptable.lock);
            return -1;
        }
        temp_zombie = temp_zombie->next;
    }
    release(&ptable.lock);
    return -1;
}
#endif

static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
};

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  #ifdef CS333_P1
  uint result_cpu;
  uint reminder_cpu;
  uint result;
  uint reminder;
  #endif

    #ifdef CS333_P3P4
        cprintf("PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSIZE\tPCs\n");
    #elif CS333_P2
        cprintf("PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSIZE\tPCs\n");
    #elif CS333_P1
        cprintf("PID\tState\tName\tElapsed\tPCs\n");
    #endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    #ifdef CS333_P2
        result = (ticks - p->start_ticks)/1000;
        reminder = (ticks - p->start_ticks)%1000;
        cprintf("%d\t%s%d\t%d\t%d\t", p->pid,p->name,p->uid,p->gid,p->parent->pid);    
#ifdef CS333_P3P4
        cprintf("%d\t",p->priority);
#endif
        cprintf("%d.%d\t",result,reminder);
    #elif CS333_P1
        result = (ticks - p->start_ticks)/1000;
        reminder = (ticks - p->start_ticks)%1000;
        cprintf("%d\t%s\t%s\t%d.%d\t", p->pid,state, p->name,result,reminder);
    #else 
        cprintf("%d\t%s\t%s", p->pid,state, p->name);
    #endif
#ifdef CS333_P2
        result_cpu= p->total_ticks_cpu/1000;
        reminder_cpu = p->total_ticks_cpu%1000;
        cprintf("%d.%d\t",result_cpu,reminder_cpu);
        cprintf("%s\t%d", state, p->sz);
#endif
        
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

#ifdef CS333_P2
int
getprocs(uint max, struct uproc* table) {
    int count =0;
    acquire(&ptable.lock);
    
    for(int i =0; i < NPROC && count  < max; ++i){
        if(ptable.proc[i].state == RUNNABLE || ptable.proc[i].state == RUNNING || ptable.proc[i].state == SLEEPING){
            table[count].pid = ptable.proc[i].pid;
            table[count].uid = ptable.proc[i].uid;
            table[count].gid = ptable.proc[i].gid;
            if(ptable.proc[i].parent == 0)
                table[count].ppid = ptable.proc[i].pid;
            else // get the parent to ppid 
                table[count].ppid = ptable.proc[i].parent->pid;

            table[count].elapsed_ticks = ticks - ptable.proc[i].start_ticks;
            table[count].CPU_total_ticks = ptable.proc[i].total_ticks_cpu;
            safestrcpy(table[count].state,states[ptable.proc[i].state],sizeof(table[count].state));
            table[count].size = ptable.proc[i].sz;
            safestrcpy(table[count].name,ptable.proc[i].name, sizeof(table[count].name));

#ifdef CS333_P3P4
            table[count].priority = ptable.proc[i].priority;
#endif
            count += 1;

        }
    }
    release(&ptable.lock);
    return count;
}
#endif
            
#ifdef CS333_P3P4
static void
assertState(struct proc *p,enum procstate state)
{
    if(p->state != state){
        cprintf("currently at %s, need to be in %s\n",states[p->state],states[state]);
        panic("There's No Match");
    }
    else
        return;
}


static int
addToStateListHead(struct proc ** sList,struct proc *p,enum procstate state){
    assertState(p,state);
    p->next = *sList;
    *sList =p;
    return 0;
}

static int
addToStateListEnd(struct proc ** sList,struct proc *p)
{
    struct proc * temp = *sList;
    if(*sList ==0)
        return addToStateListHead(sList,p,p->state);
    while(temp->next !=0)
        temp = temp->next;
    temp->next = p;
    p->next = 0;
    return 0;
}



static int
removeFromStateList(struct proc ** sList,struct proc *p)
{
    if(p == 0)
        return -1;
    if(*sList == 0)
        return -1;
    if(*sList){
        struct proc * temp = *sList;
        if(p==temp){
            *sList = temp->next;
            p->next = 0;
            return 0;
        }
    }
    struct proc * current = *sList;
    while(current->next){
        if(current->next ==p){
            current->next=current->next->next;
            p->next = 0;
            return 0;
        }
        current = current->next;
    }
    return -1;
}


void
control_r(void)
{
   cprintf("Ready List Processes:\n");
   for(int i =0; i<MAX+1;++i)
   {
       struct proc * temp = ptable.pLists.ready[i];
       cprintf("%d: " ,i);
       if (temp == 0)
       {
          cprintf("Nothing Here!!!\n");
       }
       while (temp != 0)
       {
          if(temp -> next == 0) 
             cprintf("(%d, %d)\n", temp -> pid,temp->budget);
          else{
             cprintf("(%d, %d)->", temp -> pid,temp->budget);
          }
          temp = temp->next;
       }
   }
   return;
}

void
control_f(void) 
{
   struct proc * temp = ptable.pLists.free;
   int count = 1; 
   cprintf("Free List Size: ");
   if (temp == 0) 
   {
      cprintf(" 0 processes\n");
      return;
   }
   while (temp -> next != 0)
   {
      count += 1;
      temp = temp->next;
   }
   cprintf(" %d processes\n", count);
   return;
}

void
control_s(void) 
{
   struct proc * temp = ptable.pLists.sleep;
   cprintf("Sleep List Processes:\n");
   if (temp == 0)
   {
      cprintf("Nothing Here!!!\n");
      return;
   }
   while (temp != 0)
   {
      if(temp -> next == 0)
         cprintf("%d\n", temp -> pid);
      else
         cprintf("%d -> ", temp -> pid);
      temp = temp->next;
   }
   return;
}


void
control_z(void) 
{
   struct proc * temp = ptable.pLists.zombie;
   cprintf("Zombie List Processes:\n");
   if (temp == 0){
      cprintf("Nothing Here!!!\n");
      return;
   }
   while (temp != 0){
      if(temp -> next == 0)
         cprintf("(%d, %d)\n", temp -> pid, temp -> parent -> pid); 
      else
         cprintf("(%d, %d)->", temp -> pid, temp -> parent -> pid);
      temp = temp->next;
   }
   return;
}
#endif

#ifdef CS333_P3P4

int
travarse(struct proc * temp,int pid,int priority)
{
 while(temp!=0)
    {
        if(temp->pid == pid)
        {
            temp->budget = BUDGET;
            temp->priority = priority;
            release(&ptable.lock);
            return 0;
        }
        temp = temp->next;
    }
   return 1; 
}
int
setpriority(int pid, int priority)
{
    struct proc * temp;
    if(pid > NPROC || pid < 0)
        return -1;
    if(priority < 0 || priority > MAX)
        return -1;
    acquire(&ptable.lock);
    for(int i = 0; i < MAX+1; ++i)
    {
        temp = ptable.pLists.ready[i];
        while(temp !=0)
        {
            if(temp->pid == pid)
            {
                removeFromStateList(&ptable.pLists.ready[i],temp);
                temp->budget = BUDGET;
                temp->priority = priority;
                addToStateListEnd(&ptable.pLists.ready[temp->priority],temp);
                release(&ptable.lock);
                return 0;
            }
            temp = temp->next;
        }
    }
    temp = ptable.pLists.running;
    if(travarse(temp,pid,priority) == 0)
        return 0;
    temp = ptable.pLists.sleep;
    if(travarse(temp,pid,priority) == 0)
        return 0;
   
    release(&ptable.lock);
    return 0;
}


int
promoteRunnable(struct proc ** sList)
{
   struct proc * temp;
   temp = *sList;
   if (temp == 0) 
      return -1;
 //  cprintf("TESTING");
   if (temp->priority == 0)
      return 0;
   while (temp)
   {
      removeFromStateList(sList,temp);
      if(temp)
      {
         temp->priority -=1;
         addToStateListEnd(&ptable.pLists.ready[temp->priority],temp);
      }
      temp = temp->next;
   }
   return 0;
}  

int
promoteSR(struct proc ** sList)
{
   struct proc * temp;
   temp = *sList;
   if (*sList == 0) 
      return -1;
   while (temp)
   {
      if (temp->priority > 0)
         temp->priority -= 1;
      temp = temp->next;
   }
   return 0;
}
#endif
