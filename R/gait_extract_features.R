#####################################################################
## Extract Gait Features from mPower walking data
##
## Example to process first 10 rows from public walking table:
##   Rscript gait_extract_features.R syn5511449 1 10
## 
## Authors: Elias Chaibub Neto, J. Christopher Bare
## Sage Bionetworks (http://sagebase.org)
#####################################################################

gait_extract_features_main <- function() {
  args <- commandArgs(trailingOnly=TRUE)
  source_table <- args[1]
  limit <- as.integer(args[2])
  offset   <- as.integer(args[3])

  ## An RData file holding completed rows
  if (length(args)>3) {
    e <- new.env()
    load(args[4], envir=e)
    name <- ls(e)[1]
    completed_records <- get(name, envir=e)
  } else {
    completed_records <- data.frame()
  }

  ## syn5511449 = walking activity from public researcher portal
  ## syn4590866 = walking from mpower level 1
  walk <- synTableQuery(sprintf("SELECT * FROM %s LIMIT %s OFFSET %s", source_table, limit, offset))
  cat("dim(walk@values)=", dim(walk@values), "\n")

  walkToDownload <- walk
  toDownload <- !(walkToDownload@values$recordId %in% rownames(completed_records))
  walkToDownload@values <- walkToDownload@values[ toDownload ,]

  fileMap <- synDownloadTableColumns(walkToDownload, "deviceMotion_walking_outbound.json.items")

  outFilename=sprintf("gait_features_%d_%d.RData", limit, offset)
}

#' Extract gait features
#'
#' @param walk a synapseClient::Table object with walking activity metadata
#' @param fileMap mapping from file handle IDs to paths on the local file system
#' @param outFilename name of .RData file to write resulting feature data.frame
#' @param completed_records a data.frame of existing features in the same format as
#'                          this functions return value
#' @param alpha numeric value between 0 and 1 used in low pass filter
#'
#' @return a data.frame holding feature data
#'
gait_extract_features <- function(walk, fileMap, outFilename, completed_records, alpha=1) {

  if (missing(fileMap)) {
    fileMap <- synDownloadTableColumns(walk, "deviceMotion_walking_outbound.json.items")
  }
  if (missing(completed_records)) {
    completed_records <- list()
  }

  ldat <- fromJSON(file=fileMap[1])
  gdat <- ShapeGaitData(ldat)
  feat1 <- GetGaitFeatures(gdat, alpha)

  feat <- matrix(NA, nrow(walk@values), length(feat1))
  rownames(feat) <- walk@values$recordId
  colnames(feat) <- names(feat1)
  feat[1,] <- feat1

  n <- nrow(walk@values)
  cat(sprintf("Processing %d rows...\n", n))

  ## replace ntest by n to get all data
  for (i in 1:nrow(walk@values)) {
    cat(i, "\n")
    recordId <- walk@values[i,'recordId']
    if (recordId %in% rownames(completed_records)) {
      feat[i,] <- completed_records[recordId,]
    } else {
      try({
        fileHandleId <- walk@values[i,'deviceMotion_walking_outbound.json.items']
        filepath <- fileMap[fileHandleId]
        ldat <- rjson::fromJSON(file=filepath)
        gdat <- ShapeGaitData(ldat)
        feat[i,] <- GetGaitFeatures(gdat, alpha)
      })
    }
  }

  if (!missing(outFilename)) {
    save(feat, file=outFilename, compress=TRUE)
  }

  invisible(feat)
}
