# juno

A simple CLI utility for creating new project scaffolds for [Janet](https://github.com/janet-lang/janet). Written in [Janet](https://github.com/janet-lang/janet). Inspired by [neil](https://github.com/babashka/neil).

## Getting Started

Required: [Janet](https://github.com/janet-lang/janet).

1. Clone this repo.

      For e.g., using the [GitHub CLI](https://github.com/cli/cli): `$ gh repo clone CFiggers/juno`

2. cd into the directory: `$ cd juno`

3. Run `$ juno new hello-world`

4. See a new directory folder created with the arg you passed to the `new` subcommand:

```bash
$ ls
... hello-world ...
```

## Installing Script

1. Symlink the `juno` script in the project root onto your `$PATH`.

      For e.g., using `ln`: `$ sudo ln -s /usr/bin/juno [path to juno project root]/juno`
      
2. Use `juno` anywhere you want!

## Compiling a Binary and Installing

Required: [jpm](https://github.com/janet-lang/jpm).

1. In the `juno` repo, run `jpm deps -l && jpm build -l`.

2. See a new `build` directory folder:

```bash
$ ls
... build ...
```

3. Put or symlink the `juno` binary in `build` onto your `$PATH`. A common way to accomplish this is to put a new item in your `~/bin` folder, which is probably already on your `$PATH`.

      For e.g., using `ln` to create a symlink: `$ sudo ln -s /usr/bin/juno [path to juno project root]/build/juno`

      Or using mv to actually relocate the binary: `$ mv [path to juno project root]/build/juno /usr/bin/juno`
  
4. Use `juno` anywhere you want!

## Roadmap

### TODO
- [ ] Improved `license` subcommand for adding/updating licenses based on Github's API
- [ ] User-defined templates and automated template adoption from existing directories
- [ ] Interactive collection of parameters if needed but not provided by option flags

### DONE
- [x] MVP (Creating projects with `new`, add a license with `license`, tell a joke with `joke`)
- [x] Dynamic tweaks to templates based on flags (like `--executable`/`-e` to automatically include a `(declare-executable)` in `project.janet` but leave the rest of the template the same)
- [x] Persistent user configuration of template defaults using `juno config` and related subcommands

## Contributing

Issues, forks, and pull requests are welcome!

## Prior Art

`juno` is by no means an original concept. Innumerable project scaffolding and management tools exist, written in a plethora of languages, for a plethora of target languages and frameworks.

Here are a few that already exist in [Janet](https://github.com/janet-lang/janet) (alphabetical order):

- [jeep](https://github.com/pyrmont/jeep)
- [newt](https://github.com/yumaikas/newt)
- [michael](https://git.sr.ht/~pepe/michael)
- [jpm](https://github.com/janet-lang/jpm)

Compared with these, the biggest difference with `juno` is the data-oriented approach to project templating. Also, the (planned) `adopt` command is distinct (to my knowledge, even among project scaffolding frameworks more broadly).

Copyright (c) 2023 Caleb Figgers
