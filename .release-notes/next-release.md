## Add JsonExtractor utility class

We've added a new class to the `JSON` library. `JsonExtractor` bundles up a lot of the boilerplate needed to extract typed values from Json objects.

Given the following Json:

```json
{
  "name": "John",
  "age": 30,
  "isStudent": true
}
```

Where you previously had to do:

```pony
let doc = recover val JsonDoc.>parse(src)? end
let name = (doc.data as JsonOject).data("name")? as String
let age = (doc.data as JsonOject).data("age")? as I64
let isStudent = (doc.data as JsonOject).data("isStudent")? as Bool
```

You can now do:

```pony
let doc = recover val JsonDoc.>parse(src)? end
let name = JsonExtractor(doc.data)("name")?.as_string()?
let age = JsonExtractor(doc.data)("age")?.as_i64()?
let isStudent = JsonExtractor(doc.data)("isStudent")?.as_bool()?
```

For simple Json structures such as the one above, there is little difference. However, once you start dealing with nested objects and arrays, `JsonExtractor` can save you a lot of boilerplate code.

