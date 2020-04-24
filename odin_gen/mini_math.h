#ifndef MINI_MATH_H
#define MINI_MATH_H

#define ODIN_VARS

const float empty;
char *file_name = "mini_math.h";
#define STATIC_PI 3.14159165

#undef  ODIN_VARS


#define ODIN_STRUCTS

typedef struct Point_f{
    float x;
    float y;
}Point_f;

typedef struct Point_i{
    int x;
    int y;
}Point_i;

typedef struct Rectangle_f{
    Point_f top_right;
    Point_f bot_left;
}Rectangle_f;

typedef struct Rectangle_i{
    Point_i top_right;
    Point_i bot_left;
}Rectangle_i;

#undef ODIN_STRUCTS


#define ODIN_FUNCS

int   compute_side_length_i(Rectangle_i r);
float compute_side_length_f(Rectangle_f r);

int   compute_area_i(Rectangle_i* r);
float compute_area_f(Rectangle_f* r);

int    abs_i(int x);
float  abs_f(float x);

#undef ODIN_FUNCS

#ifdef MINI_MATH_IMPLEMENTATION //avoid multiple definitions

int    abs_i(int x)
{
    if(x < 0){
        return -1*x;
    }
    return x;
}

float  abs_f(float x)
{
    if(x < 0.0f){
        return -1.0f*x;
    }
    return x;
}

int compute_side_length_i(Rectangle_i r)
{
    return abs_i(r.bot_left.x - r.top_right.x);
}

float compute_side_length_f(Rectangle_f r)
{
    return abs_f(r.bot_left.y - r.top_right.y);
}

int   compute_area_i(Rectangle_i* r)
{
    int side_length = compute_side_length_i(*r);
    return side_length * side_length;
}

float compute_area_f(Rectangle_f* r)
{
    float side_length = compute_side_length_f(*r);
    return side_length * side_length;
}

#endif  //endif MINI_MATH_IMPLEMENTATION
#endif // endif MINI_MATH_H
