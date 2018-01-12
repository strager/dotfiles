#!/usr/bin/env bash

set -e
set -o pipefail
set -u

test_dir_path="$(cd "$(dirname "${0}")" && pwd || exit 1)"
jq_script_path="${test_dir_path}/flow.jq"
scratch_dir_path="$(mktemp -d /tmp/test_flow_jq.XXXXXXXX || exit 1)"

cd "${scratch_dir_path}"

test_no_errors() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[],"passed":true}
EOF
    cat >expected.txt <<'EOF'
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_parse_error() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"kind":"parse","level":"error","suppressions":[],"message":[{"context":"suite.test'money is earned after defeating Lt. Surge', (): void => {","descr":"Unexpected string","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":58,"column":11,"offset":1490},"end":{"line":58,"column":53,"offset":1533}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":58,"endline":58,"start":11,"end":53}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/test/money.js:58:11: error: Unexpected string
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_parse_error_2() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"kind":"parse","level":"error","suppressions":[],"message":[{"context":"  }))","descr":"Unexpected token )","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":70,"column":5,"offset":1876},"end":{"line":70,"column":5,"offset":1877}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":70,"endline":70,"start":5,"end":5}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/test/money.js:70:5: error: Unexpected token )
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_single_name_error() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"kind":"infer","level":"error","suppressions":[],"message":[{"context":"export function getMoneyEarnedFromTrainerBattle (info: {|class: TrainerClazz, lastMonsterLevel: number|}): Money {","descr":"TrainerClazz","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/money.js","type":"SourceFile","start":{"line":8,"column":65,"offset":186},"end":{"line":8,"column":76,"offset":198}},"path":"/Users/mg/Projects/pokemon-router/lib/money.js","line":8,"endline":8,"start":65,"end":76},{"context":null,"descr":"Could not resolve name","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/lib/money.js:8:65: error: TrainerClazz. Could not resolve name
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_single_import_error() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"kind":"infer","level":"error","suppressions":[],"message":[{"context":"import {doesnotexist} from './util'","descr":"Named import from module `./util`","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/money.js","type":"SourceFile","start":{"line":5,"column":9,"offset":101},"end":{"line":5,"column":20,"offset":113}},"path":"/Users/mg/Projects/pokemon-router/lib/money.js","line":5,"endline":5,"start":9,"end":20},{"context":null,"descr":"This module has no named export called `doesnotexist`.","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/lib/money.js:5:9: error: Named import from module `./util`. This module has no named export called `doesnotexist`.
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_multi_piece_error() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"kind":"infer","level":"error","suppressions":[],"message":[{"context":"    case 'Rock': return 99","descr":"string literal `Rock`","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/money.js","type":"SourceFile","start":{"line":14,"column":10,"offset":421},"end":{"line":14,"column":15,"offset":427}},"path":"/Users/mg/Projects/pokemon-router/lib/money.js","line":14,"endline":14,"start":10,"end":15},{"context":null,"descr":"This type is incompatible with","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0},{"context":"function getMoneyEarnedPerLevelForTrainerClass (c: TrainerClass): Money {","descr":"string enum","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/money.js","type":"SourceFile","start":{"line":12,"column":52,"offset":374},"end":{"line":12,"column":63,"offset":386}},"path":"/Users/mg/Projects/pokemon-router/lib/money.js","line":12,"endline":12,"start":52,"end":63}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/lib/money.js:14:10: error: string literal `Rock`. This type is incompatible with
/Users/mg/Projects/pokemon-router/lib/money.js:12:52: note: string enum
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_multi_piece_error_2() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"extra":[{"message":[{"context":null,"descr":"Property `a` is incompatible:","type":"Blame","path":"","line":0,"endline":0,"start":1,"end":0}],"children":[{"message":[{"context":"  let l: {|a: number|} = {a: ''}","descr":"string","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":19,"column":30,"offset":509},"end":{"line":19,"column":31,"offset":511}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":19,"endline":19,"start":30,"end":31},{"context":null,"descr":"This type is incompatible with","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0},{"context":"  let l: {|a: number|} = {a: ''}","descr":"number","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":19,"column":15,"offset":494},"end":{"line":19,"column":20,"offset":500}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":19,"endline":19,"start":15,"end":20}]}]}],"kind":"infer","level":"error","suppressions":[],"message":[{"context":"  let l: {|a: number|} = {a: ''}","descr":"object literal","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":19,"column":26,"offset":505},"end":{"line":19,"column":32,"offset":512}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":19,"endline":19,"start":26,"end":32},{"context":null,"descr":"This type is incompatible with","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0},{"context":"  let l: {|a: number|} = {a: ''}","descr":"object type","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":19,"column":10,"offset":489},"end":{"line":19,"column":22,"offset":502}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":19,"endline":19,"start":10,"end":22}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/test/money.js:19:30: error: Property `a` is incompatible: string. This type is incompatible with
/Users/mg/Projects/pokemon-router/test/money.js:19:15: note: number
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_multi_piece_error_3() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"extra":[{"message":[{"context":"  constructor (route: $ReadOnlyArray<RouteEntry>) {","descr":"function expects more arguments","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/route.js","type":"SourceFile","start":{"line":41,"column":3,"offset":864},"end":{"line":44,"column":3,"offset":966}},"path":"/Users/mg/Projects/pokemon-router/lib/route.js","line":41,"endline":44,"start":3,"end":3}]}],"kind":"infer","level":"error","suppressions":[],"message":[{"context":"    return new RouteCursor()","descr":"new `RouteCursor`","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/route.js","type":"SourceFile","start":{"line":90,"column":12,"offset":2168},"end":{"line":90,"column":28,"offset":2185}},"path":"/Users/mg/Projects/pokemon-router/lib/route.js","line":90,"endline":90,"start":12,"end":28},{"context":null,"descr":"Called with too few arguments","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/lib/route.js:90:12: error: new `RouteCursor`. Called with too few arguments
/Users/mg/Projects/pokemon-router/lib/route.js:41:3: note: function expects more arguments
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_multi_piece_multi_file_error() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"kind":"infer","level":"error","suppressions":[],"message":[{"context":"  assert.equal(getLevelForExperience('Dugtrio', ''), 57)","descr":"string","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/experience.js","type":"SourceFile","start":{"line":58,"column":49,"offset":1743},"end":{"line":58,"column":50,"offset":1745}},"path":"/Users/mg/Projects/pokemon-router/test/experience.js","line":58,"endline":58,"start":49,"end":50},{"context":null,"descr":"This type is incompatible with the expected param type of","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0},{"context":"export function getLevelForExperience (species: Species, experience: number): number {","descr":"number","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/experience.js","type":"SourceFile","start":{"line":34,"column":70,"offset":1216},"end":{"line":34,"column":75,"offset":1222}},"path":"/Users/mg/Projects/pokemon-router/lib/experience.js","line":34,"endline":34,"start":70,"end":75}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/test/experience.js:58:49: error: string. This type is incompatible with the expected param type of
/Users/mg/Projects/pokemon-router/lib/experience.js:34:70: note: number
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_multi_piece_multi_file_error_2() {
    cat >input.json <<'EOF'
{"flowVersion":"0.61.0","errors":[{"extra":[{"message":[{"context":null,"descr":"Property `class` is incompatible:","type":"Blame","path":"","line":0,"endline":0,"start":1,"end":0}],"children":[{"message":[{"context":"    class: 'BugCatcher',","descr":"string","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":20,"column":12,"offset":548},"end":{"line":20,"column":23,"offset":560}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":20,"endline":20,"start":12,"end":23},{"context":null,"descr":"This type is incompatible with","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0},{"context":"export function getMoneyEarnedFromTrainerBattle (info: {|class: TrainerClass, lastMonsterLevel: number|}): Money {","descr":"string enum","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/money.js","type":"SourceFile","start":{"line":8,"column":65,"offset":186},"end":{"line":8,"column":76,"offset":198}},"path":"/Users/mg/Projects/pokemon-router/lib/money.js","line":8,"endline":8,"start":65,"end":76}]}]}],"kind":"infer","level":"error","suppressions":[],"message":[{"context":"  const money: Money = getMoneyEarnedFromTrainerBattle({","descr":"object literal","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/test/money.js","type":"SourceFile","start":{"line":19,"column":56,"offset":535},"end":{"line":22,"column":3,"offset":589}},"path":"/Users/mg/Projects/pokemon-router/test/money.js","line":19,"endline":22,"start":56,"end":3},{"context":null,"descr":"This type is incompatible with the expected param type of","type":"Comment","path":"","line":0,"endline":0,"start":1,"end":0},{"context":"export function getMoneyEarnedFromTrainerBattle (info: {|class: TrainerClass, lastMonsterLevel: number|}): Money {","descr":"object type","type":"Blame","loc":{"source":"/Users/mg/Projects/pokemon-router/lib/money.js","type":"SourceFile","start":{"line":8,"column":56,"offset":177},"end":{"line":8,"column":104,"offset":226}},"path":"/Users/mg/Projects/pokemon-router/lib/money.js","line":8,"endline":8,"start":56,"end":104}]}],"passed":false}
EOF
    cat >expected.txt <<'EOF'
/Users/mg/Projects/pokemon-router/test/money.js:20:12: error: Property `class` is incompatible: string. This type is incompatible with
/Users/mg/Projects/pokemon-router/lib/money.js:8:65: note: string enum
EOF
    jq --raw-output --from-file "${jq_script_path}" input.json >actual.txt
    diff -u expected.txt actual.txt
}

test_no_errors
test_parse_error
test_parse_error_2
test_single_name_error
test_single_import_error
test_multi_piece_error
test_multi_piece_error_2
test_multi_piece_error_3
test_multi_piece_multi_file_error
test_multi_piece_multi_file_error_2
