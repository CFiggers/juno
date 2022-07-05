(declare-project
  :name "janet-new"
  :description "A cli application for generating Janet project scaffolds")

(declare-executable
  :name "janet-new"
  :entry "src/janet-new.janet"
  # :lflags ["-static"]
  :install false)
