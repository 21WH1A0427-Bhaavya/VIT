#include <stdio.h>
#define INF 1000

int main() {
    int v;
    scanf("%d",&v);
    int g[v][v];
    for(int i=0;i<v;i++)
        for(int j=0;j<v;j++)
            scanf("%d",&g[i][j]);

    int key[v], mst[v], parent[v];
    for(int i=0;i<v;i++) key[i]=INF, mst[i]=0;
    key[0]=0; parent[0]=-1;

    for(int i=0;i<v-1;i++){
        int min=INF,u;
        for(int j=0;j<v;j++)
            if(!mst[j] && key[j]<min) min=key[j], u=j;
        mst[u]=1;
        for(int j=0;j<v;j++)
            if(g[u][j] && !mst[j] && g[u][j]<key[j])
                key[j]=g[u][j], parent[j]=u;
    }

    printf("Edge   Weight\n");
    for(int i=1;i<v;i++)
        printf("%d - %d    %d\n", parent[i], i, key[i]);
}