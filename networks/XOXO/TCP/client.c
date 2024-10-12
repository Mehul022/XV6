#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

void error(const char *msg)
{
    perror(msg);
    exit(0);
}

int main(int argc, char *argv[])
{
    // Check if the required arguments are provided
    if (argc < 3)
    {
        fprintf(stderr, "ERROR, no IP address or port provided\n");
        exit(1);
    }

    int client_sock1;
    struct sockaddr_in serv_addr;

    // Creating a socket
    client_sock1 = socket(AF_INET, SOCK_STREAM, 0); // creating a socket of TCP type and IPv4 protocol
    if (client_sock1 < 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    // Defining server address
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(atoi(argv[2])); // Use port from command line argument

    // Convert IP address from text to binary
    if (inet_pton(AF_INET, argv[1], &serv_addr.sin_addr) <= 0) // Use IP address from command line argument
    {
        perror("Invalid address or address not supported");
        exit(EXIT_FAILURE);
    }

    // Connecting to the server
    while (1)
    {
        if (connect(client_sock1, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
        {
            perror("Connection failed");
            return 0;
        }
        else
        {
            printf("Connected to server at %s:%s\n", argv[1], argv[2]);
            break;
        }
    }

    printf("Welcome to TIC-TAC-TOE\n");
    char buf[1024];
    while (1)
    {
        memset(buf, '\0', sizeof(buf)); // Clear the buffer
        recv(client_sock1, buf, sizeof(buf), 0);
        printf("%s", buf);
        if (strstr(buf, "Done"))
            break;

        if (strstr(buf, "Enter your move (1-3): ") || strstr(buf, "Do You want to start the game(Yes/no)") || strstr(buf, "Want to play again?(Yes/No)"))
        {
            char str[1024];
            fgets(str, sizeof(str), stdin);
            send(client_sock1, str, strlen(str), 0);
        }
    }

    close(client_sock1);
    return 0;
}
