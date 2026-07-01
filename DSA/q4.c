#include <stdio.h>
#define INF 1000000

int minDist(int dist[], int visited[], int n) {
    int min = INF, idx;
    for (int i = 0; i < n; i++) {
        if (!visited[i] && dist[i] <= min) 
            min = dist[i], idx = i;
    }
    return idx;
}

int main() {
    int n;
    scanf("%d", &n);
    int g[n][n];
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            scanf("%d", &g[i][j]);
    int src;
    scanf("%d", &src);

    int dist[n], visited[n];
    for (int i = 0; i < n; i++) 
        dist[i] = INF, visited[i] = 0;
    dist[src] = 0;

    for (int i = 0; i < n-1; i++) {
        int u = minDist(dist, visited, n);
        visited[u] = 1;
        for (int v = 0; v < n; v++)
            if (!visited[v] && g[u][v] && dist[u] + g[u][v] < dist[v])
                dist[v] = dist[u] + g[u][v];
    }

    printf("Vertex \tDistance from Source\n");
    for (int i = 0; i < n; i++)
        printf("%d\t\t%d\n", i, dist[i]);
}
