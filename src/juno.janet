(import /src/templates)
(import cmd)
(import spork/path)
(use judge)

# TODO: (#8): Implement `adopt` feature within user templating engine

(def version "0.0.3-d")

(defmacro recursively [osfn path]
  (assert (or (= osfn 'os/mkdir) (= osfn 'os/rmdir))
          "This macro only works with `os/mkdir` and `os/rmdir`")
  (with-syms [$path $osfn]
    ~(let [,$path ,path
           ,$osfn ,osfn
           patha (string/replace-all "\\" "/" ,$path)
           parts (string/split "/" patha)
           paths (accumulate path/join "." parts)
           pathsp (if (= ,$osfn os/rmdir) (reverse paths) paths)]
       (each p pathsp
         (case ,$osfn
           os/mkdir (eprint "  - Creating " p)
           os/rmdir (eprint "  - Removing " p))
         (,$osfn p)))))

(deftest "test mkdir-recursive"
  (recursively os/mkdir "a/nested/test/path")
  (test (truthy? (os/stat "a/nested/test/path")) true)
  (recursively os/rmdir "a/nested/test/path")
  (test (truthy? (os/stat "a/nested/test/path")) false))

(deftest "test mkdir-recursive"
  (recursively os/mkdir (path/join "a" "nested" "test" "path"))
  (test (truthy? (os/stat "a/nested/test/path")) true)
  (recursively os/rmdir (path/join "a" "nested" "test" "path"))
  (test (truthy? (os/stat "a/nested/test/path")) false))

(defn create-file! [path &opt contents]
  (print "- Creating file " path " at " (os/cwd))
  (spit path (or contents "")))

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

(defmacro ensure-config-file! [config-path]
  (with-syms [$cp]
    ~(let [,$cp ,config-path]
       (unless (os/stat ,$cp)
         (recursively os/mkdir (path/dirname ,$cp))
         (spit ,$cp (string/format "%j" {}))))))

(defn manage-config-map! [action &named config-map config-root config-name]
  (let [homedir (or config-root (or (os/getenv "HOME") (os/getenv "HOMEPATH")))
        config-path (path/join homedir ".config" (or config-name ".junorc"))
        config-map (or config-map {})]
    (ensure-config-file! config-path)
    (case action
      :load (parse (slurp config-path))
      :save (spit config-path (string/format "%j" config-map))
      :reset (spit config-path (string/format "%j" {})))))

# Declare function to allow reference out of order
(varfn deploy-template [])

(defn execute-step [_ step]
  (let [{:contents contents
         :name name
         :type s-type} step]
    (case s-type
      :file (create-file! name contents)
      :folder (do (os/mkdir name)
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

(defn handle-version "" []
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
  [--default-author (optional :string) "Set a `:default-author` in .junorc. `juno new` will pass this value to templates when no `--author` is provided."
   --default-template (optional :string) "Set a `:default-template` in .junorc. `juno new` will default to this value if no `--template` is provided."
   --default-license (optional :string) "Set a `:default-license` in .junorc. `juno new` will pass this value to templates when no `--license` is provided."
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

(def main-group 
  (cmd/group 
    {:doc (string/format
      ``
      Juno v%s
      
      Usage: juno <subcommand> {positional arguments} [options] 
      
        A simple CLI tool for creating new project directories. Defaults to a basic Janet project.
      ``
      version)
     :epilogue 
      ``
      General options:
      
        -h, --help   Print command-specific usage
      
      Examples:
      
        $ juno new new-project-name
        $ juno new template new-project-name
        $ juno joke
      
      ``}
      joke handle-joke
      license handle-license
      new handle-new
      config handle-configure))

(defn main [& args]
  (let [normalized-args (cmd/args)]
    (cond
      (deep= normalized-args @["--help"])      (do (cmd/run main-group ["help"]) (break))
      (deep= normalized-args @["-h"])          (do (cmd/run main-group ["help"]) (break))
      (has-value? normalized-args "--version") (do (handle-version)              (break))
      (has-value? normalized-args "-v")        (do (handle-version)              (break)))
    (cmd/run main-group (cmd/args))))
