(use shriek)

(defn request [method url &opt copts mimes]
  (default copts {})
  (def [bb hb] [@"" @""])
  (def opts (merge @{:method method
                     :url url
                     :write-function (fn [buf] (buffer/push bb buf))
                     :header-function (fn [buf] (buffer/push hb buf))} copts))
  (def curl (:setopt (init) ;(kvs opts)))

  (if mimes (:add-mime curl mimes))
  (:perform curl)
  # TODO peg from spork
  (def headers
    (->> (slice (string/split "\r\n" hb) 1)
         (filter |(not (empty? $)))
         (map |(string/split ": " $ 0 2))
         flatten
         (apply struct)))
  @{:status (:getinfo curl :response-code)
    :body (string bb)
    :headers headers})

(defn GET [url]
  (request "GET" url {:get? true}))

(defn HEAD [url]
  (request "HEAD" url {:nobody? true}))

(defn POST [url body]
  (request "POST" url
           ;(case (type body)
              :string
              [{:post-fields body
                :http-headers ["content-type" "text/plain"]}]
              :struct
              [{} body]
              :function
              [{:post? true
                :read-function body}])))

(defn download [url &opt file]
  (default file (last (string/split "/" url)))
  (with [f (file/open file :wb)]
    (defn save-file [buf] (:write f buf))
    (def curl (-> (init)
                  (:setopt :url url
                           :write-function save-file)
                  :perform))))
