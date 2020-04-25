 package  test

import "core:fmt"

 Point_f :: struct{
        x : f32,
y : f32,
    }
 Point_i :: struct{
        x : int,
y : int,
    }
 Rectangle_f :: struct{
        top_right : Point_f,
bot_left : Point_f,
    }
 Rectangle_i :: struct{
        top_right : Point_i,
bot_left : Point_i,
    }

    main :: proc() {
fmt.println("work") ;       
    }