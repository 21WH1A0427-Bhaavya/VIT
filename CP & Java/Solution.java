import java.util.Scanner;
import java.util.Stack;
class Solution {
    public static boolean validateStackSequences(int[] pushed, int[] popped) {
        Stack<Integer> st = new Stack<>();
        for(int i=0; i<pushed.length; i++) {
            st.push(pushed[i]);
        }
        int j=0;
        while(!st.isEmpty() && j < popped.length) {
            //System.out.println(ele + " " + popped[j]);
            if(st.pop() == popped[j]) {
                st.pop();
            }
            j += 1;
        }
        return st.isEmpty();
    }
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        int[] pushed = new int[n];
        int[] popped = new int[n];
        for(int i=0; i<n; i++) {
            pushed[i] = sc.nextInt();
        }
        for(int i=0; i<n; i++) {
            popped[i] = sc.nextInt();
        }
        if(validateStackSequences(pushed, popped)) System.out.println("Valid Stack");
        else System.out.println("Invalid Stack");
    }
}