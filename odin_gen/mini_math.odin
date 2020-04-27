//this code is auto-generated from existing files.
//There may be some syntacic oddities based on the original file formatting, but the layout and function will be correct.
//edit at your own risk

package {PACKAGE_NAME}

import "core:fmt"

when ODIN_OS=="windows" do foreign import mini_math "{PACKAGE_NAME}.lib";
when ODIN_OS=="linux"   do foreign import mini_math "{PACKAGE_NAME}.a";

 Point_f :: struct{
        x : float,
y : float,
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

foreign {PACKAGE_NAME} {
    {VARS}
    {FUNCS}
}

main ::proc(){
    fmt.println("Auto generate successful");
}