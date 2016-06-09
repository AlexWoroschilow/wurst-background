#!/bin/env Rscript
# setwd()
# 
options(warn=0)

script.path <- function(){
    cmd.args <- commandArgs()
    m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)
    script.dir <- dirname(regmatches(cmd.args, m))
    if(length(script.dir) == 0) stop("can't determine script dir: please call the script with Rscript")
    if(length(script.dir) > 1) stop("can't determine script dir: more than one '--file' argument detected")
    return(script.dir)
}

arguments = commandArgs(trailingOnly = TRUE)
setwd(script.path())

source('lib/igraph.r', chdir = TRUE)
source('lib/assert.r', chdir = TRUE)



assert(!is.na((file_source = arguments[1])), "You have to define an input file, for example super_graph.ncol")
assert(!is.na((file_result = arguments[2])), "You have to define an output file, for example super_graph.clust")

filter_weight = 0.5

cat(paste("read graph file:", file_source, "\n"))
G = read.graph(file_source, format = 'ncol')

G = delete.edges(G, which(E(G)$weight < filter_weight))
G = delete.edges(G, which(is.na(E(G)$weight)))

G = as.undirected(G, "each")
G = as.undirected(G, "collapse")

tryCatch({
  clsuter = cluster.leading.eigenvector.community(G)
  write(paste(clsuter$cluster, "\t", clsuter$index, "\t", clsuter$name), file = file_result)
}, error = function(w) {
  stop(paste("Exception: can not read graph file", plot(subgraph)))
})
