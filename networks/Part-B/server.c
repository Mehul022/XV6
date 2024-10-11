#include "struct.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/time.h>
#include <fcntl.h>
#define TIMEOUT 0.1
#define MAX_CHUNK_SIZE 10
char **received_data;
PendingACK *pending_acks = NULL;

double get_current_time()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + (tv.tv_usec / 1000000.0);
}

void add_to_pending_acks(long long int seq_num)
{
    PendingACK *new_ack = (PendingACK *)malloc(sizeof(PendingACK));
    new_ack->seq_num = seq_num;
    gettimeofday(&new_ack->sent_time, NULL);
    new_ack->next = pending_acks;
    pending_acks = new_ack;
}

void remove_from_pending_acks(long long int seq_num)
{
    PendingACK *current = pending_acks;
    PendingACK *previous = NULL;
    while (current != NULL)
    {
        if (current->seq_num == seq_num)
        {
            if (previous == NULL)
            {
                pending_acks = current->next;
            }
            else
            {
                previous->next = current->next;
            }
            free(current);
            return;
        }
        previous = current;
        current = current->next;
    }
}

void send_data(int sockfd, char *data, struct sockaddr_in *client)
{
    int total_length = strlen(data);
    int total_chunks = (total_length + MAX_CHUNK_SIZE - 1) / (MAX_CHUNK_SIZE - 1);
    data_chunk chunk;
    int flags = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

    for (long long int seq = 0; seq < total_chunks; seq++)
    {
        chunk.seq_num = seq;
        strncpy(chunk.data, data + seq * (MAX_CHUNK_SIZE - 1), (MAX_CHUNK_SIZE - 1));
        chunk.data[MAX_CHUNK_SIZE - 1] = '\0';
        chunk.total_chunks = total_chunks;
        sendto(sockfd, &chunk, sizeof(chunk), 0, (struct sockaddr *)client, sizeof(*client));
        add_to_pending_acks(seq);

        char ack[256];
        int ack_len = recvfrom(sockfd, ack, sizeof(ack), 0, NULL, NULL);
        if (ack_len > 0)
        {
            long long int ack_seq = atoll(ack);
            printf("Received ACK for chunk %lld\n", ack_seq);
            remove_from_pending_acks(ack_seq);
        }

        // Handle timeouts and retransmissions
        PendingACK *current = pending_acks;
        while (current != NULL)
        {
            double current_time = get_current_time();
            double sent_time = current->sent_time.tv_sec + (current->sent_time.tv_usec / 1000000.0);
            if (current_time - sent_time > TIMEOUT)
            {
                printf("Resending chunk %lld\n", current->seq_num);
                data_chunk resend_chunk;
                resend_chunk.seq_num = current->seq_num;
                resend_chunk.total_chunks = total_chunks;
                strncpy(resend_chunk.data, data + current->seq_num * (MAX_CHUNK_SIZE - 1), MAX_CHUNK_SIZE - 1);
                resend_chunk.data[MAX_CHUNK_SIZE - 1] = '\0';
                sendto(sockfd, &resend_chunk, sizeof(resend_chunk), 0, (struct sockaddr *)client, sizeof(*client));
                gettimeofday(&current->sent_time, NULL);
            }
            current = current->next;
        }
    }

    // Wait for remaining ACKs
    while (pending_acks != NULL)
    {
        PendingACK *current = pending_acks;
        while (current != NULL)
        {
            char ack[256];
            int ack_len = recvfrom(sockfd, ack, sizeof(ack), 0, NULL, NULL);
            if (ack_len > 0)
            {
                long long int ack_seq = atoll(ack);
                printf("Received ACK for chunk %lld\n", ack_seq);
                remove_from_pending_acks(ack_seq);
            }
            else
            {
                double current_time = get_current_time();
                double sent_time = current->sent_time.tv_sec + (current->sent_time.tv_usec / 1000000.0);
                if (current_time - sent_time > TIMEOUT)
                {
                    printf("Resending chunk %lld\n", current->seq_num);
                    data_chunk resend_chunk;
                    resend_chunk.seq_num = current->seq_num;
                    resend_chunk.total_chunks = total_chunks;
                    strncpy(resend_chunk.data, data + current->seq_num * (MAX_CHUNK_SIZE - 1), MAX_CHUNK_SIZE - 1);
                    resend_chunk.data[MAX_CHUNK_SIZE - 1] = '\0';
                    sendto(sockfd, &resend_chunk, sizeof(resend_chunk), 0, (struct sockaddr *)client, sizeof(*client));
                    gettimeofday(&current->sent_time, NULL);
                }
            }
            current = current->next;
        }
    }
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("No port provided\n");
        exit(1);
    }

    int server_fd;
    struct sockaddr_in client, server_addr;
    int opt = 1;

    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_DGRAM, 0)) == 0)
    {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // Configure server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY; // Listen on any interface
    server_addr.sin_port = htons(atoi(argv[1]));

    // Bind socket
    if (bind(server_fd, (const struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
    {
        perror("bind failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    char random_data[] = "Hello, World! This is a random array of characters for testing.";
    char buffer[1024];

    // Receive first message to identify client
    while (1)
    {
        socklen_t client_len = sizeof(client);
        int n = recvfrom(server_fd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client, &client_len);
        if (n >= 0)
        {
            printf("Received message from client: %s\n", buffer);
            break;
        }
    }

    // Send data to the identified client
    send_data(server_fd, random_data, &client);

    // Prepare to receive additional chunks
    data_chunk chunk;
    chunk.seq_num = -1;
    sendto(server_fd, &chunk, sizeof(chunk), 0, (struct sockaddr *)&client, sizeof(client));

    int count = 0;
    int flag = 0;
    int array_size = 10;
    received_data = malloc(array_size * sizeof(char *));
    if (!received_data)
    {
        perror("malloc failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    while (1)
    {
        int n = recvfrom(server_fd, &chunk, sizeof(chunk), 0, (struct sockaddr *)&client, &(socklen_t){sizeof(client)});
        if (n < 0)
        {
            continue;
        }
        if (chunk.seq_num == -1)
        {
            break;
        }
        if (chunk.seq_num >= array_size)
        {
            array_size *= 2;
            received_data = realloc(received_data, array_size * sizeof(char *));
            if (!received_data)
            {
                perror("realloc failed");
                close(server_fd);
                exit(EXIT_FAILURE);
            }
        }
        received_data[chunk.seq_num] = strdup(chunk.data);
        count++;
        printf("Received chunk %lld: %s\n", chunk.seq_num, chunk.data);
        if (flag)
        {
            char ack[256];
            sprintf(ack, "%lld", chunk.seq_num);
            sendto(server_fd, ack, sizeof(ack), 0, (struct sockaddr *)&client, sizeof(client));
            flag = 0;
        }
        else
        {
            flag = 1;
        }
    }

    printf("Received Data in Order:\n");
    for (int i = 0; i < count && received_data[i] != NULL; i++)
    {
        printf("%s", received_data[i]);
        free(received_data[i]);
    }
    free(received_data);
    printf("\n");
    close(server_fd);
    return 0;
}
