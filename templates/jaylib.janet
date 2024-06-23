(import jaylib)
(use judge)

(def width 800)
(def height 600)
(def speed-factor 50)

(def rng (math/rng))

(defn wrap [thing]
  (def {:pos [x y] :size size} thing)
  (when (< x 0) (update-in thing [:pos 0] |(+ $ width)))
  (when (< y 0) (update-in thing [:pos 1] |(+ $ height)))
  (when (> (+ x size) width) (update-in thing [:pos 0] |(- $ width)))
  (when (> (+ y size) height) (update-in thing [:pos 1] |(- $ height))))

(defn bounce [square]
  (var {:x x :y y :z z
        :x-speed x-speed :y-speed y-speed :z-speed z-speed
        :size size} square)
  (when (> y (- height size))
    (set (square :y-speed) (- y-speed)))
  (when (> x (- width size))
    (set (square :x-speed) (- x-speed)))
  # (when (> z (- depth size))
  #   (set (square :z-speed) (- z-speed)))
  (when (> 0 y)
    (set (square :y-speed) (- y-speed)))
  (when (> 0 x)
    (set (square :x-speed) (- x-speed)))
  # (when (> 0 z)
  #   (set (square :z-speed) (- z-speed)))
  )

(defn add-thing [things]
  (array/push things @{:pos @[(math/rng-int rng width)
                              (math/rng-int rng height)]
                       :vel @[(- (math/rng-int rng 10) 5)
                              (- (math/rng-int rng 10) 5)]
                       :acc @[0 0]
                       :size 5}))

(defn drop-thing [things]
  (array/pop things))

(defn vec-distance [[x1 y1] [x2 y2]]
  (math/sqrt (+ (math/pow (- x2 x1) 2)
                (math/pow (- y2 y1) 2))))

(test (vec-distance [0 0] [1 1]) 1.4142135623730951)
(test (vec-distance [0 0] [3 4]) 5)
(test (vec-distance [0 0] [-3 -4]) 5)
(test (vec-distance [0 0] [3 -4]) 5)

(defn magnitude [[x y]]
  (math/sqrt (+ (math/pow x 2)
                (math/pow y 2))))

(defn magnitude [[x y]]
  (math/sqrt (+ (math/pow x 2)
                (math/pow y 2))))

(test (magnitude [0.74278135270820744 1.8569533817705188]) 2)

(defn limit [[x y] target-mag]
  (let [start-mag (magnitude [x y])]
    (cond
      (zero? start-mag) [x y]

      (> start-mag target-mag)
      [(* target-mag (/ x start-mag))
       (* target-mag (/ y start-mag))]

      [x y])))

(test (limit [2 5] 1) [0.37139067635410372 0.92847669088525941])
(test (limit [2 5] 2) [0.74278135270820744 1.8569533817705188])
(test (limit [2 5] 7) [2 5])

(defn normalize [[x y] &opt target-mag]
  (default target-mag 1)
  (let [start-mag (magnitude [x y])]
    (when (zero? start-mag) (break [x y]))
    [(* target-mag (/ x start-mag))
     (* target-mag (/ y start-mag))]))

(test (normalize [2 5]) [0.37139067635410372 0.92847669088525941])

(defn main [& args]
  (jaylib/init-window width height "Template")
  # (jaylib/set-target-fps 60)

  (var dt math/inf)
  (var time 0)

  # Add other properties here
  (def things @[@{:pos @[100 100]
                  :vel @[1 1]
                  :acc @[0 0]
                  :size 5}])
  
  (repeat 2200 (add-thing things))

  (while (not (jaylib/window-should-close))
    (let [newtime (jaylib/get-time)]
      (set dt (- time newtime))
      (set time newtime))
    
    (defer (jaylib/end-drawing)
      (jaylib/begin-drawing)

      (jaylib/clear-background 0x181818FF) 
      
      (each thing things 
        
        # (update thing :pos |(map + $ (map (comp math/round (partial * dt speed-factor)) (thing :vel))))
        (update-in thing [:pos 0] |(+ $ (math/round (* dt speed-factor ((thing :vel) 0)))))
        (update-in thing [:pos 1] |(+ $ (math/round (* dt speed-factor ((thing :vel) 1)))))
        
        # (update thing :vel |(map + $ (thing :acc)))
        (wrap thing)

        (def {:x x :y y} thing)
        (jaylib/draw-rectangle ;(thing :pos) (thing :size) (thing :size) :white))
      
      (comment "Put your code here")
           
      (jaylib/draw-fps 10 10)
      (jaylib/draw-text (string/format "Things: %d" (length things)) 10 (- height 20 10) 20 :white)) 

    (case (jaylib/get-mouse-wheel-move)
      -1 (add-thing things)
      1 (drop-thing things))))
