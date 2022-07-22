(def licenses-cache
  {:mit  
   ```
   MIT License

   Copyright (c) [year] [name]

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
   ```})

# TODO (#5): Fetching license text from GitHub
(defn handle-license [res]
  (let [license (or (res "license") "mit")]
    (if-let [got-license (licenses-cache (keyword license))] 
      got-license 
      (do (print "  ! Tried to get a %s license, but couldn't !" license)
          "TODO: Add an awesome license here"))))

(defn default-new [proj-name res]
  {:license {:type :file
             :name "LICENSE" 
             :contents (handle-license res)} 
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
                       :description "TODO: Write a cool description") 
                     ```
                     proj-name)
                   (when (res "executable")
                     (string/format
                       ``` 
                       (declare-executable
                         :name "%s"
                         :entry "src/%s.janet"
                         # :lflags ["-static"]
                         :install false)
                       ```
                      proj-name
                      proj-name)))}})

# TODO (#6): Additional project templates and user templating engine
(def templates
  {:default default-new})