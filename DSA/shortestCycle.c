#include <stdio.h>
#include <stdbool.h>
#include <limits.h>
#define INF 1000000000
int main() {
    int v, e;
    scanf("%d %d", &v, &e);
    int dist[v][v];
    for(int i=0; i<v; i++) {
        for(int j=0; j<v; j++) {
            if(i == j) {
                dist[i][j] = 0;
            }
            else {
                dist[i][j] = INF;
            }
        }
    }
    int edges[e][3];
    for(int i=0; i<e; i++) {
        int start, end, weight;
        scanf("%d %d %d", &start, &end, &weight);
        dist[start][end] = weight;
        edges[i][0] = start;
        edges[i][1] = end;
        edges[i][2] = weight;
    }
    for(int k=0; k<v; k++) {
        for(int i=0; i<v; i++) {
            for(int j=0; j<v; j++) {
                if(dist[i][k] < INF && dist[k][j] < INF) {
                    if(dist[i][j] > dist[i][k] + dist[k][j]) {
                        dist[i][j] = dist[i][k] + dist[k][j];
                    }
                }
            }
        }
    }
    int shortest = INF;
    for(int i=0; i<e; i++) {
        int start = edges[i][0];
        int end = edges[i][1];
        int weight = edges[i][2];
        if(dist[end][start] < INF) {
            int cycle_len = dist[end][start] + weight;
            if(cycle_len < shortest) shortest = cycle_len;
        }
    }
    if(shortest == INF) {
        printf("No cycle exists");
    }
    else {
        printf("Length of the shortest cycle: %d", shortest);
    }
    return 0;
}