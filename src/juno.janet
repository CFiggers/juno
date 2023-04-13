(import /src/templates)
(import cmd)
(import spork/path)

# TODO: (#8): Implement `adopt` feature within user templating engine

(def version "0.0.3")

# Wrap os/mkdir to have ! in fn name indicating stateful change
(defn create-folder! [path]
  (os/mkdir path))

(defn create-file! [path &opt contents]
  (print "- Creating file " path " at " (os/cwd))
  (os/shell (string "touch " path))
  (when contents
    (spit path contents)))

(cmd/defn handle-joke 
          "Tell one specific joke. Juno doesn't know any good ones." 
          [] 
          (print "What's brown and sticky? A stick!"))

(cmd/defn handle-license 
          "Add a license to the current directory. Expects an operation name and a license name (such as `mit`)." 
          [license-type (optional :string "mit")]
          (if-let [got-license (templates/licenses-cache (keyword license-type))]
            (create-file! "LICENSE" got-license)
            (do (printf "  ! Tried to get a %s license, but couldn't !" license-type)
                (print "TODO: Add an awesome license here"))))

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

(defn serve-new [proj-name &named opts]
  (let [dir (path/join (or (opts :directory) ".") proj-name) 
        temp ((templates/templates (keyword (or (opts :template) "default"))) proj-name opts)]
    (if temp
      (do (print "Creating a new Janet project following the " (opts :template) " template")
          (print)
          (os/mkdir dir)
          (os/cd dir)
          (deploy-template temp)
          (print)
          (print "Success! Thank you, please come again"))
      (print "No template with that name found."))))

(cmd/defn handle-new "Make a new project directory." 
          [[--directory -d] (optional :string ".")
           [--executable -e] (flag)
           [--license -l] (optional :string "mit")
           [--author -a] (optional :string) 
           template (optional :string "default")
           project-name :string]
          (serve-new project-name
                     :opts {:executable executable
                            :license license
                            :project-name project-name
                            :template template
                            :directory directory
                            :author author}))

(cmd/defn handle-version "" []
          (print "Version " version))

(cmd/main
 (cmd/group "A simple CLI tool for creating new project directories. Defaults to a simple Janet project."
            joke handle-joke
            license handle-license
            new handle-new
            --version handle-version
            -v handle-version))
