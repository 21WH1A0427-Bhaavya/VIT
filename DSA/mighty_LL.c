#include <stdio.h>
#include <stdlib.h>
struct Node {
    int data;
    struct Node* next;
};
struct Node* head = NULL;
struct Node* createNode(int value) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = value;
    newNode->next = NULL;
    return newNode;
}
void insertAtB(int value) {
    struct Node* newNode = createNode(value);
    newNode->next = head;
    head = newNode;
    return;
}
void insertAtE(int value) {
    struct Node* newNode = createNode(value);
    if(head == NULL) {
        head = newNode;
        return;
    }
    struct Node* curr = head;
    while(curr->next != NULL) {
        curr = curr->next;
    }
    curr->next = newNode;
    return;
}
void deleteFromB() {
    struct Node* temp = head;
    head = head->next;
    free(temp);
    return;
}
void insertAtPos(int pos, int value) {
    struct Node* temp = head;
    int i=0;
    if(pos == 1) {
        insertAtB(value);
    }
    while(i < pos-1 && temp != NULL) {
        temp = temp->next;
        i += 1;
    }
    if(temp != NULL) {
        struct Node* newNode = createNode(value);
        newNode->next = temp->next;
        temp->next = newNode;
    }
    return;
}
void deleteAtPos(int pos) {
    struct Node* temp = head;
    int i=0;
    while(i < pos-1 && temp->next != NULL) {
        temp = temp->next;
        i += 1;
    }
    struct Node* dummy = temp->next;
    temp->next = dummy->next;
    free(dummy);
    return;
}
int main() {
    // insertAtB(10);
    // insertAtB(20);
    // insertAtE(5);
    // insertAtE(25);

    // deleteFromB();
    // insertAtB(15);

    insertAtPos(1, 5);
    insertAtPos(4, 25);
    deleteAtPos(3);
    deleteAtPos(1);

    struct Node* curr = head;
    while(curr != NULL) {
        printf("%d -> ", curr->data);
        curr = curr->next;
    }
    return 0;
}