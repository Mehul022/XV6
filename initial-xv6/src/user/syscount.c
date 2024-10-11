// user/syscount.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

char *syscall_names[] = {
    "fork", "exit", "wait", "pipe", "read", "kill", "exec", "fstat",
    "chdir", "dup", "getpid", "sbrk", "sleep", "uptime", "open",
    "write", "mknod", "unlink", "link", "mkdir", "close", "waitx",
    "getSysCount"};

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        fprintf(2, "Usage: syscount <mask> command [args]\n");
        exit(1);
    }
    int mask = atoi(argv[1]);
    if (mask <= 0 || (mask & (mask - 1)) != 0)
    {
        printf("Invalid mask!!\n");
        return 0;
    }
    int syscall_index = -1;
    while (mask > 1)
    {
        mask >>= 1;
        syscall_index++;
    }
    if (syscall_index < 0 || syscall_index >= 23)
    {
        printf("Invalid mask!!\n");
        return 0;
    }
    int p = fork();
    if (p < 0)
    {
        printf("fork");
        return -1;
    }
    else if (p == 0)
    {
        exec(argv[2], argv + 2);
        printf("Exec failed");
        exit(1);
    }
    else
    {
        wait(0);
        printf("PID %d called %s %d times.\n", p, syscall_names[syscall_index], getSysCount(syscall_index + 1));
    }
    return 0;
}