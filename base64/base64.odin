package Base64


import "core:fmt"
import "core:strings"

B64TABLE := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

_to_string :: proc(_n : int ) -> string{
    //fmt.println("in toStr");
    ret_val : string ;
    n := _n;
    STRINGTABLE : string = "0123456789"; 
    for{
        if n <= 0{
            break;
        }
        chunk := fmt.aprintf("%v", rune(STRINGTABLE[int(n) % 10]));
        fmt.println(rune(STRINGTABLE[0]));
        temp : []string = {chunk,ret_val};  
        ret_val = strings.concatenate(temp);
        n = n/10;
    }
    //fmt.println("returning ", ret_val);
    return ret_val;
}

_toHex :: proc (_n : u8) -> string{
    VALID_DIGITS :string = "0123456789ABCDEF";
    //fmt.println("in toHex");
    ret_val : string;
    n := _n;
    for{
        if n <= 0{
            break;
        }
        chunk := fmt.aprintf("%v", rune(VALID_DIGITS[int(n) % 16]));
        //fmt.println("chunking ", n , ":= ", chunk);
        temp : []string = {chunk,ret_val};  
        ret_val = strings.concatenate(temp);
        //fmt.println(ret_val);
        //fmt.println("concat gave me: ",ret_val);
        n = n / 16;
        
    }

    //fmt.println("returning ", ret_val);
    return ret_val;
}

b64_encode :: proc(input : string) -> string {
    ret_val : string; 

    //chunk for current iteration of recursive loop 
    chunk :[4]u8; //init to zero
    //in this case we can parse a non-padded segment
    if len(input) >= 3 {
        chunk[0] |= (input[0] & 0xFC) >> 2;
        chunk[1] |= ((input[0] & 0x03) << 4) | ((input[1] & 0x30) >> 2);
        chunk[2] |= ((input[1] & 0x0F) << 4) | ((input[2] & 0xC0) >> 2);
        chunk[3] |= (input[2] & 0x3F) >> 2;


    }
    //in this case we have 1 padding
    else if len(input) == 2{
        chunk[0] |= (input[0] & 0xFC) >> 2;
        chunk[1] |= ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 1);
        chunk[2] |= ((input[1] & 0x0F) << 4) ;
    }   
    //in this case we have 2 paddings
    else{
        chunk[0] |= (input[0] & 0xFC) >> 2;
        chunk[1] |= ((input[0] & 0x03) << 4);
    }

     
    for val,idx in chunk{
        //fmt.println("looking at [v:", val,"i:", idx,"]");
        //fmt.println(_toHex(val));
        temp_chunk := fmt.aprintf("%v",rune(B64TABLE[val]));
        temp : []string = {temp_chunk,ret_val};
        ret_val = strings.concatenate(temp) ;
    }

    fmt.println("my chunks are", chunk, " -> ",ret_val);

    return ret_val;
}

b64_decode :: proc(input : string) -> string {
    ret_val : string;    
    return ret_val;
}


main :: proc () {
    //known values to verify initial functionality
    //test_sentence_in := "Test Sentence";
    //test_sentence_out := "VGVzdCBTZW50ZW5jZQo=";
    test_sentence_in := "Man";
    test_sentence_out := "TWFu";
    
    //test
    assert(b64_encode(test_sentence_in) == test_sentence_out);
    assert(b64_decode(test_sentence_out) == test_sentence_in);
}