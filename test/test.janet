(use judge)
(use sh)

(def expected-files
  ["test-project"
   "test-project/LICENSE"
   "test-project/README.md"
   "test-project/src"
   "test-project/src/test-project.janet"
   "test-project/.gitignore"
   "test-project/project.janet"])

(deftest-type test-project
  :setup (fn [] (do ($ "jpm" "clean" > :null)
                    ($ "jpm" "build" > :null)
                    ($ "rm" "-rf" "test-project")))
  :reset (fn [_] ($ "rm" "-rf" "test-project"))
  :teardown (fn [_] ($ "rm" "-rf" "test-project")))

(deftest: test-project "Test `--version` command" [_]
  (test ($< "./build/juno" "--version") "Version 0.0.3\n")
  (test ($< "./build/juno" "-v") "Version 0.0.3\n"))

(deftest: test-project "Test telling a joke" [_] 
  (test ($< "./build/juno" "joke") "What's brown and sticky? A stick!\n"))

(deftest: test-project "Test new project, defaults" [_]
  (test ($< "./build/juno" "new" "test-project") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false))
  
  (test (string/find "declare-executable" (slurp "test-project/project.janet")) nil)
  (test (string/find "[name]" (slurp "test-project/LICENSE")) 34)
  (test (string/find "TODO: Write a cool description" (slurp "test-project/project.janet")) 56))

(deftest: test-project "Test new project, with `--executable` flag" [_]
  (test ($< "./build/juno" "new" "test-project" "-e") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false))

  (test (string/find "declare-executable" (slurp "test-project/project.janet")) 95))

(deftest: test-project "Test new project, with `--author` parameter" [_]
  (test ($< "./build/juno" "new" "test-project" "--author" "\"Rumplestiltskin\"") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false)) 

  (test (string/find "Rumplestiltskin" (slurp "test-project/LICENSE")) 35)
  (test (string/find "[name]" (slurp "test-project/LICENSE")) nil))

(deftest: test-project "Test new project, with `--description` parameter" [_]
  (test ($< "./build/juno" "new" "test-project" "--description" "\"A cool test project\"") "Creating a new Janet project following the default template\n\n- Creating file README.md at /home/caleb/projects/janet/juno/test-project\n- Creating file LICENSE at /home/caleb/projects/janet/juno/test-project\n- Creating file project.janet at /home/caleb/projects/janet/juno/test-project\n- Creating file test-project.janet at /home/caleb/projects/janet/juno/test-project/src\n- Creating file .gitignore at /home/caleb/projects/janet/juno/test-project\n\nSuccess! Thank you, please come again\n")
  
  (each file expected-files
        (test (nil? (os/stat file)) false)) 

  (test (string/find "A cool test project" (slurp "test-project/project.janet")) 57)
  (test (string/find "TODO: Write a cool description" (slurp "test-project/project.janet")) nil))

(deftest: test-project "Test `license` subcommand" [_]
  (os/mkdir "test-project")
  (os/cd "test-project") 
  (test (= ($< "../build/juno" "license") (string "- Creating file LICENSE at " (os/cwd) "\n")) true)
  (os/cd ".."))
