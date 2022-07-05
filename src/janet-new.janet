# (use spork)
(import ./lib/argparse)
(import ./templates)

# TODO (#1): Add and handle flags for including optional add-ons to a template
# e.g. "executable" to add (declare-executable) to `project.janet`

# TODO: (#8): Implement `adopt` feature within user templating engine

(def argparse-params
    ["A simple CLI tool. Creates a new Janet project directory."
     "joke" {:kind :flag
             :action (fn [] (print "What's brown and sticky? A stick!"))} 
     "new" {:kind :subcommand
            :help "Make a new project directory. Expects [template] and [project name]."
            :args-expected 2 # Expects template and project name
            :args-required false} 
     # TODO (#2): Implement `license` subcommand
     "license" {:kind :subcommand
                :help "Add a license to the current directory. Expects an operation name and a licence name (such as `mit`)."
                :args-expected 2 # Expects [:add|:remove|:append|:replace] and a license name
                :args-required false} 
     # TODO (#3): Implement `directory` option to deploy a project to a custom dir     
     "directory" {:kind :option
                  :short "d"
                  :value-name "directory"
                  :required false
                  :help "Specify a directory other than the current one."}])

(defn create-folder! [path]
  (os/mkdir path))

(defn create-file! [path &opt contents]
  (print "- Creating file " path " at " (os/cwd))
  (os/shell (string "touch " path))
  (when contents 
    # TODO (#9): Replace references to file/open, file/write, file/close with spit
    (let [file (file/open path :an)]
      (file/write file contents)
      (file/close file))))

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
  (deploy-template contents) # TODO (#4): Use directory handling
                  (os/cd ".."))
      (error "Unreachable"))))

  # TODO (#4): Add directory handling
(varfn deploy-template [template]
  (let [steps (pairs template)]
    (map (fn [a] (apply execute-step a)) steps)))

(defn handle-new [proj-name &opt template]
  (default template "default")
  (let [temp ((templates/templates (keyword template)) proj-name)]
    (if temp 
      (do (print "Creating a new Janet project following the " template " template")
          (print)
          (os/mkdir proj-name)
          (os/cd proj-name)
          (deploy-template temp)
          (print)
          (print "Success! Thank you, please come again"))
      (print "No template with that name found."))))

(defn main [& args] 
  (let [res (argparse/argparse ;argparse-params)  
        subcommands (res :subcommands)
        in? (fn [a col] (if (index-of a col) true false))]
        (if res 
          (cond 
            (in? "new" subcommands) (handle-new ;(reverse (in res "new")))
            (in? "license" subcommands) (print "Add a new license, I suppose") 
            (print "Try again."))
          (print "Couldn't parse")))) 