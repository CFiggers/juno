# janet-new

A simple CLI utility for creating new project scaffolds for [Janet](https://github.com/janet-lang/janet). Written in [Janet](https://github.com/janet-lang/janet). Inspired by [neil](https://github.com/babashka/neil).

## Getting Started

Required: [Janet](https://github.com/janet-lang/janet).

1. Clone this repo.

  - For e.g., using the [GitHub CLI](https://github.com/cli/cli): `$ gh repo clone CFiggers/janet-new`

2. cd into the directory: `$ cd janet-new`

3. Run `$ janet janet-new.janet new hello-world`

4. See a new directory folder created with the arg you passed to the `new` subcommand:

```bash
$ ls
... hello-world ...
```

## Compiling a Binary and Installing

Required: [jpm](https://github.com/janet-lang/jpm).

1. In the `janet-new` repo, run `jpm build`.

2. See a new `build` directory folder:

```bash
$ ls
... build ...
```

3. Put or symlink the `janet-new` binary in `build` onto your `$PATH`.

  - For e.g., using `ln` to create a symlink: `$ sudo ln -s /usr/bin/janet-new [path to janet-new]/build/janet-new`
  
4. Use `janet-new` anywhere you want.
