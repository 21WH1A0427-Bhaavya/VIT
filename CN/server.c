#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

int main() {
    int server_fd, new_socket;
    struct sockaddr_in server_addr, client_addr;
    socklen_t addr_len = sizeof(client_addr);
    char buffer[1024] = {0};
    char message[] = "Hello from Server";

    // 1. Create socket
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        perror("Socket creation failed");
        exit(1);
    }

    // 2. Bind socket to IP and port
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(8080);

    bind(server_fd, (struct sockaddr*)&server_addr, sizeof(server_addr));

    // 3. Listen for connections
    listen(server_fd, 5);

    printf("Server listening on port 8080...\n");

    // 4. Accept client connection
    new_socket = accept(server_fd, (struct sockaddr*)&client_addr, &addr_len);

    // 5. Receive data from client
    recv(new_socket, buffer, sizeof(buffer), 0);
    printf("Client says: %s\n", buffer);

    // 6. Send response to client
    send(new_socket, message, strlen(message), 0);

    // 7. Close sockets
    close(new_socket);
    close(server_fd);

    return 0;
}
