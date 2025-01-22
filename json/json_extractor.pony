use "collections"

class val JsonExtractor
  """
  Utility class for working with JSON structures.

  Given the following JSON:
  ```json
{
  "environments": [
    {
      "name": "corral-env",
      "user": "sean",
      "image": "an-image:latest",
      "shell": "fish",
      "workdir": "/workspace",
      "workspace": "/home/sean/ponylang/corral",
      "mounts": [
        {"source":"/var/run/docker.sock","target":"/var/run/docker.sock", "type": "bind"}
      ]
    }
  ]
}
  ```

  We can use the following code to extract our values:

  ```pony
  primitive Parser
    fun apply(json: JsonType val): Array[Environment] val ? =>
      recover val
        let envs = JsonExtractor(json)("environments")?.as_array()?
        let result: Array[Environment] = Array[Environment]
        for e in envs.values() do
          let obj = JsonExtractor(e).as_object()?
          let name = JsonExtractor(obj("name")?).as_string()?
          let user = JsonExtractor(obj("user")?).as_string()?
          let image = JsonExtractor(obj("image")?).as_string()?
          let shell = JsonExtractor(obj("shell")?).as_string()?
          let workdir = JsonExtractor(obj("workdir")?).as_string()?
          let workspace = JsonExtractor(obj("workspace")?).as_string()?
          let mounts = recover trn Array[Mount] end
          for i in JsonExtractor(obj("mounts")?).as_array()?.values() do
            let m = MountParser(i)?
            mounts.push(m)
          end

          let environment = Environment(name, user, image, shell, workdir, workspace, consume mounts)
          result.push(environment)
        end
        result
      end

  primitive MountParser
    fun apply(json: JsonType val): Mount ? =>
      let obj = JsonExtractor(json).as_object()?
      let source = JsonExtractor(obj("source")?).as_string()?
      let target = JsonExtractor(obj("target")?).as_string()?
      let mtype = JsonExtractor(obj("type")?).as_string()?

      Mount(source, target, mtype)
  ```

  The JsonExtractor creates a lot of intermediate objects, but it makes the code
  easier to read and understand. We suggest not using it in critical paths where
  performance is a concern.
  """
  let _json: JsonType val

  new val create(json: JsonType val) =>
    """
    Create a new JsonExtractor from a JSON structure.
    """
    _json = json

  fun val apply(idx_or_key: (String | USize)): JsonExtractor val ? =>
    """
    Extract an array or object by index or key and return a new JsonExtractor.
    """
    match (_json, idx_or_key)
    | (let a: JsonArray val, let idx: USize) =>
      JsonExtractor((a.data)(idx)?)
    | (let o: JsonObject val, let key: String) =>
      JsonExtractor((o.data)(key)?)
    else
      error
    end

  fun val size(): USize ? =>
    """
    Return the size of the JSON structure.

    Results in an error for any structure that isn't a `JsonArray` or `JsonObject`.
    """
    match _json
    | let a: JsonArray val =>
      a.data.size()
    | let o: JsonObject val =>
      o.data.size()
    else
      error
    end

  fun val values(): Iterator[JsonType val] ? =>
    """
    Return an iterator over the values of the JSON structure.

    Results in an error for any structure that isn't a `JsonArray`.
    """
    match _json
    | let a: JsonArray val =>
      a.data.values()
    else
      error
    end

  fun val pairs(): Iterator[(String, JsonType val)] ? =>
    """
    Return a pairs iterator over the values of the JSON structure.

    Results in an error for any structure that isn't a `JsonArray`.
    """
    match _json
    | let o: JsonObject val =>
      o.data.pairs()
    else
      error
    end

  fun val as_array(): Array[JsonType] val ? =>
    """
    Extract an Array from the JSON structure.
    """
    match _json
    | let a: JsonArray val =>
      a.data
    else
      error
    end

  fun val as_object(): Map[String, JsonType] val ? =>
    """
    Extract a Map from the JSON structure.
    """
    match _json
    | let o: JsonObject val =>
      o.data
    else
      error
    end

  fun val as_string(): String ? =>
    """
    Extract a String from the JSON structure.
    """
    _json as String

  fun val as_none(): None ? =>
    """
    Extract a None from the JSON structure.
    """
    _json as None

  fun val as_f64(): F64 ? =>
    """
    Extract a F64 from the JSON structure.
    """
    _json as F64

  fun val as_i64(): I64 ? =>
    """
    Extract a I64 from the JSON structure.
    """
    _json as I64

  fun val as_bool(): Bool ? =>
    """
    Extract a Bool from the JSON structure.
    """
    _json as Bool

  fun val as_string_or_none(): (String | None) ? =>
    """
    Extract a String or None from the JSON structure.
    """
    match _json
    | let s: String => s
    | let n: None => n
    else
      error
    end
