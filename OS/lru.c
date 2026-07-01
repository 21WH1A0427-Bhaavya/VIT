#include <stdio.h>
#include <stdbool.h>

int find(int pages[], int key[], int idx) {
    int dup = key[idx - 1] + 1;
    for (int i = idx; i > 0; i--) {
        if (pages[i] == pages[idx]) {
            key[i] = dup;
        }
    }
    int min = 100;
    for (int j = 0; j < idx + 1; j++) {
        if (min > key[j]) {
            min = key[j];
        }
    }
    return min;
}

int main() {
    int n;
    printf("Enter the number of pages: ");
    scanf("%d", &n);
    printf("Enter the page numbers: ");
    int pages[n];
    int key[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &pages[i]);
        key[i] = 0;
    }

    int frames[3];
    for (int i = 0; i < 3; i++) {
        frames[i] = pages[i];
        find(pages, key, i);
    }

    int hit = 0, fault = 3; 
    bool flag = false;

    for (int i = 3; i < n; i++) {
        flag = false;  
        for (int j = 0; j < 3; j++) {
            if (pages[i] == frames[j]) {
                hit++;
                flag = true;
                break;
            }
        }

        if (!flag) {
            fault++;
            int recent[3];
            for (int k = 0; k < 3; k++) {
                recent[k] = -1;
                for (int t = i - 1; t >= 0; t--) {
                    if (frames[k] == pages[t]) {
                        recent[k] = t;
                        break;
                    }
                }
            }
            int min_index = 0;
            for (int k = 1; k < 3; k++) {
                if (recent[k] < recent[min_index]) {
                    min_index = k;
                }
            }
            frames[min_index] = pages[i];
        }
    }

    printf("Hits: %d\n", hit);
    printf("Faults: %d\n", fault);
    return 0;
}
