#include <stdio.h>
#include <stdlib.h>
char stack1[100];
int top = -1;
int balanced(char exp[]) {
    for(int i=0; exp[i] != '\0'; i++) {
        char ch = exp[i];
        if(ch == '(' || ch == '[' || ch == '{') {
            stack1[++top] = ch;
        }
        else if(ch == ')' || ch == ']'|| ch == '}') {
            if(top == -1) return 0;
            if(ch == ')' && stack1[top] == '(') {
                top--;
            }
            else if(ch == ']' && stack1[top] == '[') {
                top--;
            }
            else if(ch == '}' && stack1[top] == '{') {
                top--;
            }
            else {
                return 0;
            }
        }
    }
    if(top == -1) {
        return 1;
    }
    else {
        return 0;
    }
}
int main() {
    char exp[] = "{(12+3)*[5+(6-1)]}";
    int balance = balanced(exp);
    if(balance == 0) {
        printf("Unbalanced Expression\nInvalid: Cannot convert or evaluate\n");
        return 0;
    }
    else {
        printf("Balnced\n");
    }
    return 0;
}