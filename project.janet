(declare-project
 :name "juno"
 :description "A cli application for generating Janet project scaffolds"
 :dependencies [{:url "https://github.com/ianthehenry/cmd.git"
                 :tag "v1.0.4"}
                {:url "https://github.com/ianthehenry/judge.git"
                 :tag "v2.3.1"}
                "https://github.com/andrewchambers/janet-jdn"
                "https://github.com/janet-lang/spork"])

(declare-executable
  :name "juno"
  :entry "src/juno.janet"
  # :lflags ["-static"]
  :install false)
