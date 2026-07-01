#include<stdio.h>
#include<stdlib.h>
struct Node {
    int data;
    struct Node* next;
};
struct Node* head = NULL;
struct Node* head1 = NULL;
struct Node* createNode(int value) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = value;
    newNode->next = NULL;
    return newNode;
}
void insertAtEnd(int value) {
    struct Node* newNode = createNode(value);
    if (head == NULL) {
        head = newNode;
        return;
    }
    struct Node* temp = head;
    while (temp->next != NULL)
        temp = temp->next;
    temp->next = newNode;
}
void delete() {
    struct Node* temp = head, *prev = NULL, *temp1 = NULL;
    int i = 0;
    while(temp != NULL) {
        if(i%2 == 1) {
            prev->next = temp->next;
            struct Node* nextNode = temp->next; 
            temp->next = NULL;
            if(head1 == NULL) {
                head1 = temp;
                temp1 = head1;
            }
            else {
                temp1->next = temp;
                temp1 = temp1->next;
            }
            temp = nextNode;
            i++;
            continue;
        }
        prev = temp;
        temp = temp->next;
        i++;
    }
}
void reverse() {
    struct Node* prev = NULL, *curr = head1, *next = NULL;
    while(curr != NULL) {
        next = curr->next;
        curr->next = prev;
        prev = curr;
        curr = next;
    }
    head1 = prev;
}
void append() {
    if (head == NULL) {
        head = head1;
        return;
    }
    struct Node* temp = head;
    while(temp->next != NULL) {
        temp = temp->next;
    }
    temp->next = head1;
}
int main() {
    int n;
    scanf("%d", &n);
    int value;
    for(int i=0; i<n; i++) {
        scanf("%d", &value);
        insertAtEnd(value);
    }
    delete();
    reverse();
    append();
    struct Node* temp = head;
    while(temp != NULL) {
        printf("%d -> ", temp->data);
        temp = temp->next;
    }
    return 0;
}
