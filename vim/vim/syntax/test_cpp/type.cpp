// CHECK-ALIAS: / <ignore>
// CHECK-ALIAS: _ <none>
// CHECK-ALIAS: b cType
// CHECK-ALIAS: c cStorageClass
// CHECK-ALIAS: m cppModifier
// CHECK-ALIAS: s cppStructure
// CHECK-ALIAS: t cInferredType

// bbbb__ :CHECK-NEXT-LINE
   char x;
// tttttt_______ :CHECK-NEXT-LINE
   string my_str;

// tttttt________ :CHECK-NEXT-LINE
   string *my_str;
// tttttt________ :CHECK-NEXT-LINE
   string* my_str;
// tttttt________ :CHECK-NEXT-LINE
   string &my_str;
// tttttt________ :CHECK-NEXT-LINE
   string& my_str;
// tttttt_________ :CHECK-NEXT-LINE
   string &&my_str;
// tttttt_________ :CHECK-NEXT-LINE
   string&& my_str;

// ttttttttttt_______ :CHECK-NEXT-LINE
   std::string my_str;
// tttttttt_______ :CHECK-NEXT-LINE
   ::string my_str;

// tttttttt      _________ :CHECK-NEXT-LINE
   optional<int> read_size;
// tttttttt       _________ :CHECK-NEXT-LINE
   optional<int> &read_size;
// tttttttt       _________ :CHECK-NEXT-LINE
   optional<int>& read_size;
// tttttttt        _________ :CHECK-NEXT-LINE
   optional<int> &&read_size;
// tttttttt        _________ :CHECK-NEXT-LINE
   optional<int>&& read_size;

// tttttttttttttttttttttttttttttttttttt _____ :CHECK-NEXT-LINE
   std::unordered_map<std::string, int> tacos;

// tttttttttttttttttt _________ :CHECK-NEXT-LINE
   std::optional<int> read_size;

// ccccc tttttt  _ :CHECK-NEXT-LINE
   const string& s;
// tttttt ccccc  _ :CHECK-NEXT-LINE
   string const& s;

// TODO(strager): Don't highlight QLJS_FORCE_INLINE as a type in the code below:
  QLJS_FORCE_INLINE explicit bool_vector_16_sse2(__m128i data) noexcept
      : data_(data) {}

// mmmmmmmm             :CHECK-NEXT-LINE
   explicit MyClass() {}

// TODO(strager): Fix these tests.
// sssss t      sssss t :DISABLED-CHECK-NEXT-LINE
   class C {};  class C;
// ssssss t _ tttt    :DISABLED-CHECK-NEXT-LINE
   struct C : Base {};
// sssss t _        ttttt_         ttttt    :DISABLED-CHECK-NEXT-LINE
   class C : public Base1, private Base2 {};
// sssss t mmmmm    :CHECK-NEXT-LINE
   class C final {};
