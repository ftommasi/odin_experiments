package Base64


import "core:fmt"
import "core:strings"

//There has got to be a better way to know these right?!?!?!
B64TABLE := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
B64RING : map[rune]int= {    'A' = 0,    'B' = 1,     'C' = 2,    'D' = 3,    'E' = 4,    'F' = 5,    'G' = 6,    'H' = 7,    'I' = 8,    'J' = 9,    'K' = 10,    'L' = 11,    'M' = 12,    'N' = 13,    'O' = 14,    'P' = 15,    'Q' = 16,    'R' = 17,    'S' = 18,    'T' = 19,    'U' = 20,    'V' = 21,    'W' = 22,    'X' = 23,    'Y' = 24,    'Z' = 25,    'a' = 26,    'b' = 27,    'c' = 28,    'd' = 29,    'e' = 30,    'f' = 31,    'g' = 32,    'h' = 33,    'i' = 34,    'j' = 35,    'k' = 36,    'l' = 37,    'm' = 38,    'n' = 39,    'o' = 40,    'p' = 41,    'q' = 42,    'r' = 43,    's' = 44,    't' = 45,    'u' = 46,    'v' = 47,    'w' = 48,    'x' = 49,    'y' = 50,    'z' = 51,    '0' = 52,    '1' = 53,    '2' = 54,    '3' = 55,    '4' = 56,    '5' = 57,    '6' = 58,    '7' = 59,    '8' = 60,    '9' = 61,    '+' = 62,    '/' = 63,    '=' = 64};
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
        chunk[1] |= ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        chunk[2] |= ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        chunk[3] |= (input[2] & 0x3F) ;
    }
    //in this case we have 1 padding
    else if len(input) == 2{
        chunk[0] |= (input[0] & 0xFC) >> 2;
        chunk[1] |= ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        chunk[2] |= ((input[1] & 0x0F) << 2) ;
        chunk[3] = 64; //padding
    }   
    //in this case we have 2 paddings
    else{
        chunk[0] |= (input[0] & 0xFC) >> 2;
        chunk[1] |= ((input[0] & 0x03) << 4);
        chunk[2] = 64;
        chunk[3] = 64;
    }
    //put it all together 
    for val,idx in chunk{
        //fmt.println("looking at [v:", val,"i:", idx,"]");
        //fmt.println(_toHex(val));
        encoded_char := rune(B64TABLE[val]);
        temp_chunk := fmt.aprintf("%v",encoded_char);
        temp : []string = {ret_val,temp_chunk};
        ret_val = strings.concatenate(temp) ;
    }

    fmt.println("my chunks are", chunk, " -> ",ret_val);

    //need to recurse 
    alias : string;
    fmt.println("about to recurse. input:",input);
    if len(input) >= 4{
        alias =  input[4:];
    } 
    else{
        alias =  "";
    }
    final :[]string ;
    if alias != "" {
        fmt.println("recursing with",alias);
        final = {ret_val,b64_encode(alias)}; 
    }
    else{
            final = {ret_val};
    }
    return strings.concatenate(final);
}

_b64_decode :: proc(input : string) -> string {
    ret_val : string;
    in_slice := input[:4];
    chunk :[3]int; //init to zero
    //1 padding
    if rune(in_slice[3]) == '='{
        chunk[0] = (B64RING[rune(in_slice[0])] << 2 ) | ((B64RING[rune(in_slice[1])] & 0x30) >> 4);
        chunk[1] = ((B64RING[rune(in_slice[1])] & 0x0F) << 4) | ((B64RING[rune(in_slice[2])] & 0x3C) >> 2);
        chunk[2] = 0; 
    }
    //2 padding
    else if   rune(in_slice[2]) == '='{
        chunk[0] = (B64RING[rune(in_slice[0])] << 2 ) | ((B64RING[rune(in_slice[1])] & 0x30) >> 4);
        chunk[1] = 0; 
        chunk[2] = 0;
   }
    //no padding
    else{
        fmt.println("no padding");
        chunk[0] = (B64RING[rune(in_slice[0])] << 2 ) | ((B64RING[rune(in_slice[1])] & 0x30) >> 4);
        chunk[1] = ((B64RING[rune(in_slice[1])] & 0x0F) << 4) | ((B64RING[rune(in_slice[2])] & 0x3C) >> 2);
        chunk[2] = ((B64RING[rune(in_slice[2])] & 0x03) << 6)| (B64RING[rune(in_slice[3])] );
    }
    
    for val,idx in chunk{
        if val > 0{
            temp_chunk := fmt.aprintf("%v",rune(val));
            temp: []string = {ret_val,temp_chunk};
            ret_val = strings.concatenate(temp);
        }
    }

    fmt.println("my chunks are", chunk, " -> ",ret_val);

    //need to recurse 
    alias : string;
    fmt.println("about to recurse. input:",input);
    if len(input) >= 4{
        alias =  input[4:];
    } 
    else{
        alias =  "";
    }

    final :[]string ;
    if alias != "" {
        final = {ret_val,_b64_decode(alias)}; 
    }
    else{
            final = {ret_val};
    }
    return strings.concatenate(final);
}


b64_decode :: proc(input : string) -> string{
    return _b64_decode(strings.trim_space(input));
}

main :: proc () {
    //known values to verify initial functionality
    test_sentences_in  :[]string = {"Man" , "Ma"  , "M"   , "Test Sentence", "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."}; 
    test_sentences_out :[]string = {"TWFu", "TWE=", "TQ==", "VGVzdCBTZW50ZW5jZQo=" ,"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=" };
    
    
    //test
    for _,idx in test_sentences_in{
        fmt.println("Testing: ",test_sentences_in[idx], test_sentences_out[idx]);
        assert(b64_encode(test_sentences_in[idx]) == test_sentences_out[idx]);
        fmt.println("   encode pass");
        assert(b64_decode(test_sentences_out[idx]) == test_sentences_in[idx]);
        fmt.println("   decode pass");
    }
}