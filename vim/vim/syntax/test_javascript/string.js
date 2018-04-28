// CHECK-ALIAS: ! javaScriptStringError
// CHECK-ALIAS: " javaScriptStringD
// CHECK-ALIAS: ' javaScriptStringS
// CHECK-ALIAS: / <ignore>
// CHECK-ALIAS: \ javaScriptSpecial
// CHECK-ALIAS: _ <none>
// CHECK-ALIAS: f javaScriptFunction

// Simple single-quoted strings.
// _'':CHECK-NEXT-LINE
    ''
// _''':CHECK-NEXT-LINE
    'x'
// _''''''''''''' ______:CHECK-NEXT-LINE
    'hello world'.length

// Single-character escapes.
// _'\\':CHECK-NEXT-LINE
    '\n'
// _''\\'\\'\\'\\'\\'\\'\\'\\'\\'\\'':CHECK-NEXT-LINE
    '_\"_\'_\0_\\_\b_\f_\n_\r_\t_\v_'

// Single-character non-escapes.
// _''\\'\\'\\'\\'\\'\\'':CHECK-NEXT-LINE
    '_\a_\C_\N_\$_\^_\ _'

// Multi-line strings.
// TODO(strager): Implement :CHECK-PREVIOUS-LINE or something.
// _''''''\:CHECK-NEXT-LINE
    'hello\
world'

// Octal escapes (disallowed in strict mode).
// _''!!'!!'!!'':CHECK-NEXT-LINE
    '_\1_\2_\3_'
// _''\\''''':CHECK-NEXT-LINE
    '_\01234'

// Unbracketed Unicode escapes.
// _''\\\\\\'\\\\\\'\\\\\\'':CHECK-NEXT-LINE
    '_\u1234_\u9abf_\uAbCd_'

// Bracketed Unicode escapes.
// _''\\\\\'\\\\\\'\\\\\\\\\\'':CHECK-NEXT-LINE
    '_\u{1}_\u{23}_\u{abcdef}_'

// Hex escapes.
// _''\\\\'\\\\'':CHECK-NEXT-LINE
    '_\x12_\xef_'

// Invalid single-character escapes.
// _''!!'!!'':CHECK-NEXT-LINE
    '_\8_\9_'

// Invalid unbracketed Unicode escapes.
// _''!!!!!'!!!!'!!''':CHECK-NEXT-LINE
    '_\u123_\uff_\ug_'
// _''!!':CHECK-NEXT-LINE
    '_\u'
// _''!!!':CHECK-NEXT-LINE
    '_\u1'
// _''!!!!':CHECK-NEXT-LINE
    '_\u12'
// _''!!!!!':CHECK-NEXT-LINE
    '_\u123'

// Invalid bracketed Unicode escapes.
// _''!!!!'!!!':CHECK-NEXT-LINE
    '_\u{}_\u{'
// _''!!!!!!!!!!!'':CHECK-NEXT-LINE
    '_\u{1234567}_'
// _''!!!!!'':CHECK-NEXT-LINE
    '_\u{g}_'

// Invalid hex escapes.
// _''!!'''':CHECK-NEXT-LINE
    '_\xg3_'
// _''!!':CHECK-NEXT-LINE
    '_\x'
// _''!!!':CHECK-NEXT-LINE
    '_\x1'

// Unterminated strings.
// _'''''''''''':CHECK-NEXT-LINE
    'hello world
//  ffffffff         :CHECK-NEXT-LINE
    function foo() {}

// Double-quoted strings.
// _""""""""""""" ______:CHECK-NEXT-LINE
    "hello world".length
// _""\\"\\"\\"\\"\\"\\"\\"\\"\\"\\"":CHECK-NEXT-LINE
    "_\"_\'_\0_\\_\b_\f_\n_\r_\t_\v_"
