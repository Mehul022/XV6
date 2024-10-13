#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void cpu_bound()
{
    volatile int i;
    
    // printf("CPU-bound process started: PID %d\n", getpid());
    for (i = 0; i < 3000000000; i++)
        ; // Busy wait (CPU-bound)
    // printf("CPU-bound process finished: PID %d\n", getpid());
}
void cpu_bound2()
{
    volatile int i;

    // printf("CPU-bound process started: PID %d\n", getpid());
    for (i = 0; i < 1500000000; i++)
        ; // Busy wait (CPU-bound)
    // printf("CPU-bound process finished: PID %d\n", getpid());
}

void io_bound()
{
    // printf("I/O-bound process started: PID %d\n", getpid());
    for (int i = 0; i < 2; i++)
    {
        sleep(100); // Simulate I/O wait
    }
    // printf("I/O-bound process finished: PID %d\n", getpid());
}

int main(int argc, char *argv[])
{
    int pid;
    // for (int i = 0; i < 2; i++)
    // { // 3 CPU-bound processes
        pid = fork();
        if (pid == 0)
        {
            cpu_bound();
            exit(0);
        }
        pid = fork();
        if (pid == 0)
        {
            cpu_bound2();
            exit(0);
        }
    // }
    for (int i = 0; i < 2; i++)
    { // 2 I/O-bound processes
        pid = fork();
        if (pid == 0)
        {
            io_bound();
            exit(0);
        }
    }
    pid=fork();
    for (int i = 0; i < 4; i++)
    { // Wait for child processes
        wait(0);
    }
    exit(0);
}
