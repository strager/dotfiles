// CHECK-ALIAS: ! javaScriptTemplateError
// CHECK-ALIAS: ' javaScriptStringS
// CHECK-ALIAS: . <none>
// CHECK-ALIAS: / <ignore>
// CHECK-ALIAS: 0 javaScriptNumber
// CHECK-ALIAS: \ javaScriptTemplateEscape
// CHECK-ALIAS: _ <none>|javaScriptTemplateSubstitution
// CHECK-ALIAS: ` javaScriptTemplate
// CHECK-ALIAS: b javaScriptBraces
// CHECK-ALIAS: c javaScriptComment
// CHECK-ALIAS: k javaScript

// TODO(strager): Separate these so they can be highlighted independently.
// CHECK-ALIAS: $ javaScriptTemplateSubstitutionDelimiter
// CHECK-ALIAS: { javaScriptTemplateSubstitutionDelimiter
// CHECK-ALIAS: } javaScriptTemplateSubstitutionDelimiter

// Simple templates.
// ``:CHECK-NEXT-LINE
   ``
// ```:CHECK-NEXT-LINE
   `x`
// `````````````:CHECK-NEXT-LINE
   `hello world`.length
// `````````````:CHECK-NEXT-LINE
   `hello$world`

// Single-character escapes.
// _`\\`:CHECK-NEXT-LINE
    `\n`
// _``\\`\\`\\`\\`\\`\\`\\`\\`\\`\\``:CHECK-NEXT-LINE
    `_\"_\'_\0_\\_\b_\f_\n_\r_\t_\v_`

// Single-character non-escapes.
// _``\\`\\`\\`\\`\\`\\``:CHECK-NEXT-LINE
    `_\a_\C_\N_\$_\^_\ _`

// Multi-line templates.
// TODO(strager): Implement :CHECK-PREVIOUS-LINE or something.
// ``````:CHECK-NEXT-LINE
   `hello
world`
// ``````\:CHECK-NEXT-LINE
   `hello\
world`

// Simple substitution.
// _``````${00}`````:CHECK-NEXT-LINE
    `hello${42}world`
// _``````${  '''''''''''''  }`````:CHECK-NEXT-LINE
    `hello${  ' beautiful '  }world`

// Multiple substitutions.
// _``````${00}`````:CHECK-NEXT-LINE
    `hello${42}world`
// _`${_}```${_}```${___}`:CHECK-NEXT-LINE
    `${a} + ${b} = ${sum}`

// Nested substitutions.
// _``````${    ``${ }`${ }`` }`````${    ``${ }`${ }`` }``:CHECK-NEXT-LINE
    `from ${foo(` ${a} ${b} `)} til ${bar(` ${c} ${d} `)}!`

// Comments inside substitutions.
// `${ ccccccccccc }`:CHECK-NEXT-LINE
   `${ /* neat! */ }`

// TODO(strager): Hex escapes.
// TODO(strager): Bracketed and unbracketed Unicode escapes.

// Invalid single-character escapes.
// _``!!`!!`!!`!!``:CHECK-NEXT-LINE
    `_\1_\2_\8_\9_`

// Template substitution delimiters are not recognized outside templates.
//       .b b:CHECK-NEXT-LINE
   class ${ }
