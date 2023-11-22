(use judge)
(use sh)

(import spork/path)
(import jdn)
(use /src/juno)

(def expected-files
  ["test-project"
   "test-project/LICENSE"
   "test-project/README.md"
   "test-project/src"
   "test-project/src/test-project.janet"
   "test-project/.gitignore"
   "test-project/project.janet"])

(def name-expected
  (or ((manage-config-map! :load) :default-author) "[name]"))

(deftest-type test-project
  # Setup: Rebuild juno and remove test-project, if exists
  :setup (fn [] (do ($ "jpm" "clean" > :null)
                    ($ "jpm" "build" > :null)
                    ($ "rm" "-rf" "test-project")))
  
  # Reset: Remove test-project, if exists
  :reset (fn [_] ($ "rm" "-rf" "test-project"))
  
  # Teardown: Remove test-project, if exists
  :teardown (fn [_] ($ "rm" "-rf" "test-project")))

# Test `juno` without subcommands

(deftest: test-project "Test `juno` without arguments" [_]
  (test-error ($< "./build/juno") "command(s) (@[\"./build/juno\"]) failed, exit code(s) @[1]"))

# Test --version command

(deftest: test-project "Test `--version` command" [_]
  (test ($< "./build/juno" "--version") "Version 0.0.3\n")
  (test ($< "./build/juno" "-v") "Version 0.0.3\n"))

# Test `joke` subcommand

(deftest: test-project "Test telling a joke" [_] 
  (test ($< "./build/juno" "joke") "What's brown and sticky? A stick!\n"))

# Test `new` subcommand

(deftest: test-project "Test new project, call without arguments" [_]
  (test-error ($< "./build/juno" "new") "command(s) (@[\"./build/juno\" \"new\"]) failed, exit code(s) @[1]"))

(deftest: test-project "Test new project, defaults" [_]
  (test ($< "./build/juno" "new" "test-project") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false))
  
  (test (string/find "declare-executable" (slurp "test-project/project.janet")) nil)
  (test (string/find name-expected (slurp "test-project/LICENSE")) 34)
  (test (string/find "TODO: Write a cool description" (slurp "test-project/project.janet")) 56)
  (test (nil? (os/stat "test-project/test")) true))

(deftest: test-project "Test new default project, with `--executable` flag" [_]
  (test ($< "./build/juno" "new" "test-project" "--executable") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false))

  (test (string/find "declare-executable" (slurp "test-project/project.janet")) 92))

(deftest: test-project "Test new default project, with `-e` flag" [_]
  (test ($< "./build/juno" "new" "test-project" "-e") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false))

  (test (string/find "declare-executable" (slurp "test-project/project.janet")) 92))

(deftest: test-project "Test new default project, with `--test` flag" [_]
  (test ($< "./build/juno" "new" "test-project" "--test") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file test.janet at /home/caleb/projects/janet/juno/test-project/test\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false))

  (test (nil? (os/stat "test-project/test")) false)
  (test (nil? (os/stat "test-project/test/test.janet")) false))

(deftest: test-project "Test new default project, with `-t` flag" [_]
  (test ($< "./build/juno" "new" "test-project" "-t") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file test.janet at /home/caleb/projects/janet/juno/test-project/test\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false))

  (test (nil? (os/stat "test-project/test")) false)
  (test (nil? (os/stat "test-project/test/test.janet")) false))

(deftest: test-project "Test new project, with `--author` parameter" [_]
  (test ($< "./build/juno" "new" "test-project" "--author" "\"Rumplestiltskin\"") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false)) 

  (test (string/find "Rumplestiltskin" (slurp "test-project/LICENSE")) 35)
  (test (string/find name-expected (slurp "test-project/LICENSE")) nil))

(deftest: test-project "Test new project, with `--description` parameter" [_]
  (test ($< "./build/juno" "new" "test-project" "--description" "\"A cool test project\"") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false)) 

  (test (string/find "A cool test project" (slurp "test-project/project.janet")) 57)
  (test (string/find "TODO: Write a cool description" (slurp "test-project/project.janet")) nil))

# Test `config` subcommand and related functions

(deftest-type w-config-dir
  :setup (fn [& _] ($ "rm" "-rf" ".config")) 
  :reset (fn [& _] ($ "rm" "-rf" ".config"))
  :teardown (fn [& _] ($ "rm" "-rf" ".config")))

(deftest: w-config-dir "get-config-map, doesn't exist yet" [_] 
  (test (manage-config-map! :load :config-root "./" :config-name ".testrc") {})
  (test (truthy? (os/stat "./.config/.testrc")) true))

(deftest: w-config-dir "get-config-map, exists" [_] 
  ($ "mkdir" ".config")
  (spit "./.config/.junorc" (jdn/encode {:default-template "typst"}))
  (test (manage-config-map! :load :config-root "./") {:default-template "typst"}))

(deftest "Test config, without arguments"
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default author is set to: Caleb Figgers\n"))

(deftest "Test config, load and cache, reset, restore cashed"
  (def start-config (manage-config-map! :load))
  (test start-config @{:default-author "Caleb Figgers"})
  (manage-config-map! :reset)
  (test (manage-config-map! :load) {})
  (manage-config-map! :save :config-map start-config)
  (test (manage-config-map! :load) @{:default-author "Caleb Figgers"}))

(deftest-type cache-real
  :setup (fn [&] (manage-config-map! :load))
  :reset (fn [&] (manage-config-map! :reset))
  :teardown (fn [start-config] (manage-config-map! :save :config-map start-config)))

(deftest: cache-real "Test auto-caching" [_]
  (test (manage-config-map! :load) {}))

(deftest: cache-real "Test auto-resetting" [_]
  (test (manage-config-map! :load) {})
  (manage-config-map! :save :config-map {:fail "dumb"})
  (test (manage-config-map! :load) {:fail "dumb"}))

(deftest: cache-real "Test auto-caching" [_]
  (test (manage-config-map! :load) {}))

(deftest: cache-real "Test config, save a default template 1" [_] 
  (test ($< "./build/juno" "config" "--default-template=typst") "")
  (test (manage-config-map! :load) @{:default-template "typst"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default template is set to: typst\n"))

(deftest: cache-real "Test config, save a default template 2" [_]  
  (test ($< "./build/juno" "config" "--default-template" "typst") "") 
  (test (manage-config-map! :load) @{:default-template "typst"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default template is set to: typst\n"))

(deftest: cache-real "Test config, save a default author 1" [_] 
  (test ($< "./build/juno" "config" "--default-author=Caleb Figgers") "")
  (test (manage-config-map! :load) @{:default-author "Caleb Figgers"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default author is set to: Caleb Figgers\n"))

(deftest: cache-real "Test config, save a default author 2" [_]  
  (test ($< "./build/juno" "config" "--default-author" "Caleb Figgers") "") 
  (test (manage-config-map! :load) @{:default-author "Caleb Figgers"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default author is set to: Caleb Figgers\n"))

(deftest: cache-real "Test config, save a default license 1" [_] 
  (test ($< "./build/juno" "config" "--default-license=bsd") "") 
  (test (manage-config-map! :load) @{:default-license "bsd"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default license is set to: bsd\n"))

(deftest: cache-real "Test config, save a default license 2" [_] 
  (test ($< "./build/juno" "config" "--default-license" "bsd") "") 
  (test (manage-config-map! :load) @{:default-license "bsd"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default license is set to: bsd\n"))

(deftest: cache-real "Test config, save a default template and a default author" [_]  
  (test ($< "./build/juno" "config" "--default-author" "Caleb Figgers" "--default-template" "typst") "") 
  (test (manage-config-map! :load) @{:default-author "Caleb Figgers" :default-template "typst"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default author is set to: Caleb Figgers\n- Your default template is set to: typst\n"))

(deftest: cache-real "Test config, save a default template, author, and license" [_]  
  (test ($< "./build/juno" "config" "--default-author" "Caleb Figgers" "--default-template" "typst" "--default-license" "bsd") "") 
  (test (manage-config-map! :load)
    @{:default-author "Caleb Figgers"
      :default-license "bsd"
      :default-template "typst"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default author is set to: Caleb Figgers\n- Your default license is set to: bsd\n- Your default template is set to: typst\n"))

(deftest: cache-real "Test config, save a default license twice" [_] 
  (test ($< "./build/juno" "config" "--default-license=mit") "") 
  (test (manage-config-map! :load) @{:default-license "mit"})
  (test ($< "./build/juno" "config" "--default-license=bsd") "")
  (test (manage-config-map! :load) @{:default-license "bsd"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default license is set to: bsd\n"))

(deftest: cache-real "Test config, save a default template, author, and license and then reset 1" [_]  
  (test ($< "./build/juno" "config" "--default-author" "Caleb Figgers" "--default-template" "typst" "--default-license" "bsd") "") 
  (test (manage-config-map! :load)
    @{:default-author "Caleb Figgers"
      :default-license "bsd"
      :default-template "typst"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default author is set to: Caleb Figgers\n- Your default license is set to: bsd\n- Your default template is set to: typst\n")
  (test ($< "./build/juno" "config" "--reset" "--force") "")
  (test (manage-config-map! :load) {})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- You have no user defaults set\n"))

(deftest: cache-real "Test config, save a default template, author, and license and then reset 2" [_]  
  (test ($< "./build/juno" "config" "--default-author" "Caleb Figgers" "--default-template" "typst" "--default-license" "bsd") "") 
  (test (manage-config-map! :load)
    @{:default-author "Caleb Figgers"
      :default-license "bsd"
      :default-template "typst"})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- Your default author is set to: Caleb Figgers\n- Your default license is set to: bsd\n- Your default template is set to: typst\n")
  (test ($< "./build/juno" "config" "-rf") "")
  (test (manage-config-map! :load) {})
  (test ($< "./build/juno" "config") "Your current Juno configuration is as follows:\n\n- You have no user defaults set\n"))

# Test that defaults actually apply correctly

(deftest: cache-real "Test defaults, template" [_]
  ($< "./build/juno" "config" "--default-template" "typst")
  (test ($< "./build/juno" "new" "test-project") "Creating a new Janet project following the typst template\n\n- Creating file prep_template.typ at /home/caleb/projects/janet/juno/test-project/lib\n- Creating file index.typ at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  ($ "rm" "-rf" "test-project"))

(deftest: cache-real "Test defaults, author" [_]
  ($< "./build/juno" "config" "--default-author" "Caleb Figgers")
  (test ($< "./build/juno" "new" "test-project") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  (test (string/find "Caleb Figgers" (slurp "test-project/LICENSE")) 34)
  (test (string/find "[name]" (slurp "test-project/LICENSE")) nil)
  ($ "rm" "-rf" "test-project"))

# Test `license` subcommand 

(deftest: test-project "Test `license` subcommand, without arguments" [_]
  (os/mkdir "test-project")
  (os/cd "test-project")
  (test-error ($< "./build/juno" "license") "spawn failed: \"No such file or directory\"")
  (os/cd ".."))

(deftest: test-project "Test `license` subcommand" [_]
  (os/mkdir "test-project")
  (os/cd "test-project") 
  (test (= ($< "../build/juno" "license") (string "- Creating file LICENSE at " (os/cwd) "\n")) true)
  (os/cd ".."))

