(def jaylib-template (slurp "templates/jaylib.janet"))
(def license-mit-template (slurp "templates/MIT.txt"))
(def typst-template (slurp "templates/prep_template.typ"))

(def licenses-cache
  {:mit license-mit-template})

# TODO (#5): Fetching license text from GitHub
(defn handle-license [opts]
  (let [license (or (opts :license) "mit")]
    (if-let [got-license (licenses-cache (keyword license))] 
      got-license 
      (do (printf "  ! Tried to get a %s license, but couldn't !" license)
          (print "TODO: Add an awesome license here")))))

(defn default-new [proj-name opts]
  {:license {:type :file
             :name "LICENSE" 
             :contents (string/replace "[name]" 
                                       (or (opts :author) "[name]") 
                                       (handle-license opts))} 
   :gitignore {:type :file
               :name ".gitignore"
               :contents 
               ```
               .clj-kondo
               .lsp
               .vscode
               build
               ```}
   :readme {:type :file
            :name "README.md"
            :contents
            (string/format
             ```
             # %s
             
             A new [Janet](janet-lang/janet) project. The sky is the limit!
             
             ## Getting Started 
             
             1. <!-- TODO: Give some helpful usage steps -->
             
             2. 
             
             3. 
             ```
             proj-name)}  
   :src {:type :folder 
         :name "src" 
         :contents {:main {:type :file 
                           :name (string/format "%s.janet" proj-name) 
                           :contents 
                           ```
                           # Uncomment to use `janet-lang/spork` helper functions.
                           # (use spork)
                           
                           (defn main [& args]
                             (print "Hello, World!"))
                           ```}}}
   :project-file {:type :file
                  :name "project.janet"
                  :contents 
                  (string 
                   (string/format
                    ```
                    (declare-project
                      :name "%s"
                      :description "%s")
                    ```
                    proj-name
                    (or (opts :description) "TODO: Write a cool description"))
                   (when (opts :executable)
                     (string/format
                       ``` 
                       
                       (declare-executable
                         :name "%s"
                         :entry "src/%s.janet"
                         # :lflags ["-static"]
                         :install false)
                       ```
                      proj-name
                      proj-name)))}
  :test (if (opts :test)
            {:type :folder 
             :name "test" 
             :contents {:test1 {:type :file 
                                :name "test.janet" 
                                :contents 
                                ```
                                (use judge) 
                                # (import spork/test)
                                
                                (def start (os/clock))
                                
                                (deftest "name this"
                                  (test true true))
                                
                                (deftest final-time
                                  (print "Elapsed time: " (- (os/clock) start) " seconds"))
                                ```}}} 
            nil)})

(defn typst-new [proj-name opts]
  {:lib-file {:type :folder 
              :name "lib" 
              :contents {:main {:type :file 
                                :name "prep_template.typ" 
                                :contents typst-template}}} 
   :index {:type :file
           :name "index.typ"
           :contents 
           ```
           #import "./lib/prep_template.typ": *
           #show: body 
           
           = 
           ```}})

(defn jaylib-new [proj-name opts]
  {:license {:type :file
             :name "LICENSE" 
             :contents (string/replace "[name]" (or (opts :author) "[name]") (handle-license opts) )} 
   :gitignore {:type :file
               :name ".gitignore"
               :contents 
               ```
               .clj-kondo
               .lsp
               .vscode
               build
               ```}
   :readme {:type :file
            :name "README.md"
            :contents
            (string/format
             ```
             # %s
             
             A new [Janet](janet-lang/janet) project. The sky is the limit!
             
             ## Getting Started 
             
             1. <!-- TODO: Give some helpful usage steps -->
             
             2. 
             
             3. 
             ```
             proj-name)}  
   :src {:type :folder 
         :name "src" 
         :contents {:main {:type :file 
                           :name (string/format "%s.janet" proj-name) 
                           :contents jaylib-template}}}
   :project-file {:type :file
                  :name "project.janet"
                  :contents 
                  (string 
                   (string/format
                    ```
                    (declare-project
                      :name "%s"
                      :description "%s")
                    ```
                    proj-name
                    (or (opts :description) "TODO: Write a cool description"))
                   (when (opts :executable)
                     (string/format
                       ``` 
                       
                       (declare-executable
                         :name "%s"
                         :entry "src/%s.janet"
                         # :lflags ["-static"]
                         :install false)
                       ```
                      proj-name
                      proj-name)))}
  :test (if (opts :test)
            {:type :folder 
             :name "test" 
             :contents {:test1 {:type :file 
                                :name "test.janet" 
                                :contents 
                                ```
                                (use judge) 
                                # (import spork/test)
                                
                                (def start (os/clock))
                                
                                (deftest "name this"
                                  (test true true))
                                
                                (deftest final-time
                                  (print "Elapsed time: " (- (os/clock) start) " seconds"))
                                ```}}} 
            nil)})

# TODO (#6): Additional project templates and user templating engine
(def templates
  {:default default-new
   :typst typst-new
   :jaylib jaylib-new})
