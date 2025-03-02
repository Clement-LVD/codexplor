# Unit tests using testthat
#  library(testthat)

  test_that("filter_subgraph extracts correct nodes", {

  library(igraph)
    g <- make_ring(10, directed = T)
    V(g)$name <- as.character(1:10)
    sub_g <- filter_igraph_egonetwork(g, "1$", 0, 2)
# 0 level inbut 2 levels out (1>2>3)!
    expect_equal(c("1","2","3"), V(sub_g)$name)

    sub_g <- filter_igraph_egonetwork(g, "1$", 1,0)
    expect_equal(c( "1","10"), V(sub_g)$name)
 # (10 -> 1 is the only one in a directed ring of 10

    sub_g <- filter_igraph_egonetwork(g, "1$", 1,1)
    expect_equal(c("1" , "2", "10"), V(sub_g)$name)
    # 2 above reunified


  test_that("filter_subgraph returns empty graph for no match", {
    g <- make_ring(10)
    V(g)$name <- as.character(1:10)
    sub_g <- filter_igraph_egonetwork(g,regex =  "99", 0, 0)

    expect_equal(vcount(sub_g), 0)
  })
})
