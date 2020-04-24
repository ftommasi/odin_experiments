package linklist

import "core:fmt"

Node :: struct(T : typeid) {
    next : ^Node(T),
    data : T
};

LinkedList :: struct (T : typeid){
    head : ^Node(T),
    size : uint,

    
}
add_node :: proc($T : typeid, l : LinkedList($D)){
        l.head^.next = make(Node(T));
        l.head^.data = $T;
        l.head^.next^.next = nil;
        l.size += 1;
    }

delete_linked_list :: proc (mylist : LinkedList($T)){
     curr : Node^($T) = mylist.head;
    for {
        if curr == nil do break;
       delete(curr) ;
    }
   
}

main :: proc(){
    mylist : LinkedList(int);
    defer delete_linked_list(mylist);//
    for i in 0..5{
        add_node(mylist,i);
    }
    curr : Node^ = mylist.head;
    for {
        if curr == nil do break;
        fmt.println(curr^.data);
    }
    
}