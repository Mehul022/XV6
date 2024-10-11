#ifndef DATA_CHUNK_H
#define DATA_CHUNK_H
#define MAX_CHUNK_SIZE 10
#include <sys/time.h>
typedef struct data_chunk
{
    long long int seq_num;
    long long int total_chunks;
    char data[MAX_CHUNK_SIZE];
} data_chunk;

typedef struct PendingACK
{
    long long int seq_num;
    struct timeval sent_time;
    struct PendingACK *next;
} PendingACK;
#endif