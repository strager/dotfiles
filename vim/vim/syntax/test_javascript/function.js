// CHECK-ALIAS: ( javaScriptParens
// CHECK-ALIAS: ) javaScriptParens
// CHECK-ALIAS: + <none>
// CHECK-ALIAS: / <ignore>
// CHECK-ALIAS: ; <none>
// CHECK-ALIAS: F javaScriptFunction
// CHECK-ALIAS: _ <none>
// CHECK-ALIAS: { javaScriptBraces
// CHECK-ALIAS: } javaScriptBraces

//  FFFFFFFF __________() {:CHECK-NEXT-LINE
    function helloWorld() {
//  }:CHECK-NEXT-LINE
    }

//  FFFFFFFF _(____  ____) {}:CHECK-NEXT-LINE
    function $(arg1, arg2) {}

//   FFFFFFFF () {:CHECK-NEXT-LINE
    (function () {
//  }());:CHECK-NEXT-LINE
    }());

//              (_  _)    _ + _;:CHECK-NEXT-LINE
    const add = (x, y) => x + y;

//                   _    _ ________();:CHECK-NEXT-LINE
    const toString = x => x.toString();
