library(igraph)

############################################################
## MARK NEWMAN'S ALGORITHM AS PROPOSED IN  ARXIV REF: physics/0605087
## from: http://lists.gnu.org/archive/html/igraph-help/2007-03/msg00033.html

######################################################################################
# RETURN THE MODULARITY MATRIX AS DEFINED BY NEWMAN
# Q = A - B WHERE B IS BASED ON A PROBABILITY OF EXISTENCE OF AN EDGE
# IN THIS CASE BASED ON THE CONFIGURATION MODEL
######################################################################################
graph.modularity = function(g) {
  d <- degree(g)
  m <- ecount(g)
  vcnt <- vcount(g)
  B <- matrix(0,nrow = vcnt,ncol = vcnt)
  for (i in 1:vcnt) {
    for (j in 1:vcnt) {
      B[i,j] <- d[i] * d[j] / (2 * m)
    }
  }
  A <- get.adjacency(g)
  Q <- A - B
  return(Q)
}


######################################################################################
# detect.communities
# THE MAIN ROUTINE FROM WHERE COMMUNITIES ARE DETECTED USING THE MODULARITY MATRIX
######################################################################################
detect.communities = function(g,indvsbl = 0) {
  V(g)$lbl <- 1:vcount(g)
  V(g)$cmn <- rep(-1,vcount(g))
  g <- modularity.partitioning(g,g,indvsbl)
  ####
  #       clrs <- rainbow(max(V(g)$cmn) + 1)
  #       lay <- layout.kamada.kawai(g)
  #       plot(
  #         g,vertex.color = clrs[V(g)$cmn + 1],vertex.size = 2,layout = lay, vertex.label =
  #           NA, edge.arrow.size = 0
  #       )
  ####
  membership <- V(g)$cmn
  csize <- c()
  for (i in 1:max(V(g)$cmn + 1)) {
    csize[i] <- length(which(V(g)$cmn == (i - 1)))
  }
  ret <- list(g,membership,csize)
  names(ret) <- c("g","membership","csize")
  return(ret)
}

#####################################################
# modularity.partitioning
# THE RECURSIVE FUNCTION CALL STOPS WHEN A SUBDIVISION DOES
# NOT CONTRIBUTE TO THE MODULARITY (A NEGATIVE LARGEST EIGENVALUE)
#####################################################
modularity.partitioning = function(g,sg,indvsbl) {
  ## MODULARITY MATRIX OF THE SUBGRAPH
  Q <- graph.modularity(sg)
  ## EIGENVALUES OF THE MODULARITY
  eg <- eigen(Q);
  evl <- eg$values
  max_eval <- sort(evl,decreasing = T,index.return = T)
  ## IF INDIVISIBLE THEN COLOR/TAG THE COMMUNITY AND RETURN THE CURRENT GRAPH
  if (round(Re(max_eval$x[1]), digits = 2) <= indvsbl) {
    ## COLOR VERTICES IN THE COMMUNITY
    col <- max(V(g)$cmn) + 1
    V(g)[V(sg)$lbl]$cmn <- col
    return(g)
  }
  ## ELSE GET PRINCIPAL EIGENVECTOR
  v <- Re(eg$vectors[,max_eval$ix[1]])
  
  ## PARTITION THE VERTICES ACCORDING TO THE SIGNS OF THE EIGENVECTOR ELTS
  neg <- which(v < 0)
  pos <- which(v >= 0)
  ## COLOR VERTICES IN THE COMMUNITY
  ## RECURSIVELY EXPLORE THE PARTITION OF NEGATIVE EIGENVECTOR CONTRIBUTIONS
  if (length(neg) > 0) {
    g <- modularity.partitioning(g,induced_subgraph(g,V(sg)$lbl[neg]),indvsbl)
  }
  ## RECURSIVELY EXPLORE THE PARTITION OF POSITIVE EIGENVECTOR CONTRIBUTIONS
  if (length(pos) > 0) {
    g <- modularity.partitioning(g,induced_subgraph(g,V(sg)$lbl[pos]),indvsbl)
  }
  return(g)
}

# test.modularity=function(){
#   tree100 <- graph.tree(100,mode="undirected")
#   cmn1 <- detect.communities(tree100,0)
#   quartz();
#   cmn2 <- detect.communities(tree100,2)
#   print(cmn2$membership)
#
# }
# test.modularity()


cluster.leading.eigenvector.community = function (graph) {
  count_v = length(V(graph));
  
  clustering <-
    data.frame(
      cluster = rep(NA, count_v),index = rep(NA, count_v),name = rep(NA, count_v)
    )
  
  collection = decompose.graph(graph, min.vertices = 1)
  
  
  result_i = 1;
  cluster_i = 0
  collection_c = length(collection)
  for (subgraph_i in 1:collection_c) {
    subgraph = simplify(collection[[subgraph_i]], TRUE, TRUE, edge.attr.comb = list(weight = "max"))
    subgraph_vc = length(V(subgraph))
    subgraph_ec = length(E(subgraph))
    
    cat(
      paste(
        "subgraph:", subgraph_i,
        "|V|", subgraph_vc,
        "|E|", subgraph_ec,
        "done:", (subgraph_i / collection_c * 100),
        "% \n"
      )
    )
    
    if (subgraph_vc < 5) {
      cluster_i = cluster_i + 1
      for (index in 1:subgraph_vc) {
        clustering[result_i,] <-
          list(cluster_i, index, V(subgraph)[index]$name)
        result_i <- result_i + 1
      }
      next
    }
    
    communities = detect.communities(subgraph, 3)
    membership = communities$membership
    
    for (community in sort(unique(membership))) {
      cluster_i = cluster_i + 1
      community_i = 1
      for (index in 1:length(membership)) {
        if (membership[index] == community) {
          clustering[result_i,] = list(cluster_i, community_i, V(subgraph)[index]$name)
          community_i = community_i + 1
          result_i = result_i + 1
        }
      }
    }
  }
  return(clustering)
}
