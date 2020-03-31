package Base64

import "core:fmt"

B64TABLE := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


b64_encode :: proc(input : string) -> string {
    ret_val : string; 
    
    //in this case we can parse a non-padded segment
    if len(input) >= 3 {
        
    }
    //in this case we have 1 padding
    else if len(input) == 2{

    }   
    //in this case we have 2 paddings
    else{

    }

    return ret_val;
}
b64_decode :: proc(input : string) -> string {
    ret_val : string;    
    return ret_val;
}


main :: proc () {
    //known values to verify initial functionality
    test_sentence_in := "Test Sentence";
    test_sentence_out := "VGVzdCBTZW50ZW5jZQo=";

    //test
    assert(b64_encode(test_sentence_in) == test_sentence_out);
    assert(b64_decode(test_sentence_out) == test_sentence_in);
}