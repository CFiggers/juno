# (use spork)
(import ./lib/argparse)
(import ./templates)
(import spork/path)

# TODO (#1): Add and handle flags for including optional add-ons to a template
# e.g. "executable" to add (declare-executable) to `project.janet`

# TODO: (#8): Implement `adopt` feature within user templating engine

(def version "0.0.2")

(def argparse-params
    ["A simple CLI tool. Creates a new Janet project directory."
     "joke" {:kind :subcommand
             :help "Tell one specific joke. Juno doesn't know any good ones."
             :action (fn [] (print "What's brown and sticky? A stick!"))} 
     "new" {:kind :subcommand
            :help "Make a new project directory. Expects [template] and [project name]."
            :args-expected 2 # Expects template and project name
            :args-required false} 
     # TODO (#2): Implement `license` subcommand
     "license" {:kind :subcommand
                :help "Add a license to the current directory. Expects an operation name and a license name (such as `mit`)."
                :args-expected 2 # Expects [:add|:remove|:append|:replace] and a license name
                :args-required false} 
     "license" {:kind :option
                :short "l"
                :help "With `new`: Specify a search string for `LICENSE` (e.g. `mit` or `gpl2`)."}
     "executable" {:kind :flag
                   :short "e"
                   :help "With `new`: Include `(declare-executable)` block in `project.janet`."} 
     "directory" {:kind :option
                  :short "d"
                  :value-name "directory"
                  :required false
                  :help "With `new`: Specify a directory other than the current one."}
     "version" {:kind :flag
                :short "v"
                :help "Prints the CLI version."
                :action (fn [] (print (string/format "Juno v%s" version)))
                :short-circuit true}])

# Wrap os/mkdir to have ! in fn name indicating stateful change
(defn create-folder! [path]
  (os/mkdir path))

(defn create-file! [path &opt contents]
  (print "- Creating file " path " at " (os/cwd))
  (os/shell (string "touch " path))
  (when contents 
    (spit path contents)))

# Declare function to allow reference out of order
(varfn deploy-template [])

(defn execute-step [_ step]
  (let [{:contents contents 
         :name name 
         :type s-type} step]
    (case s-type
      :file (create-file! name contents)
      :folder (do (create-folder! name)
                  (os/cd name)
                  (deploy-template contents)
                  (os/cd ".."))
      (error "Unreachable"))))

(varfn deploy-template [template]
  (let [steps (pairs template)]
    (map (fn [a] (apply execute-step a)) steps)))

(defn handle-new [res]
  (let [[proj-name t] (reverse (res "new"))
        dir (path/join (or (res "directory") ".") proj-name)
        temp-name (or t "default")
        temp ((templates/templates (keyword temp-name)) proj-name res)] 
    (if temp
      (do (print "Creating a new Janet project following the " temp-name " template")
          (print)
          (os/mkdir dir)
          (os/cd dir)
          (deploy-template temp)
          (print)
          (print "Success! Thank you, please come again"))
      (print "No template with that name found."))))

(defn main [& args] 
  (when-let [res (argparse/argparse ;argparse-params)
             subcommands (res :subcommands)
             in? (fn [a col] (if (index-of a col) true false))]
    (cond
      subcommands (cond
                    (in? "new" subcommands)
                    (handle-new res)
                    (in? "license" subcommands)
                    (print "Add a new license, I suppose")))))