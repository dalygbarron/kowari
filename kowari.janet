(import pingo)

(defn- load-named-pic
  "Loads a picture and saves it's file name as well. It should be fine in
  practice since pingo only changes image data in a destructive way"
  [path]
  (def pic (pingo/read-file path))
  {:name path
   :data (pic :data)
   :width (pic :width)
   :height (pic :height)})

(defn- make-bin-node
  "Makes a node in the bin packing tree"
  [pic lower-bound right-bound]
  @{:pic pic
    :lower-bound lower-bound
    :right-bound right-bound
    :lower nil
    :right nil})

(defn- right-size
  "Gives you the space of a tree node's right area as a 2d tuple"
  [tree]
  [(tree :right-bound)
   ((tree :pic) :height)])

(defn- lower-size
  "Gives you the space of a tree node's lower area as a 2d tuple"
  [tree]
  [(+ (tree :right-bound) ((tree :pic) :width))
   (tree :lower-bound)])

(defn- pic-size
  "Gives you the size of a pic as a 2d tuple of numbers"
  [pic]
  [(pic :width) (pic :height)])

(defn- fit
  "Takes two 2d tuples of numbers as points and checks the first is lesser than
  the second in each dimension"
  [point bound]
  (and (<= (point 0) (bound 0)) (<= (point 1) (bound 1))))

(defn- add-to-bin
  "Tries to fit an item into the tree recursively. Returns true on success and
  false on failure"
  [tree pic]
  (def size (pic-size pic))
  (if (fit size (right-size tree))
    (if (nil? (tree :right))
      (do
        (set (tree :right) (make-bin-node pic
                                          (- ((tree :pic) :height) (pic :height))
                                          (- (tree :right-bound) (pic :width))))
        true)
      (if (add-to-bin (tree :right) pic)
        true
        (if (fit size (lower-size tree))
          (if (nil? (tree :lower))
            (do
              (set (tree :lower) (make-bin-node pic
                                                (- (tree :lower-bound)
                                                   (pic :height))
                                                (- (+ (tree :right-bound)
                                                      ((tree :pic) :width))
                                                   (pic :width))))
              true)
            (add-to-bin (tree :lower) pic))
          false)))
    false))

(defn make-atlas
  "Creates a texture atlas representation which contains tree of placements,
  but it lets you choose what to do with it all. width and height are the
  bounds of the atlas, passive is whether to crash on errors, and files are the
  string names of png files to get images from"
  [width height & files]
  (def sorted-files (sort-by (fn [pic] (- 0 (max (pic :width) (pic :height))))
                             (map load-named-pic files)))
  (def top (sorted-files 0))
  (if (or (> (top :width) width) (> (top :height) height))
    (errorf "Could not fit %s" (top :name)))
  (def bin-tree (make-bin-node top
                               (- height (top :height))
                               (- width (top :width))))
  (for i 1 (length sorted-files)
    (if (not (add-to-bin bin-tree (sorted-files i)))
      (errorf "could not fit %s" ((sorted-files i) :name))))
  bin-tree)

(defn each-atlas
  "Iterates over atlas nodes recursively, calling a function with intended
  arguments of [x y pic]. It doesn't do anything else. Also note that pic has
  a name field as well as the usual"
  [tree func &opt x y]
  (default x 0)
  (default y 0)
  (func x y (tree :pic))
  (if (not (nil? (tree :right)))
    (each-atlas (tree :right) func (+ x ((tree :pic) :width)) y))
  (if (not (nil? (tree :lower)))
    (each-atlas (tree :lower) func x (+ ((tree :pic) :height) y))))

(defn render-atlas
  "Takes an atlas and renders it to a single picture"
  [tree]
  (def width (+ (tree :right-bound) ((tree :pic) :width)))
  (def height (+ (tree :lower-bound) ((tree :pic) :height)))
  (def canvas (pingo/make-blank-image width height))
  (each-atlas tree
              (fn [x y pic]
                (pingo/superimpose canvas pic x y)))
  canvas)

(defn render-atlas-to-file
  "Renders an atlas to a file and evaluates to the overall picture as a
  souvenir"
  [tree filename]
  (def pic (render-atlas tree))
  (pingo/write-file pic filename)
  pic)
