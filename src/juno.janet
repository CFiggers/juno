(import /src/templates)
(import cmd)
(import jdn)
(import spork/path)
(use judge)
(use sh)

# TODO: (#8): Implement `adopt` feature within user templating engine

(def version "0.0.3")

(defn create-folder! 
  "Wrap os/mkdir to have ! in fn name indicating stateful change"
  [path]
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

(defn ensure-config-file! [config-path]
  (unless (os/stat config-path)
    ($ "mkdir" (path/dirname config-path) "-p")
    (spit config-path (jdn/encode {}))))

(defn load-config-file! [config-path]
  (jdn/decode (slurp config-path)))

(defn save-config-file! [config-path config-map]
  (spit config-path (jdn/encode config-map)))

(defn manage-config-map! [action &named config-map config-root config-name]
  (let [homedir (or config-root (os/getenv "HOME"))
        config-path (path/join homedir ".config" (or config-name ".junorc"))
        config-map (or config-map {})]
    (ensure-config-file! config-path)
    (case action
      :load (load-config-file! config-path)
      :save (save-config-file! config-path config-map)
      :reset (spit config-path (jdn/encode {})))))

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
  (let [config (manage-config-map! :load) 
        opts (-> opts
                 (update :template |(or $ (config :default-template)))
                 (update :author |(or $ (config :default-author)))
                 (update :license |(or $ (config :default-license))))
        dir (path/join (or (opts :directory) ".") proj-name)
        temp ((templates/templates (keyword (or (opts :template) "default"))) proj-name opts)]
    (if temp
      (do (print "Creating a new Janet project following the " (or (opts :template) "default") " template")
          (print)
          (os/mkdir dir)
          (os/cd dir)
          (deploy-template temp)
          (print)
          (print "Success! Thank you, please come again"))
      (print "No template with that name found."))))

(cmd/defn handle-new "Make a new project directory." 
  [[--directory --dir -d] (optional :string ".") "The relative directory path where you'd like juno to create the new project. Defaults to the current dir."
   [--executable -e] (flag) "Indicate to the template to include features for building executables, if it has any."
   [--license -l] (optional :string) "Specify a license to include in the project. Defaults to MIT."
   [--author -a] (optional :string) "Specify the author name to use to the copyright field in the LICENSE file."
   [--description -D] (optional :string) "Specify the description to use in the template's project description fields, if it has any."
   [--test -t] (flag) "Indicate to the template to include features for testing, if it has any."
   template (optional :string) "Tell juno what template to use to scaffold your new project. Defaults to a simple Janet project."
   project-name :string] "Specify the project name to use in the template's project name fields, if it has any."
  (serve-new project-name
             :opts @{:executable executable
                     :license license
                     :project-name project-name
                     :template template
                     :directory directory
                     :author author
                     :test test
                     :description description}))

(cmd/defn handle-version "" []
  (print "Version " version))

(defn print-defaults [config-map] 
  (print "Your current Juno configuration is as follows:" "\n") 
  (if (empty? config-map)
    (print "- You have no user defaults set")
    (each config (pairs config-map)
      (print "- Your default "
             (case (first config)
               :default-template "template"
               :default-author "author"
               :default-license "license")
             " is set to: " (in config 1)))))

(defn handle-reset [force]
  (if force
    (manage-config-map! :reset)
    (do (print "This will reset your `.junorc` file to default. Are you sure? [y/N]")
        (let [input (getline)]
          (if (= "y\n" (string/ascii-lower input))
            (manage-config-map! :reset)
            (print "Cancelled"))))))

(cmd/defn handle-configure "Configure defaults (like author, template, and license) that Juno will use elsewhere. Saves configs to `~/.config/.junorc`."
  [--default-author (optional :string) "Set a `:default-author`. `juno new` will pass this value to templates when no `--author` is provided."
   --default-template (optional :string) "Set a `:default-template`. `juno new` will default to this value if no `--template` is provided."
   --default-license (optional :string) "Set a `:default-license`. `juno new` will pass this value to templates when no `--license` is provided."
   [--force -f] (flag)
   [--reset -r] (flag)] 
          (if reset
            (handle-reset force)
            (let [targets (-> @{}
                              (put :default-author default-author)
                              (put :default-license default-license)
                              (put :default-template default-template))
                  config (manage-config-map! :load)]
              (if (empty? targets)
                (print-defaults config)
                (manage-config-map! :save :config-map targets)))))

(cmd/main
 (cmd/group 
  (string/format
    ``
    Juno v%s
    
    Usage: juno [subcommand] {positional arguments} [options] 
    
    A simple CLI tool for creating new project directories. Defaults to a basic Janet project.
    ``
    version)
    joke handle-joke
    license handle-license
    new handle-new
    config handle-configure
    --version handle-version
    -v handle-version))
