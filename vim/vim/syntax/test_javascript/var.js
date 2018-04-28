// CHECK-ALIAS: / <ignore>
// CHECK-ALIAS: _ <none>
// CHECK-ALIAS: v javaScriptVar

// vvvvv _     :CHECK-NEXT-LINE
   const z = w;
// vvv _     :CHECK-NEXT-LINE
   let x = y;
// vvv _     :CHECK-NEXT-LINE
   var q = r;
