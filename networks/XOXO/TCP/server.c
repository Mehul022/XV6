#include "header.h"

void sigchld_handler(int s)
{
    while (waitpid(-1, NULL, WNOHANG) > 0)
        ;
}
int main(int argc, char *argv[])
{
    struct sigaction action;
    action.sa_handler = sigchld_handler;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_RESTART;
    if (sigaction(SIGCHLD, &action, NULL) == -1)
    {
        perror("sigaction");
        exit(1);
    }
    if (argc < 2)
    {
        printf("No port provided\n");
        exit(1);
    }
    int server_fd, new_socket1, new_socket2, valread;
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);
    char buffer[1024] = {0};
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0)// sock_stream specifies its a tcp as contineous packets!!; AF_net specifies its a ipv4 
    {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt)))// 3 argument confirs that multiple listen request are accepted!;
    {
        perror("setsockopt failed");
        exit(EXIT_FAILURE);
    }
    address.sin_family = AF_INET;// setting address type in this case its ipv4
    address.sin_addr.s_addr = INADDR_ANY; // accept any ip address request
    address.sin_port = htons(atoi(argv[1]));
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0)
    {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }
    listen(server_fd, 100);
    printf("Welcome to Server of the TIC-TAC-TOE Game!!\n");
    while (1)
    {
        if ((new_socket1 = accept(server_fd, (struct sockaddr *)&address, (socklen_t *)&addrlen)) < 0)
        {
            perror("accept failed for Player 1");
            close(new_socket1);
            continue;
        }
        printf("Player 1 has connected\n");
        if ((new_socket2 = accept(server_fd, (struct sockaddr *)&address, (socklen_t *)&addrlen)) < 0)
        {
            perror("accept failed for Player 2");
            close(new_socket2);
            continue;
        }
        printf("Player 2 has connected\n");
        int pid = fork();
        if (pid < 0)
        {
            perror("fork failed");
            exit(EXIT_FAILURE);
        }
        else if (pid == 0)
        {
            close(server_fd);
            int flag1 = 0, flag2 = 0;
            
            while (!flag1 || !flag2)
            {
                if (!flag1)
                {
                    snprintf(buffer, sizeof(buffer), "Do You want to start the game(Yes/no)");
                    send(new_socket1, buffer, strlen(buffer), 0);
                    recv(new_socket1, buffer, sizeof(buffer), 0);
                    char input[1024];
                    sscanf(buffer, "%s", input);
                    if(strstr(input,"yes") || strstr(input,"Yes"))
                    {
                        flag1=1;
                    }
                }
                if (!flag2)
                {
                    snprintf(buffer, sizeof(buffer), "Do You want to start the game(Yes/no)");
                    send(new_socket2, buffer, strlen(buffer), 0);
                    recv(new_socket2, buffer, sizeof(buffer), 0);
                    char input[1024];
                    sscanf(buffer, "%s", input);
                    if (strstr(input, "yes") || strstr(input, "Yes"))
                    {
                        flag2 = 1;
                    }
                }
            }
            handle_client(new_socket1, new_socket2);
            close(new_socket1);
            close(new_socket2);
            exit(0);
        }
        else if (pid > 0)
        {
            close(new_socket1);
            close(new_socket2);
        }
    }
    close(server_fd);
}