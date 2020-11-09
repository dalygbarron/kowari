(include pingo)

(defn make-atlas
  "Creates a texture atlas representation which contains the final rendered
  image and the tree of placements, but it lets you choose what to do with it
  all"
  [width height passive & files]
  (def sorted-files
    (sort-by (fn [pic] (max (pic :width) (pic :height)))
             (map (fn [file] (pingo/read-file file)) files)))
  (def atlas-pic (pingo/make-blank-image width height))

  
