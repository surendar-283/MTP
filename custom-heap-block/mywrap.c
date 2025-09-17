#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <stdio.h>

/* Finalizer: runs when GC frees the block */
static void finalize_myint(value v) {
  int x = *((int *) Data_custom_val(v)); //Data_custom_val returns a void* to the raw value
  printf("Finalizing custom int %d\n", x);
}

/* Define custom operations */
static struct custom_operations myint_ops = {
  "my.myint",
  finalize_myint,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

/* Allocate a custom block holding one int */
// CAMLprim is a macro used by OCaml to mark a C function that will be called from OCaml.
CAMLprim value ml_make_myint(value vx) {
  CAMLparam1(vx); //This macro registers the OCaml parameter vx with the GC.

  //caml_alloc_custom allocates a custom block on the OCaml heap.
  //0->memory used for minor gc and 1->memory used for major gc
  value v = caml_alloc_custom(&myint_ops, sizeof(int), 0, 1);
  *((int *) Data_custom_val(v)) = Int_val(vx);
  CAMLreturn(v);
}

