(use judge)
(use sh)

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
  (test (nil? (os/stat "test-project")) false)
  (test (nil? (os/stat "test-project/LICENSE")) false)
  (test (nil? (os/stat "test-project/README.md")) false)
  (test (nil? (os/stat "test-project/src")) false)
  (test (nil? (os/stat "test-project/src/test-project.janet")) false)
  (test (nil? (os/stat "test-project/.gitignore")) false)
  (test (nil? (os/stat "test-project/project.janet")) false))

(deftest: test-project "Test `license` subcommand" [_]
  (os/mkdir "test-project")
  (os/cd "test-project") 
  (test (= ($< "../build/juno" "license") (string "- Creating file LICENSE at " (os/cwd) "\n")) true)
  (os/cd ".."))
