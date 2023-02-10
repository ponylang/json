// in your code this `use` statement would be:
// use "json"
use "../../json"

actor Main
  new create(env: Env) =>
    env.out.print("This library needs an example. Care to add one?")
