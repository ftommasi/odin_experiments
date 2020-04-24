package mini_math_test

import "core:fmt"

when ODIN_OS=="windows" do foreign import mini_math "mini_math.lib";
when ODIN_OS=="linux"   do foreign import mini_math "mini_math.a";


Point_i :: struct {
   x : i32,
   y : i32,        
}
Point_f :: struct {
   x : f32,
   y : f32,
}

Rectangle_i :: struct {
   top_right : Point_i,
   bot_left : Point_i,
}
Rectangle_f :: struct {
   top_right : Point_f,
   bot_left  : Point_f,
}




foreign mini_math{
    compute_side_length_i :: proc "c" (r : Rectangle_i ) -> i32  ---;
    compute_side_length_f :: proc "c" (r : Rectangle_f ) -> f32  ---;

    compute_area_i :: proc "c"(r : ^Rectangle_i ) -> i32  ---;
    compute_area_f :: proc "c"(r : ^Rectangle_f ) -> f32  ---;

    abs_i :: proc "c"(x : i32) -> i32 ---;
    abs_f :: proc "c"(x : f32) -> f32 ---;
}


main :: proc() {
    //dummy structs
    int_r : Rectangle_i;
    flt_r : Rectangle_f;

    TR_i : Point_i;
    TR_i.x = 4;
    TR_i.y = 4;
    BL_i : Point_i;
    BL_i.x = 2;
    BL_i.y = 2;
    int_r.top_right = TR_i;
    int_r.bot_left  = BL_i;

    TR_f : Point_f;
    TR_f.x = 4.0;
    TR_f.y = 4.0;
    BL_f : Point_f;
    BL_f.x = 2.0;
    BL_f.y = 2.0;
    flt_r.top_right = TR_f;
    flt_r.bot_left  = BL_f;
    
    //asserts
    assert(abs_f(-2.0) == 2.0);
    assert(abs_i(2) == 2);
    assert(abs_f(2.0) == 2.0);

    assert(compute_side_length_i(int_r) == 2);
    assert(compute_side_length_f(flt_r) == 2.0);

    assert(compute_area_i(&int_r) == 4);
    assert(compute_area_f(&flt_r) == 4.0);


}