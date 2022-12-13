# crystal-examples [![Build Status](https://travis-ci.org/maiha/crystal-examples.svg?branch=main)](https://travis-ci.org/maiha/crystal-examples)

crystal examples checker

<p float="left">
  <img src="https://user-images.githubusercontent.com/12258/54723697-c77f2480-4bab-11e9-9d03-3dc4df494ef1.png" width=200 />
  <img src="https://user-images.githubusercontent.com/12258/54723703-d06ff600-4bab-11e9-847d-611effb1e481.png" width=200 />
  <img src="https://user-images.githubusercontent.com/12258/54723801-22b11700-4bac-11e9-880a-9c17fc3b5645.png" width=200 />
</p>

## Supported Literals
In addition to the standard crystal literals, the following literals may be used for comments.
```crystal
x # raises FooError
x # => 10.00:00:00.000010000
x # => UUID(ba714f86-cac6-42c7-8956-bcf5105e1b81)
x # => 2016-02-15 04:35:50.0 UTC
x # => NaN
x # => #<Foo>
```

## Requirements
- `crystal-examples` : linux x86_64 static binary is [available](https://github.com/maiha/crystal-examples/releases)
- `docker compose`

## Setup

First, specify a working directory and initialize or upgrade. Be careful when specifying an existing directory, as files such as Makefiles will be overwritten.

```console
$ crystal-examples setup .
Setting up working directory in ./
  ok         /tmp/work
  create     Makefile
  create     config.toml
  create     compose.yaml
  create     examples.db
  create     crystal-examples # 0.3.1 [51d73b1] (2019-03-20)
  not found  crystal/src
  ...
  not found  ./crystal/bin/crystal # (compiled compiler)
  ...
```

#### `crystal/src`

Second, prepare source directory. In general, run as follows.

```console
$ git clone https://github.com/crystal-lang/crystal.git
```

Here, `crsytal/src` should be in subdir because compiler will work in docker container which mounts "./".

#### crystal

Then, prepare `crystal` compiler. There are three choices.

##### 1. use compiled compiler (default)

Build `./crystal/.build/crystal` if it's first time for the `./crystal` src.

```console
$ make crystal
```

##### 2. use system compiler

Update the value of `bin` to just `crystal`.

```console
$ vi config.toml
bin     = "crystal"               # use system compiler
```

##### 3. use custom compiler

Same above, you can use any compiler by updating `bin` in `config.toml`.
Note that it will be used in docker container.

##  Web interface

`make web` runs web server at `0.0.0.0:8080` in docker container.

```console
$ make web
[production] Kemal is ready to lead at http://0.0.0.0:8080
```

If you want to change setting like listen port, edit `config.toml`.

## Architecture

#### `src`

a relative path from crystal src dir to the src file.
For example, `array.cr`, `http/client.cr`.

#### `Example` model

one code block written in `src` as comment.

- `src`  : its src
- `seq`  : sequence number of the comment blocks in the src
- `line` : line number of the comment block in the src
- `type` : type of comment block (ex. `json`, `crystal`)
- `code` : content of the comment block

```crystal
[] of Int32 # same as Array(Int32)
[]          # syntax error
```

- `sha1`     : SHA1 message digest for the code
- `compiled` : status cache about compiling
- `tested`   : status cache about testing

#### `CompileCache` model

compile cache of `Example`

- `src`, `seq` : the primary key for the `Example`
- `exit_code`  : exit code of compiling process
- `log`        : stdout and stderr of compiling

#### `TestCache` model

test cache of `Example`

- `src`, `seq` : the primary key for the `Example`
- `exit_code`  : exit code of testing process
- `log`        : stdout and stderr of testing

#### `Heuritstic` model

Accumulated heuristics for example code execution.

- `action` : heuristic type (`require`, `compile`, `test`)
- `target` : heuristic target (file name or SHA1 of the code)
- `by`     : heuristic argument

It is serialized into the following string.

```
compile 081fe59b04... by:pseudo ...
require digest/base.cr by:digest ...
test fa5a9799... by:random ...
```

See: [bundled/heuristic.jnl](./bundled/heuristic.jnl)

## Difficulty

### Annotations

There are various types of sample code.

```crystal
lib LibTicker
  fun on_tick(callback : (Int32, Void* ->), data : Void*)
end
```

```crystal
FileUtils.ln("/usr/bin/vim", "/usr/bin/emacs")
```

Is this pseudo code? Is this the real code we should test?
Ideally the sample code should be annotated at this point.

```crystal
# @[Test]
# ```crystal
# [:foo, :bar].size # => 2
# ```
```

At present, we are responding each time by accumulating empirical knowledge by manual housekeeping in [bundled/heuristic.jnl](./bundled/heuristic.jnl).

### API breaking changes

Crystal often broke the stdlib API compatibility, especially `Time`, at each release.
For example, we have an example code like this.

```crystal
time = Time.utc(2016, 2, 15, 10, 20, 30)
time.to_s # => 2016-02-15 10:20:30 UTC
```

Our inner module `CommentSpec` convert this as follows.

```crystal
time.to_s.should eq( Time.parse("2016-02-15 10:20:30 UTC", "%F %T %z") )
```

However, there is no guarantee that `Time.parse` and` Time.new` will work with the current crystal version, and there is no alias for backwards compatibility.

This is preventing the use within CI and automation.

## Development

`docker compose` is needed in development too.

```console
$ make
```

## Contributing

1. Fork it ( https://github.com/maiha/crystal-examples/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
