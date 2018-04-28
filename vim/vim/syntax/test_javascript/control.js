// CHECK-ALIAS: / <ignore>
// CHECK-ALIAS: _ <none>
// CHECK-ALIAS: b javaScriptBranch
// CHECK-ALIAS: c javaScriptConditional
// CHECK-ALIAS: e javaScriptException
// CHECK-ALIAS: k javaScriptRepeat
// CHECK-ALIAS: l javaScriptLabel
// CHECK-ALIAS: v javaScriptVar
// CHECK-ALIAS: w javaScriptRepeat

// cc      :CHECK-NEXT-LINE
   if (a) {
//   cccc cc      :CHECK-NEXT-LINE
   } else if (b) {
//   cccc  :CHECK-NEXT-LINE
   } else {
   }

// wwwww      :CHECK-NEXT-LINE
   while (a) {}

// ww  :CHECK-NEXT-LINE
   do {
//   wwwww     :CHECK-NEXT-LINE
   } while (a);

// www             :CHECK-NEXT-LINE
   for (a; b; c) {}
// www    kk      :CHECK-NEXT-LINE
   for (a in b) {}
// www    kk      :CHECK-NEXT-LINE
   for (a of b) {}
// www  vvvvv   kk      :CHECK-NEXT-LINE
   for (const a of b) {}

//         www       :CHECK-NEXT-LINE
   myloop: for (;;) {
//   bbbbbbbb:CHECK-NEXT-LINE
     continue
//   bbbbb:CHECK-NEXT-LINE
     break
   }

// 'of' is a context-sensitive keyword.
// FIXME(strager)
//     __   __   :DISABLED-CHECK-NEXT-LINE
   let of = of();
//      __ kk __    :DISABLED-CHECK-NEXT-LINE
   for (of of of) {}
//          __ kk __    :DISABLED-CHECK-NEXT-LINE
   for (let of of of) {}
//      __  __  __    :DISABLED-CHECK-NEXT-LINE
   for (of; of; of) {}
//        __      :DISABLED-CHECK-NEXT-LINE
   for (; of; ) {}

// cccccc      :CHECK-NEXT-LINE
   switch (a) {
//   llll _ :CHECK-NEXT-LINE
     case b:
//   llll _ :CHECK-NEXT-LINE
     case c:
//     bbbbb:CHECK-NEXT-LINE
       break;
//   lllllll:CHECK-NEXT-LINE
     default:
  }

// eee  :CHECK-NEXT-LINE
   try {
//   eeeee      :CHECK-NEXT-LINE
   } catch (e) {
//   eeeeeee  :CHECK-NEXT-LINE
   } finally {
   }
