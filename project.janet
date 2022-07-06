(declare-project
  :name "juno"
  :description "A cli application for generating Janet project scaffolds")

(declare-executable
  :name "juno"
  :entry "src/juno.janet"
  # :lflags ["-static"]
  :install false)
