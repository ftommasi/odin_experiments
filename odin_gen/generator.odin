package generator

import "core:fmt"
import "core:strings"
import "core:os"

DEBUG_MODE :: true;

//some template string that we will replace keywords ({PACKAGE_NAME},{STRUCTS},{VARIABLES}) with odin code snippets based on read file
ODIN_TEMPLATE_STRING :: `//this code is auto-generated from existing files.
//There may be some syntacic oddities based on the original file formatting, but the layout and function will be correct.
//edit at your own risk

package {PACKAGE_NAME}
when ODIN_OS=="windows" do foreign import mini_math "{PACKAGE_NAME}.lib";
when ODIN_OS=="linux"   do foreign import mini_math "{PACKAGE_NAME}.a";

{STRUCTS}

foreign {PACKAGE_NAME} {
    {VARS}
    {FUNCS}
}`;


IMPLEMENTATION_TEMPLATE_STRING :: `//this code is auto-generated from existing files.
//There may be some syntacic oddities based on the original file formatting, but the layout and function will be correct.
//edit at your own risk


#include "{HEADER_FILENAME}"
{IMPLEMENTATION}`;


ODIN_STRUCT_STRING :: `{STRUCT_NAME} :: struct {
    {MEMBERS}
}`;



debug_print :: proc(args : ..any){
    if DEBUG_MODE{
        fmt.println(args);
    }
}

update_implementation_file :: proc(pkg_name,header_filename : string) -> (ret_str : string,ret_bool : bool){
    implementation_file_template :: IMPLEMENTATION_TEMPLATE_STRING;
    file_data,success := os.read_entire_file(header_filename);
    if success{
        willthiswork := string(file_data);
        defer delete(willthiswork);
       
        //read file up until `#ifdef PACKAGE_NAME_IMPLEMENTATION` then copy paste into new file
        interim,worked := strings.replace_all(implementation_file_template,"{HEADER_FILENAME}",header_filename);
        defer delete(interim);

        split_by_space := strings.split(willthiswork, " ");
        defer delete(split_by_space);

        sub_string_marker : int;
        for token,idx in split_by_space{
            if strings.contains(token,"IMPLEMENTATION"){
                sub_string_marker = idx+1; //get the next token after the #define xxx_IMPLEMENTATION. This may be a comment, a new line, or empty space.
                break;
            }
        }

        implementation := strings.join(split_by_space[sub_string_marker:]," ");
        defer delete(implementation);

        FINAL_IMPLEMENTATION,worked_2 := strings.replace_all(interim,"{IMPLEMENTATION}",implementation);
        if worked_2
        {
            ret_str  = FINAL_IMPLEMENTATION;
            ret_bool = true;
            return;
        }
        ret_str  = "FAIL WRITE";
        ret_bool = false;
        return;
    }
    ret_str  = "FAIL readfile";
    ret_bool = false;
    return;
}

generate_implementation_file :: proc(package_name : string){
    //this portion generates the .c definition file for a SHL .h file
    template_string ::IMPLEMENTATION_TEMPLATE_STRING;
    replaced,worked := strings.replace_all(template_string,"{PACKAGE_NAME}",package_name);
    defer delete(replaced);
    if worked{
        header_file := strings.concatenate(([]string){package_name,".h"});
        defer delete(header_file);

        source_file := strings.concatenate(([]string){package_name,".c"});
        defer delete(source_file);

        replaced,worked = update_implementation_file(package_name,header_file);
        defer delete(replaced);

        if worked{
            split_by_space := strings.split(replaced, "\n");
            defer delete(split_by_space);

            //delete last 2 lines of SHL .h file
            //this will only work on my style of formatting SHL. this may cause bugs
            no_endifs := strings.join(split_by_space[:len(split_by_space)-3],"\n");
            defer delete(no_endifs);

            //debug_print(no_endifs);
            worked_3 := os.write_entire_file(source_file,transmute([]byte)no_endifs);
        }
    }
}


generate_odin_bridge :: proc(){

}


process_sub_section :: proc(sub_name,SPLIT_TOKEN : string, split_by_token : []string, curr_idx : int) -> (final_idx : int ,joined : string){
    final_idx = curr_idx;
    final_idx += 1;
    start_marker := final_idx; //+1?
    for{
        token := split_by_token[final_idx];
        if strings.contains(token,sub_name){
            end_marker := final_idx-1;
            joined = strings.join(split_by_token[start_marker : end_marker],"\n");
            break;
        }
        final_idx += 1;
    }
    return ;
}

parse_struct_string :: proc(struct_string : string) -> [dynamic]string{
    //debug_print(struct_string);
    STRUCT_TEMPLATE :: `{STRUCT_NAME} :: struct{
        {MEMBERS}
    }`;
    ret_val : [dynamic]string;
    struct_decl_string : string; //= make(string) ;
    struct_name : string;
    final_worked : bool;
    //get struct name

    //get rid of typedef keyword because its being a pain in my ass and its irrelevant to Odin
        //its okay to do this because we are only doing this in structs section. typedefs in vars wont be affected
    no_typedefs,typedef_work := strings.replace_all(struct_string,"typedef","");
    defer delete(no_typedefs);
   
    split_by_space := strings.split(no_typedefs, "struct");
    defer delete(split_by_space);

    //because we tokenized on the word struct there will always be empty space on the 0th item
    for token,idx in split_by_space[1:]{
        split_by_open_curly := strings.split(token, "{");
        defer delete(split_by_open_curly);
       
        split_by_close_curly := strings.split(split_by_open_curly[1], "}");
        defer delete(split_by_close_curly);
       
        no_nrls,no_nls_work := strings.replace_all(split_by_close_curly[0],"\n","");
        defer delete(no_nrls);
        
        no_nls,no_nl_work := strings.replace_all(no_nrls,"\r","");
        defer delete(no_nls);


//        no_colons := strings.join(no_nls, "");
//        defer delete(no_colons);

        all_members:= strings.split(no_nls,";");
        defer delete(all_members);
       
        struct_name = split_by_open_curly[0];
       
        with_struct,struct_worked := strings.replace_all(STRUCT_TEMPLATE,"{STRUCT_NAME}",struct_name);
        defer delete(with_struct);
       
        bridged_members :[dynamic]string;
        MEMBER_TEMPLATE :: `{MEMBER_NAME} : {MEMBER_TYPE},`;
        valid : bool = true;
        for member in all_members{
            walk := 0;
            for{
                if walk > len(member)-1{
                    valid = false;
                    break;
                }
                if member[walk] != ' '{
                    break;
                }
                walk += 1;
            }
            if valid{
            //debug_print("now looking at:",member);
                split_by_close_space := strings.split(member[walk:], " ");
                defer delete(split_by_close_space);

                tokens : [dynamic] string;
                member_type :string; // = split_by_close_space[0];
                member_name :string; //= split_by_close_space[1];
                valid : bool = true;
                idx := 0;
                token := split_by_close_space[0];
                walk = 0;
                for{
                    if split_by_close_space[walk] != "" && split_by_close_space[walk] != "\r"{
                        debug_print("walk->",split_by_close_space[walk]);
                        break;
                    }
                    walk+=1;
                }
                
                //debug_print(split_by_close_space[walk:]);
                for valid{

                   if idx > len(split_by_close_space) - 1{
                       valid = false;
                       break;
                   } 
                    token = split_by_close_space[idx];
                    if token != "" {
                        //we always know in C its type name;
                        member_type = token;
                        //walk until we get to name (there could be a lot of ---)
                        for{
                            
                            idx += 1;
                            if idx > len(split_by_close_space)-1{
                                valid = false;
                                break;
                            }
                            token = split_by_close_space[idx];
                            if token != ""{
                                member_name = token;
                                break;
                            }
                        }
                    }
                    idx += 1;
                }

                //debug_print("memb->",member_name);
                //debug_print("type->",member_type);
                bridge_type,memrepl_worked := strings.replace_all(MEMBER_TEMPLATE,"{MEMBER_TYPE}",member_type);
                defer delete(bridge_type);

                bridge_entry,tpye_worked := strings.replace_all(bridge_type,"{MEMBER_NAME}",member_name);
                //debug_print(bridge_entry);
                //defer delete(bridged_entry);
                //debug_print("appending ->",bridge_entry);
                append(&bridged_members,bridge_entry);
            }
        }

        bm_joined := strings.join(bridged_members[:],"\n");

        struct_decl_string,final_worked = strings.replace_all(with_struct,"{MEMBERS}",bm_joined);
        append(&ret_val,struct_decl_string);
        //debug_print(struct_decl_string);
       
    }

    //get all struct members
    //SOO MUCH SPLITTTING!!!!!!!!!!!!!
   
    return ret_val;
}



main :: proc() {
    package_name := "mini_math";
    SPLIT_TOKEN :: "\n";
    //generate_implementation_file(package_name);
    //genereate_odin_bridge();

    //this portion generates the "odin bridge" file for the compiled c static library
    odin_template := ODIN_TEMPLATE_STRING;
    header_file := strings.concatenate(([]string){package_name,".h"});
    defer delete(header_file);

    //here we update structs
    file_data,success := os.read_entire_file(header_file);
    defer delete(file_data);
    if success{
        file_as_string:= string(file_data);
        //defer delete(file_as_string); //<- This core dumps because its a cast and file_data get deleted above.
       
        split_by_token := strings.split(file_as_string, SPLIT_TOKEN);
        defer delete(split_by_token);

        struct_strings,funcs_strings,vars_strings :[dynamic]string;
         
        struct_start_marker,struct_end_marker : int;
        funcs_start_marker ,funcs_end_marker  : int;
        vars_start_marker  ,vars_end_marker   : int;
        parsing : bool = true;

        idx : int = 0;
        //decompose into struct, procs, and vars
        for parsing{
            token := split_by_token[idx];
            //if we hit #define XXXX_IMPLEMENTATION we are done
            if strings.contains(token,"IMPLEMENTATION"){
                parsing = false;
            }
           
            if strings.contains(token,"ODIN_STRUCTS"){
                new_idx, struct_joined := process_sub_section("ODIN_STRUCTS",SPLIT_TOKEN, split_by_token, idx);              
                idx = new_idx;
                append(&struct_strings,struct_joined);
            }
            if strings.contains(token,"ODIN_FUNCS"){
                new_idx, funcs_joined := process_sub_section("ODIN_FUNCS",SPLIT_TOKEN, split_by_token, idx);              
                idx = new_idx;
                append(&funcs_strings,funcs_joined);
            }
            if strings.contains(token,"ODIN_VARS"){
                new_idx, vars_joined := process_sub_section("ODIN_VARS",SPLIT_TOKEN, split_by_token, idx);              
                idx = new_idx;
                append(&vars_strings,vars_joined);
            }
            idx += 1;
        }
       
        parsed_structs := parse_struct_string(struct_strings[0]); //this gives the right result
        defer delete(parsed_structs);
       
        final_structs := strings.join(parsed_structs[:],"\n");
        defer delete(final_structs);
        structs_worked := os.write_entire_file("odin_structs.odin",transmute([]byte)final_structs);
        //debug_print("structs:",struct_strings);
        //debug_print("funcs  :", funcs_strings);
        //debug_print("vars   :",  vars_strings);
    }
}