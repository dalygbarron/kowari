(include kowari)

# Yeah sorry fellas it's just a smoke test I don't want to have to compare
# individual pixels or whatever.

(def atlas (kowari/make-atlas 256
                              256
                              true
                              "test/a.png"
                              "test/b.png"
                              "test/c.png"))

