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
(defn handle-license [opts]
  (let [license (or (opts :license) "mit")]
    (if-let [got-license (licenses-cache (keyword license))] 
      got-license 
      (do (printf "  ! Tried to get a %s license, but couldn't !" license)
          (print "TODO: Add an awesome license here")))))

(defn default-new [proj-name opts]
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
                                :contents 
                                ```
                                #let body(doc) = {
                                    set page ( 
                                        paper: "us-letter",
                                        numbering: "1",
                                        margin: (x: 1in, top: 1in, bottom: 0.9in)
                                    )
                                
                                    show heading.where(level:1): it => [
                                        #set block(
                                            below: 1.65em
                                        )
                                        #set text(12pt, 
                                            weight: "bold",
                                            font: "Times New Roman")
                                        #block(it.body)
                                    ]
                                
                                    show heading.where(level:2): it => [
                                        #set block(
                                            below: 1.65em
                                        )
                                        #set text(12pt, 
                                            style: "italic",
                                            font: "Times New Roman")
                                        #block(it.body)
                                    ]
                                
                                    show heading.where(level:3): it => [
                                        #set block(
                                            below: 1.65em
                                        )
                                        #set text(12pt, 
                                            style: "italic",
                                            wight: "regular",
                                            font: "Times New Roman")
                                        #block(it.body)
                                    ]
                                
                                    set par(
                                        leading: 0.5em
                                    )
                                
                                    set block(
                                        below: 1.65em
                                    )
                                
                                    set text(
                                        font: "Times New Roman",
                                        size: 12pt
                                    )
                                
                                    doc
                                } 
                                
                                #let blockquote(body) = box(inset: (x: 1.65em, y: 0pt), width: 100%, {
                                  set text(style: "italic")
                                  body
                                })
                                
                                #let poetry(body) = box(inset: (x: 1.65em, y: 0pt), width: 100%, {
                                  set text(style: "italic")
                                  set align(center)
                                  set block(spacing: 0.5em)
                                  body
                                })
                                ```}}} 
   :index {:type :file
           :name "index.typ"
           :contents 
           ```
           #import "./lib/prep_template.typ": *
           #show: body 
           
           = 
           ```}})

# TODO (#6): Additional project templates and user templating engine
(def templates
  {:default default-new
   :typst typst-new})