#include <stdio.h>
#include <stdlib.h>
int partition(int arr[], int low, int high) {
    int pivot = arr[high];
    int i = low-1;
    int temp;
    for(int j=low; j<high; j++) {
        if(arr[j] < pivot) {
            i += 1;
            temp = arr[j];
            arr[j] = arr[i];
            arr[i] = temp; 
        }
    }
    temp = arr[i+1];
    arr[i+1] = arr[high];
    arr[high] = temp;
    return i+1;
}
void quickSort(int arr[], int low, int high) {
    if(low < high) {
        int pivot_idx = partition(arr, low, high);
        quickSort(arr, low, pivot_idx-1);
        quickSort(arr, pivot_idx+1, high);
    }
}
int main() {
    int n;
    scanf("%d", &n);
    int arr[n];
    for(int i=0; i<n; i++) {
        scanf("%d", &arr[i]);
    }
    quickSort(arr, 0, n-1);
    for(int i=0; i<n; i++) {
        printf("%d ", arr[i]);
    }
    return 0;
}