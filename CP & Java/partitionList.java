import java.util.Scanner;
class Node {
    int data;
    Node next;
    Node (int d) {
        data = d;
        next = null;
    }
}
public class partitionList {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        Node head = null;
        Node tail = null;
        System.out.println("Enter the number of elements: ");
        int n = sc.nextInt();
        for(int i=0; i<n; i++) {
            int data = sc.nextInt();
            Node newNode = new Node(data);
            if(head == null) {
                head = tail = newNode;
            }
            else {
                tail.next = newNode;
                tail = tail.next;
            }
        }
        // Node curr = head;
        // while(curr != null) {
        //     System.out.println(curr.data + " ");
        //     curr = curr.next;
        // }
        System.out.println("Enter x: ");
        int x = sc.nextInt();
        
        Node temp1 = null, temp2 = null;
        Node beforeTail = null, afterTail = null;

        while (head != null) {
            Node nextNode = head.next;
            head.next = null; 

            if (head.data < x) {
                if (temp1 == null) {
                    temp1 = beforeTail = head;
                } else {
                    beforeTail.next = head;
                    beforeTail = head;
                }
            } else {
                if (temp2 == null) {
                    temp2 = afterTail = head;
                } else {
                    afterTail.next = head;
                    afterTail = head;
                }
            }
            head = nextNode;
        }

        if (beforeTail != null) {
            beforeTail.next = temp2;
            head = temp1;
        } else {
            head = temp2;
        }
        while (head != null) {
            System.out.print(head.data + " ");
            head = head.next;
        }
    }
}