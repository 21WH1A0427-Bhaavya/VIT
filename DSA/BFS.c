#include <stdio.h>
#include <stdbool.h>

void BFS(int v, int graph[v][v], int src) {
    int queue[v];
    bool visited[v];
    int front = 0, rear = 0;
    visited[src] = true;
    queue[rear++] = src;
    while(front < rear) {
        int current = queue[front++];
        printf("%d ", current);
        for(int i=0; i<v; i++) {
            if(graph[current][i] == 1 && !visited[i]) {
                queue[rear++] = i;
                visited[i] = true; 
            }
        }
    }
}
int main() {
    int v, e;
    scanf("%d %d", &v, &e);
    int graph[v][v];
    for(int i=0; i<e; i++) {
        int a, b;
        scanf("%d %d", &a, &b);
        graph[a][b] = 1;
        graph[b][a] = 1;
    }
    int src;
    scanf("%d", &src);
    BFS(v, graph, src);
    return 0;
}