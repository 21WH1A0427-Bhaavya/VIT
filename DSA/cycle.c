#include <stdio.h>
#include <stdbool.h>

int dfs(int v, int graph[][v], int src, int parent, bool visited[v], int degree[v]) {
    visited[src] = true;
    for(int i=0; i<degree[src]; i++) {
        int neighbor = graph[src][i];
        if(!visited[neighbor]) {
            if(dfs(v, graph, neighbor, src, visited, degree)) return true;
        }
        else {
            if(neighbor != parent) {
                return true;
            }
        }
    }
    return false;
}


int main() {
    int v, e;
    scanf("%d %d", &v, &e);

    int graph[v][v];
    bool visited[v];
    int degree[v];

    for(int i=0; i<v; i++) {
        degree[i] = 0;
        visited[i] = false;
    }

    for(int i=0; i<e; i++) {
        int a, b;
        scanf("%d %d", &a, &b);
        graph[a][degree[a]++] = b;
        graph[b][degree[b]++] = a;
    }

    bool cycle = false;
    for(int i=0; i<v; i++) {
        if(!visited[i]) {
            if(dfs(v, graph, i, -1, visited, degree)) {
                cycle = true;
                break;
            }
        }
    }
    if(cycle)  
    {
        printf("Cycle exists: 1");
    }
    else 
    {
        printf("Cycle doesn't exist: 0");
    }
    return 0;
}