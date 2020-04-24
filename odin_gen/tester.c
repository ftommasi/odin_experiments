//std includes
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

//user includes
#define MINI_MATH_IMPLEMENTATION
#include "mini_math.h"


int main(int argc, char** argv)
{
    //Dummy Structs for testing
    Rectangle_i int_r;
    Rectangle_f flt_r;

    Point_i TR_i;
    TR_i.x = 4;
    TR_i.y = 4;
    Point_i BL_i;
    BL_i.x = 2;
    BL_i.y = 2;
    int_r.top_right = TR_i;
    int_r.bot_left  = BL_i;

    Point_f TR_f;
    TR_f.x = 4.0f;
    TR_f.y = 4.0f;
    Point_f BL_f;
    BL_f.x = 2.0f;
    BL_f.y = 2.0f;
    flt_r.top_right = TR_f;
    flt_r.bot_left  = BL_f;

    //test all these functions 
    assert(abs_f(-2.0f) == 2.0f);
    assert(abs_i(2) == 2);
    assert(abs_f(2.0f) == 2.0f);

    assert(compute_side_length_i(int_r) == 2);
    assert(compute_side_length_f(flt_r) == 2.0f);

    assert(compute_area_i(&int_r) == 4);
    assert(compute_area_f(&flt_r) == 4.0f);


}