#include <stdio.h>
int main() {
        int blocks, files;
        printf("Enter the Number of blocks: ");
        scanf("%d", &blocks);
        int allocated[blocks];
        int blockSize[blocks];
        printf("Enter the block size: ");
        for(int i=0; i<blocks; i++) {
                scanf("%d", &blockSize[i]);
                allocated[i] = 0;
        }
        printf("Enter the Number of files: ");
        scanf("%d", &files);
        int fileSize[files];
        printf("Enter the file size: ");
        for(int i=0; i<files; i++) {
                scanf("%d", &fileSize[i]);
        }
        int intFragment[blocks];
        int j = 0;
        int k=0;
        int fileSizeO[files], fileNo[files], BlockNo[blocks], blockSizeO[blocks];
        for(int i=0; i<files; i++) {
                for(int j=0; j<blocks; j++) {
                if(fileSize[i] <= blockSize[j] && allocated[j] != 1) {
                        intFragment[j] = blockSize[j] - fileSize[i];
                        allocated[j] = 1;
                        fileNo[k] = i;
                        fileSizeO[k] = fileSize[i];
                        BlockNo[k] = j;
                        blockSizeO[k] = blockSize[j];
                        k += 1;
                        break;
                        }
                }
        }

        int iFragment = 0, eFragment = 0;
        for(int i=0; i<blocks; i++) {
                if(allocated[i] == 1) {
                        iFragment += intFragment[i];
                }
                else {
                        eFragment += blockSize[i];
                }
        }
        printf("Internal Fragmentation: %d\n", iFragment);
        printf("External Fragmentation: %d\n", eFragment);
        return 0;
    }