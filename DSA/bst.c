#include <stdio.h>
#include <stdlib.h>
struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};
struct Node* createNode(int value) {
    struct Node* root = (struct Node*)malloc(sizeof(struct Node));
    root->data = value;
    root->left = root->right = NULL;
    return root;
}
struct Node* insert(struct Node* root, int value) {
    if(root == NULL) {
        root = createNode(value);
    }
    if(root->data > value) {
        root->left = insert(root->left, value);
    }
    else if(root->data < value) {
        root->right = insert(root->right, value);
    }
    return root;
}
struct Node* findMin(struct Node* root) {
    while(root->left != NULL) {
        root = root->left;
    }
    return root;
}
struct Node* delete(struct Node* root, int key) {
    if(root == NULL) return NULL;
    if(root->data > key) root->left = delete(root->left, key);
    else if(root->data < key) root->right = delete(root->right, key);

    else {
        if(root->left == NULL && root->right == NULL) {
            free(root);
            return NULL;
        }
        else if(root->left == NULL) {
            struct Node* temp = root->right;
            free(root);
            return temp; 
        }
        else if(root->right == NULL) {
            struct Node* temp = root->left;
            free(root);
            return temp;
        }
        struct Node* temp = findMin(root->right);
        root->data = temp->data;
        root->right = delete(root->right, temp->data);
    }
    return root;
}
void inorder(struct Node* root) {
    if(root == NULL) return;
    inorder(root->left);
    printf("%d ", root->data);
    inorder(root->right);
}
void preorder(struct Node* root) {
    if(root == NULL) return;
    printf("%d ", root->data);
    preorder(root->left);
    preorder(root->right);
}
void postorder(struct Node* root) {
    if(root == NULL) return;
    postorder(root->left);
    postorder(root->right);
    printf("%d ", root->data);
}
int height(struct Node* root) {
    if(root == NULL) return -1;
    int leftH = height(root->left);
    int rightH = height(root->right);
    return 1 + (leftH > rightH ? leftH : rightH);
}
void levelOrder(struct Node* root) {
    if(root == NULL) {
        return;
    }
    struct Node* queue[100];
    int front = 0, rear = 0;
    queue[rear++] = root;
    while(front < rear) {
        struct Node* temp = queue[front++];
        printf("%d ", temp->data);

        if(temp->left != NULL) {
            queue[rear++] = temp->left;
        }

        if(temp->right != NULL) {
            queue[rear++] = temp->right;
        }
    }
}
int main() {
    struct Node* root = NULL;
    root = insert(root, 45);
    root = insert(root, 20);
    root = insert(root, 60);
    root = insert(root, 10);
    root = insert(root, 30);
    root = insert(root, 50);
    root = insert(root, 70);
    root = insert(root, 25);

    inorder(root);
    printf("\n");
    preorder(root);
    printf("\n");
    postorder(root);
    printf("\n");

    root = delete(root, 20);
    inorder(root);
    printf("\n");
    return 0;
}