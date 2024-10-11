#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        fprintf(stderr, "ERROR, no IP address or port provided\n");
        exit(1);
    }

    int client_sock;
    struct sockaddr_in server_addr;
    socklen_t addrlen = sizeof(server_addr);

    client_sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (client_sock < 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(atoi(argv[2]));
    if (inet_pton(AF_INET, argv[1], &server_addr.sin_addr) <= 0)
    {
        perror("Invalid address or address not supported");
        exit(EXIT_FAILURE);
    }

    char *message = "Hello from client!";
    sendto(client_sock, message, strlen(message), 0, (struct sockaddr *)&server_addr, sizeof(server_addr));
    printf("Welcome to TIC-TAC-TOE\n");

    char buf[1024];
    while (1)
    {
        memset(buf, 0, sizeof(buf));
        ssize_t n = recvfrom(client_sock, buf, sizeof(buf), 0, (struct sockaddr *)&server_addr, &addrlen);
        if (n < 0)
        {
            perror("recvfrom failed");
            continue;
        }
        printf("%s", buf);

        if (strstr(buf, "Done"))
        {
            break;
        }

        if (strstr(buf, "Enter your move (1-3): ") || strstr(buf, "Do You want to start the game(Yes/no)") || strstr(buf, "Want to play again?(Yes/No)"))
        {
            char str[1024];
            fgets(str, sizeof(str), stdin);
            ssize_t sent_bytes = sendto(client_sock, str, strlen(str), 0, (struct sockaddr *)&server_addr, sizeof(server_addr));
            if (sent_bytes < 0)
            {
                perror("sendto failed");
            }
        }
    }

    close(client_sock);
    return 0;
}
