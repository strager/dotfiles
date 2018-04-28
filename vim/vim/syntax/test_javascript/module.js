// CHECK-ALIAS: * javaScriptImportStar
// CHECK-ALIAS: / <ignore>
// CHECK-ALIAS: _ <none>|javaScriptImportAsNamed|javaScriptImportDefault|javaScriptTemplateSubstitution
// CHECK-ALIAS: ` javaScriptTemplate
// CHECK-ALIAS: a javaScriptImportAs
// CHECK-ALIAS: c javaScriptComment|javaScriptLineComment
// CHECK-ALIAS: f javaScriptImportFrom
// CHECK-ALIAS: i javaScriptImport

// Module import.
// iiiiii               :CHECK-NEXT-LINE
   import 'some_module';

// Import of default.
// iiiiii        ffff          :CHECK-NEXT-LINE
   import assert from 'assert';

// Import of all.
// iiiiii * aa        ffff          :CHECK-NEXT-LINE
   import * as assert from 'assert';

// Import of default and all.
// iiiiii         * aa        ffff          :CHECK-NEXT-LINE
   import azzert, * as assert from 'assert';

// Import of no names.
// iiiiii    ffff          :CHECK-NEXT-LINE
   import {} from 'assert';

// Import of one name.
// iiiiii         ffff          :CHECK-NEXT-LINE
   import {equal} from 'assert';

// Import of default and a name.
// iiiiii                 ffff          :CHECK-NEXT-LINE
   import assert, {equal} from 'assert';

// Import of several name.
// iiiiii                              ffff          :CHECK-NEXT-LINE
   import {equal, notEqual, deepEqual} from 'assert';

// Import of an aliased name.
// iiiiii              aa        ffff          :CHECK-NEXT-LINE
   import {strictEqual as equal} from 'assert';

// Import of several aliased names.
// iiiiii              aa                       aa           ffff          :CHECK-NEXT-LINE
   import {strictEqual as equal, strictNotEqual as notEqual} from 'assert';

// Import with inline comments.
// FIXME(strager)
// cccciiiiiicccc______ccccffffcccc        cccc:DISABLED-CHECK-NEXT-LINE
   /**/import/**/assert/**/from/**/'assert'/**/
// FIXME(strager)
// cccciiiiiicccc*ccccaacccc      cccc cccc cccc           ccccaacccc     cccc cccc              ccccaacccc        cccc ccccffffcccc        cccc:DISABLED-CHECK-NEXT-LINE
   /**/import/**/*/**/as/**/assert/**/,/**/{/**/strictEqual/**/as/**/equal/**/,/**/strictNotEqual/**/as/**/notEqual/**/}/**/from/**/'assert'/**/

// Multi-line import.
// iiiiii  :CHECK-NEXT-LINE
   import {
//               aa       :CHECK-NEXT-LINE
     strictEqual as equal,
//                  aa          :CHECK-NEXT-LINE
     strictNotEqual as notEqual,
//   ffff                       :CHECK-NEXT-LINE
   } from 'assert';

// Multi-line import with inline comments.
// iiiiii  :CHECK-NEXT-LINE
   import {
//   cccccccccccccccc:CHECK-NEXT-LINE
     // Test comment.
//               aa        ccccccccccccccccccc:CHECK-NEXT-LINE
     strictEqual as equal, /* Test comment. */
//                  aa           ccccccccccccccccccc:CHECK-NEXT-LINE
     strictNotEqual as notEqual, /* Test comment. */
//   ffff                       :CHECK-NEXT-LINE
   } from 'assert';

// Incomplete imports.
// iiiiii:CHECK-NEXT-LINE
   import
// iiiiii __:CHECK-NEXT-LINE
   import as
// iiiiii *:CHECK-NEXT-LINE
   import *
// iiiiii * aa:CHECK-NEXT-LINE
   import * as
// iiiiii     ffff:CHECK-NEXT-LINE
   import foo from
// iiiiii   :CHECK-NEXT-LINE
   import {x
// iiiiii    aa:CHECK-NEXT-LINE
   import {x as
// iiiiii    aa  :CHECK-NEXT-LINE
   import {x as y
// iiiiii     :CHECK-NEXT-LINE
   import {x};
// iiiiii     ffff:CHECK-NEXT-LINE
   import {x} from
// iiiiii     ffff :CHECK-NEXT-LINE
   import {x} from;

// 'import' is a context-insensitive keyword.
//     iiiiii :CHECK-NEXT-LINE
   let import = null;

// 'from' and 'as' are context-sensitive keywords.
//          ____     :CHECK-NEXT-LINE
   function from() {}
//          __     :CHECK-NEXT-LINE
   function as() {}
//     ____   __     :CHECK-NEXT-LINE
   let from = as + 1;
// iiiiii ____ ffff   :CHECK-NEXT-LINE
   import from from x;
// iiiiii __ ffff   :CHECK-NEXT-LINE
   import as from x;
// iiiiii * aa ____:CHECK-NEXT-LINE
   import * as from
// iiiiii   aa __ ffff   :CHECK-NEXT-LINE
   import * as as from x;
// FIXME(strager)
// iiiiii  __ aa __  ffff :DISABLED-CHECK-NEXT-LINE
   import {as as as} from;
// iiiiii * aa ____ ffff:CHECK-NEXT-LINE
   import * as from from
//  `````` ```` ``   ____   __  :CHECK-NEXT-LINE
   `import from as ${from + as}`
// cccccccccccccccccccc:CHECK-NEXT-LINE
   /* import as from */

// 'import' is word-matched.
// _________ _ ____    :CHECK-NEXT-LINE
   important x from '';
// _______ _ ____    :CHECK-NEXT-LINE
   simport x from '';

// 'from' is word-matched.
//          _____    :CHECK-NXT-LINE
   import x froms '';

// 'as' is word-matched.
//           ___            :CHECK-NEXT-LINE
   import {x sas y} from '';
