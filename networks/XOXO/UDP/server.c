#include "header.h"

char board[3][3];

void updated_board_sent(int client_socket, struct sockaddr_in *client_addr)
{
    char board_str[BUFFER_SIZE];
    snprintf(board_str, sizeof(board_str),
             "\n %c | %c | %c \n---+---+---\n %c | %c | %c \n---+---+---\n %c | %c | %c \n",
             board[0][0], board[0][1], board[0][2],
             board[1][0], board[1][1], board[1][2],
             board[2][0], board[2][1], board[2][2]);
    sendto(client_socket, board_str, strlen(board_str), 0, (struct sockaddr *)client_addr, sizeof(*client_addr));
}

int check_winner(char symbol)
{
    for (int i = 0; i < 3; i++)
    {
        if ((board[i][0] == symbol && board[i][1] == symbol && board[i][2] == symbol) ||
            (board[0][i] == symbol && board[1][i] == symbol && board[2][i] == symbol))
        {
            return 1;
        }
    }
    if ((board[0][0] == symbol && board[1][1] == symbol && board[2][2] == symbol) ||
        (board[0][2] == symbol && board[1][1] == symbol && board[2][0] == symbol))
    {
        return 1;
    }
    return 0;
}

int is_draw()
{
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if (board[i][j] == ' ')
            {
                return 0;
            }
        }
    }
    return 1;
}

int is_valid_move(int row, int col)
{
    if (row >= 1 && row < 4 && col > 0 && col < 4 && board[row - 1][col - 1] == ' ')
    {
        return 1;
    }
    return 0;
}

void handle_client(int socket, struct sockaddr_in *addr1, struct sockaddr_in *addr2)
{
    int current_player = 1;
    char player_symbol;
    char buffer[BUFFER_SIZE];

    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            board[i][j] = ' ';

    while (1)
    {
        struct sockaddr_in *current_addr = (current_player == 1) ? addr1 : addr2;
        player_symbol = (current_player == 1) ? 'X' : 'O';
        snprintf(buffer, sizeof(buffer), "Enter your move (1-3): ");
        sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)current_addr, sizeof(*current_addr));
        int addrlen = sizeof(*current_addr);
        recvfrom(socket, buffer, sizeof(buffer), 0, (struct sockaddr *)current_addr, &addrlen);

        int row, col;
        sscanf(buffer, "%d %d", &row, &col);

        if (is_valid_move(row, col))
        {
            board[row - 1][col - 1] = player_symbol;
            updated_board_sent(socket, addr1);
            updated_board_sent(socket, addr2);

            if (check_winner(player_symbol))
            {
                snprintf(buffer, sizeof(buffer), "Player %d Wins!\nWant to play again?(Yes/No)", current_player);
                sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr1, sizeof(*addr1));
                memset(buffer, 0, 1024);
                addrlen = sizeof(*addr1);
                recvfrom(socket, buffer, sizeof(buffer), 0, (struct sockaddr *)addr1, &addrlen);
                int flag = 0;
                if (strstr(buffer, "Yes"))
                {
                    printf("yooo");
                    flag = 1;
                }
                int flag2 = 0;
                if (flag)
                {
                    snprintf(buffer, sizeof(buffer), "Player %d Wins!\nWant to play again?(Yes/No)", current_player);
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr2, sizeof(*addr2));
                    addrlen = sizeof(*addr2);
                    recvfrom(socket, buffer, sizeof(buffer), 0, (struct sockaddr *)addr2, &addrlen);
                    if (strstr(buffer, "Yes"))
                    {
                        flag2 = 1;
                    }
                }
                else
                {
                    snprintf(buffer, sizeof(buffer), "Player %d Wins!", current_player);
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr2, sizeof(*addr2));
                }
                if (flag && flag2)
                {
                    for (int i = 0; i < 3; i++)
                        for (int j = 0; j < 3; j++)
                            board[i][j] = ' ';
                }
                else
                {
                    snprintf(buffer, sizeof(buffer), "Done");
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr1, sizeof(*addr1));
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr2, sizeof(*addr2));
                    break;
                }
            }
            if (is_draw())
            {
                snprintf(buffer, sizeof(buffer), "It's a Draw!\nWant to play again?(Yes/No)");
                sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr1, sizeof(*addr1));
                memset(buffer, 0, 1024);
                addrlen = sizeof(*addr1);
                recvfrom(socket, buffer, sizeof(buffer), 0, (struct sockaddr *)addr1, &addrlen);
                int flag = 0;
                if (strstr(buffer, "Yes"))
                {
                    flag = 1;
                }
                int flag2 = 0;
                if (flag)
                {
                    snprintf(buffer, sizeof(buffer), "It's a Draw!\nWant to play again?(Yes/No)");
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr2, sizeof(*addr2));
                    addrlen = sizeof(*addr2);
                    recvfrom(socket, buffer, sizeof(buffer), 0, (struct sockaddr *)addr2, &addrlen);
                    if (strstr(buffer, "Yes"))
                    {
                        flag2 = 1;
                    }
                }
                else
                {
                    snprintf(buffer, sizeof(buffer), "It's a Draw!");
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr2, sizeof(*addr2));
                }
                if (flag && flag2)
                {
                    for (int i = 0; i < 3; i++)
                        for (int j = 0; j < 3; j++)
                            board[i][j] = ' ';
                }
                else
                {
                    snprintf(buffer, sizeof(buffer), "Done");
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr1, sizeof(*addr1));
                    sendto(socket, buffer, strlen(buffer), 0, (struct sockaddr *)addr2, sizeof(*addr2));
                    break;
                }
            }
            current_player = (current_player == 1) ? 2 : 1;
        }
        else
        {
            sendto(socket, "Invalid move. Try again.\n", 25, 0, (struct sockaddr *)current_addr, sizeof(*current_addr));
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
    struct sockaddr_in address, client1, client2;
    int opt = 1;
    int addrlen = sizeof(address);
    char buffer[1024] = {0};

    if ((server_fd = socket(AF_INET, SOCK_DGRAM, 0)) == 0)
    {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt)))
    {
        perror("setsockopt failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(atoi(argv[1]));

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0)
    {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    printf("Welcome to Server of the TIC-TAC-TOE Game!!\n");

    while (1)
    {
        addrlen = sizeof(client1);
        if (recvfrom(server_fd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client1, &addrlen) < 0)
        {
            perror("recvfrom failed for Player 1");
            continue;
        }
        printf("Player 1 has connected\n");

        addrlen = sizeof(client2);
        if (recvfrom(server_fd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client2, &addrlen) < 0)
        {
            perror("recvfrom failed for Player 2");
            continue;
        }
        printf("Player 2 has connected\n");

        int flag1 = 0, flag2 = 0;
        while (!flag1 || !flag2)
        {
            if (!flag1)
            {
                snprintf(buffer, sizeof(buffer), "Do You want to start the game(Yes/no)");
                sendto(server_fd, buffer, strlen(buffer), 0, (struct sockaddr *)&client1, sizeof(client1));
                recvfrom(server_fd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client1, &addrlen);
                char input[1024];
                sscanf(buffer, "%s", input);
                if (strstr(input, "yes") || strstr(input, "Yes"))
                {
                    flag1 = 1;
                }
            }
            if (!flag2)
            {
                snprintf(buffer, sizeof(buffer), "Do You want to start the game(Yes/no)");
                sendto(server_fd, buffer, strlen(buffer), 0, (struct sockaddr *)&client2, sizeof(client2));
                recvfrom(server_fd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client2, &addrlen);
                char input[1024];
                sscanf(buffer, "%s", input);
                if (strstr(input, "yes") || strstr(input, "Yes"))
                {
                    flag2 = 1;
                }
            }
        }

        handle_client(server_fd, &client1, &client2);
    }
    close(server_fd);
}
