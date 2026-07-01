#include <stdio.h>
#include <stdlib.h>

int q[1000], f=0, r=-1;

void push(int x) { 
    q[++r]=x; 
}
int pop() { 
    return q[f++]; 
}
int empty() { 
    return f>r; 
}

int main() {
    int n, m;
    scanf("%d%d", &n, &m);
    int adj[n][n];
    for(int i=0;i<n;i++) {
        for(int j=0;j<n;j++) {
            adj[i][j]=0;
        }
    }
    for(int i=0;i<m;i++) {
        int u,v; scanf("%d%d",&u,&v);
        adj[u][v]=adj[v][u]=1;
    }
    int s,d; 
    scanf("%d%d",&s,&d);

    int dist[n], prev[n];
    for(int i=0;i<n;i++) {
        dist[i]=-1, prev[i]=-1;
    }
    dist[s]=0; 
    push(s);

    while(!empty()) {
        int u=pop();
        for(int v=0;v<n;v++)
            if(adj[u][v] && dist[v]==-1){
                dist[v]=dist[u]+1;
                prev[v]=u;
                push(v);
            }
    }

    printf("Shortest path length: %d\n", dist[d]);
    int path[100]; int cnt=0;
    for(int v=d;v!=-1;v=prev[v]) path[cnt++]=v;
    printf("Path: ");
    for(int i=cnt-1;i>=0;i--) printf("%d ", path[i]);
}