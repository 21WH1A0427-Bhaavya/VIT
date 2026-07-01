#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

int main() {
    int sock;
    struct sockaddr_in server_addr;
    char buffer[1024] = {0};
    char message[] = "Hello from Client";

    // 1. Create socket
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("Socket creation failed");
        exit(1);
    }

    // 2. Server address
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(8080);
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");

    // 3. Connect to server
    connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr));

    // 4. Send message to server
    send(sock, message, strlen(message), 0);

    // 5. Receive reply from server
    recv(sock, buffer, sizeof(buffer), 0);
    printf("Server says: %s\n", buffer);

    // 6. Close socket
    close(sock);

    return 0;
}
