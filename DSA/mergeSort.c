#include <stdio.h>
#include <stdlib.h>
void merge(int arr[], int left, int mid, int right) {
    int i = left;
    int j = mid + 1;
    int k = 0;
    int temp[100];

    while(i <= mid && j <= right) {
        if(arr[i] <= arr[j]) {
            temp[k++] = arr[i++];
        }
        else if(arr[j] < arr[i]) {
            temp[k++] = arr[j++];
        }
    }
    while(i <= mid) {
        temp[k++] = arr[i++]; 
    }
    while(j <= right) {
        temp[k++] = arr[j++];
    }
    for(int i=left, k=0; i<=right; i++, k++) {
        arr[i] = temp[k];
    }
}

void mergeSort(int arr[], int left, int right) {
    if(left < right) {
        int mid = (left + right)/2;
        mergeSort(arr, left, mid);
        mergeSort(arr, mid+1, right);

        merge(arr, left, mid, right);
    }
}
int main() {
    int n;
    scanf("%d", &n);
    int arr[n];
    for(int i=0; i<n; i++) {
        scanf("%d", &arr[i]);
    }
    mergeSort(arr, 0, n-1);
    for(int i=0; i<n; i++) {
        printf("%d ", arr[i]);
    }
    return 0;
}