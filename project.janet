(declare-project
 :name "juno"
 :description "A cli application for generating Janet project scaffolds"
 :dependencies ["https://github.com/ianthehenry/cmd.git"
                "https://github.com/ianthehenry/judge.git"
                "https://github.com/andrewchambers/janet-jdn"
                "https://github.com/janet-lang/spork"])

(declare-executable
  :name "juno"
  :entry "src/juno.janet"
  # :lflags ["-static"]
  :install false)
