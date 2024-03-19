#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define BACKLOG 100

void panic(int code, int lineNum) {
	if (code == 0) {
		return;
	}

	char error_msg[64];
	snprintf(error_msg, sizeof(error_msg), "Panic %d @ %d\n", code, lineNum);
	__attribute__((unused)) ssize_t bytes_written = write(STDOUT_FILENO, error_msg, strlen(error_msg));
	exit(code);
}

int main() {
	int server_fd, new_socket;
	struct sockaddr_in address;
	int addrlen = sizeof(address);

	// Create socket
	if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
		panic(255, 31);
	}

	address.sin_family = AF_INET;
	address.sin_addr.s_addr = INADDR_ANY;
	address.sin_port = htons(8080);

	// Bind socket to address and port
	if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
		panic(1, 44);
	}

	// Listen for incoming connections
	if (listen(server_fd, BACKLOG) < 0) {
		panic(1, 56);
	}

	while (1) {
		// Accept incoming connection
		if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
			panic(1, 69);
		}

		// Send HTTP response
		const char *response = "HTTP/1.1 200 OK\r\n\r\nHello, World!";
		ssize_t send_result = send(new_socket, response, strlen(response), 0);
		if (send_result < 0) {
			panic(1, 93);
		}

		// Shutdown and close the socket
		shutdown(new_socket, SHUT_RDWR);
		close(new_socket);
	}

	return 0;
}