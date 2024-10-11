#include "header.h"

char board[3][3];

void updated_board_sent(int client_socket)
{
    char board_str[BUFFER_SIZE];
    snprintf(board_str, sizeof(board_str),
             "\n %c | %c | %c \n---+---+---\n %c | %c | %c \n---+---+---\n %c | %c | %c \n",
             board[0][0], board[0][1], board[0][2],
             board[1][0], board[1][1], board[1][2],
             board[2][0], board[2][1], board[2][2]);
    send(client_socket, board_str, strlen(board_str), 0);
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

void handle_client(int new_socket1, int new_socket2)
{
    int current_player = 1;
    int winner = 0;
    char player_symbol;
    char buffer[BUFFER_SIZE];
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            board[i][j] = ' ';

    while (1)
    {
        int player_socket = (current_player == 1) ? new_socket1 : new_socket2;
        player_symbol = (current_player == 1) ? 'X' : 'O';

        snprintf(buffer, sizeof(buffer), "Enter your move (1-3): ");
        send(player_socket, buffer, strlen(buffer), 0);
        memset(buffer, 0, 1024);
        recv(player_socket, buffer, sizeof(buffer), 0);
        int row, col;
        sscanf(buffer, "%d %d", &row, &col);

        if (is_valid_move(row, col))
        {
            board[row - 1][col - 1] = player_symbol;
            updated_board_sent(new_socket1);
            updated_board_sent(new_socket2);
            if (check_winner(player_symbol) && current_player == 1)
            {
                snprintf(buffer, sizeof(buffer), "Player 1 Wins!\nWant to play again?(Yes/No)");
                send(new_socket1, buffer, strlen(buffer), 0);
                memset(buffer, 0, 1024);
                recv(new_socket1, buffer, sizeof(buffer), 0);
                int flag = 0;
                if (strstr(buffer, "Yes"))
                {
                    flag = 1;
                }
                int flag2 = 0;
                if (flag)
                {
                    snprintf(buffer, sizeof(buffer), "Player 1 Wins!\nWant to play again?(Yes/No)");
                    send(new_socket2, buffer, strlen(buffer), 0);
                    memset(buffer, 0, 1024);
                    recv(new_socket2, buffer, sizeof(buffer), 0);

                    if (strstr(buffer, "Yes"))
                    {
                        flag2 = 1;
                    }
                }
                else
                {
                    snprintf(buffer, sizeof(buffer), "Player 1 Wins!");
                    send(new_socket2, buffer, strlen(buffer), 0);
                }
                if (flag && flag2)
                {
                    for (int i = 0; i < 3; i++)
                        for (int j = 0; j < 3; j++)
                            board[i][j] = ' ';
                }
                else
                {
                    send(new_socket1, "Done", 4, 0);
                    send(new_socket2, "Done", 4, 0);
                    break;
                }
            }
            if (check_winner(player_symbol) && current_player == 2)
            {
                snprintf(buffer, sizeof(buffer), "Player 2 Wins!\nWant to play again?(Yes/No)");
                send(new_socket1, buffer, strlen(buffer), 0);
                memset(buffer, 0, 1024);
                recv(new_socket1, buffer, sizeof(buffer), 0);
                int flag = 0;
                if (strstr(buffer, "Yes"))
                {
                    flag = 1;
                }
                int flag2 = 0;
                if (flag)
                {
                    snprintf(buffer, sizeof(buffer), "Player 2 Wins!\nWant to play again?(Yes/No)");
                    send(new_socket2, buffer, strlen(buffer), 0);
                    memset(buffer, 0, 1024);
                    recv(new_socket2, buffer, sizeof(buffer), 0);
                    if (strstr(buffer, "Yes"))
                    {
                        flag2 = 1;
                    }
                }
                else
                {
                    snprintf(buffer, sizeof(buffer), "Player 2 Wins!");
                    send(new_socket2, buffer, strlen(buffer), 0);
                }
                if (flag && flag2)
                {
                    for (int i = 0; i < 3; i++)
                        for (int j = 0; j < 3; j++)
                            board[i][j] = ' ';
                }
                else
                {
                    send(new_socket1, "Done", 4, 0);
                    send(new_socket2, "Done", 4, 0);
                    break;
                }
            }
            if (is_draw())
            {
                snprintf(buffer, sizeof(buffer), "Match Draw!!\nWant to play again?(Yes/No)");
                send(new_socket1, buffer, strlen(buffer), 0);
                memset(buffer, 0, 1024);
                recv(new_socket1, buffer, sizeof(buffer), 0);
                int flag = 0;
                if (strstr(buffer, "Yes"))
                {
                    flag = 1;
                }
                int flag2 = 0;
                if (flag)
                {
                    snprintf(buffer, sizeof(buffer), "Match Draw!!\nWant to play again?(Yes/No)");
                    send(new_socket2, buffer, strlen(buffer), 0);
                    memset(buffer, 0, 1024);
                    recv(new_socket2, buffer, sizeof(buffer), 0);
                    if (strstr(buffer, "Yes"))
                    {
                        flag2 = 1;
                    }
                }
                else
                {
                    snprintf(buffer, sizeof(buffer), "Match Draw!!");
                    send(new_socket2, buffer, strlen(buffer), 0);
                }
                if (flag && flag2)
                {
                    for (int i = 0; i < 3; i++)
                        for (int j = 0; j < 3; j++)
                            board[i][j] = ' ';
                }
                else
                {
                    send(new_socket1, "Done", 4, 0);
                    send(new_socket2, "Done", 4, 0);
                    break;
                }
            }
            current_player = (current_player == 1) ? 2 : 1;
        }
        else
        {
            send(player_socket, "Invalid move. Try again.\n", 25, 0);
        }
    }
}
