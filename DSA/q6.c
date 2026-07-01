#include <stdio.h>
#include <stdlib.h>

typedef struct { 
    int u,v,w; 
} edge;
int cmp(const void *a,const void *b) { 
    return ((edge*)a)->w - ((edge*)b)->w; 
}

int parent[20];
int find(int x){ 
    return parent[x]==x?x:(parent[x]=find(parent[x])); 
}
void merge(int x,int y){ 
    parent[find(x)]=find(y); 
}

int main() {
    int n;
    scanf("%d",&n);
    int g[n][n];
    for(int i=0;i<n;i++)
        for(int j=0;j<n;j++)
            scanf("%d",&g[i][j]);

    edge e[n*n]; int cnt=0;
    for(int i=0;i<n;i++)
        for(int j=i+1;j<n;j++)
            if(g[i][j] && g[i][j]<9999)
                e[cnt++] = (edge){i,j,g[i][j]};
    qsort(e,cnt,sizeof(edge),cmp);

    for(int i=0;i<n;i++) 
        parent[i]=i;

    for(int i=0;i<cnt;i++){
        int u=find(e[i].u), v=find(e[i].v);
        if(u!=v){
            printf("%d -> %d\n", e[i].u+1, e[i].v+1);
            merge(u,v);
        }
    }
}