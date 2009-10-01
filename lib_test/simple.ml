(*pp camlp4o -I ../lib -I `ocamlfind query type-conv` pa_type_conv.cmo pa_orm.cma *)

TYPE_CONV_PATH "Simple"
open Printf

type x = {
  foo: int;
  bar: string
} with
orm(
 debug: all;
 dot: "simple.dot";
 modname: "My_simple"
)

open My_simple
open OUnit
open Test_utils

let name = "simple.db"

let x = { foo = (Random.int 100); bar="hello world" }

let test_init () =
  ignore(open_db init name);
  ignore(open_db ~rm:false init name);
  ignore(open_db ~rm:false init name)

let test_save () =
  let db = open_db init name in
  x_save db x

let test_update () =
  let db = open_db init name in
  x_save db x;
  x_save db x

let test_get () =
  let db = open_db ~rm:false init name in
  let i = x_get db in
  "2 in db" @? (List.length i = 1);
  let i = List.hd i in
  "values match" @? (i.foo = x.foo && (i.bar = x.bar))

let test_save_get () =
  let db = open_db init name in
  x_save db x;
  let i = x_get db in
  "1 in db" @? (List.length i = 1);
  let i = List.hd i in
  "structurally equal after get" @? ( x == i)

let test_delete () =
  let db = open_db ~rm:false init name in
  let x1 = match x_get db with [x] -> x |_ -> assert false in
  let x2 = { foo = (Random.int 100); bar="x2" } in
  let x3 = { foo = (Random.int 100); bar="x3" } in
  "1 in db" @? (List.length (x_get db) = 1);
  x_delete db x1;
  "0 in db" @? (List.length (x_get db) = 0);
  x_save db x1;
  x_save db x2;
  x_save db x3;
  "3 in db" @? (List.length (x_get db) = 3);
  x_delete db x2;
  "2 in db" @? (List.length (x_get db) = 2);
  match x_get db with
  [a3;a1] -> "equal" @? (a3=x3 && a1=x1)
  |_ -> assert false
  
let suite = [
  "simple_init" >:: test_init;
  "simple_save" >:: test_save;
  "simple_update" >:: test_update;
  "simple_get" >:: test_get;
  "simple_save_get" >:: test_save_get;
  "simple_delete" >:: test_delete;
]

