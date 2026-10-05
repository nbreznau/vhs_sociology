# Download the source data from Zenodo (Korte 2026, "VHS Mining Ethnology,
# Sociology, and Economics") and verify it against Zenodo's checksums.
#
# Files land in files/zenodo/ (git-ignored). 01_Data_Import.R uses the
# downloaded workbook when present and otherwise falls back to the frozen
# snapshot files/Repository.xlsx.
#
# A published record needs no login. For a draft or restricted record, set an
# access token first: Sys.setenv(ZENODO_TOKEN = "<your token>")

library("jsonlite")
library("tools")

zenodo_record <- Sys.getenv("ZENODO_RECORD", "19063511")
zenodo_token  <- Sys.getenv("ZENODO_TOKEN", "")
out_dir       <- "files/zenodo"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

with_token <- function(url) {
  if (zenodo_token == "") return(url)
  paste0(url, if (grepl("\\?", url)) "&" else "?", "access_token=", zenodo_token)
}

# Published records live under /records; drafts only under /deposit/depositions
meta <- tryCatch(
  fromJSON(with_token(paste0("https://zenodo.org/api/records/", zenodo_record)),
           simplifyVector = FALSE),
  error = function(e) NULL
)
if (is.null(meta) && zenodo_token != "") {
  meta <- fromJSON(with_token(paste0("https://zenodo.org/api/deposit/depositions/", zenodo_record)),
                   simplifyVector = FALSE)
}
if (is.null(meta)) {
  stop("Zenodo record ", zenodo_record, " is not publicly available. ",
       "Publish it, or set ZENODO_TOKEN for a draft/restricted record.")
}

files <- meta$files
if (length(files) == 0) stop("Zenodo record ", zenodo_record, " lists no files.")

for (f in files) {
  # /records and /deposit APIs name these fields differently
  name <- if (!is.null(f$key)) f$key else f$filename
  url  <- if (!is.null(f$links$content)) f$links$content else if (!is.null(f$links$self)) f$links$self else f$links$download
  md5  <- sub("^md5:", "", f$checksum)
  dest <- file.path(out_dir, name)

  if (file.exists(dest) && unname(md5sum(dest)) == md5) {
    message("Up to date: ", dest)
    next
  }
  message("Downloading ", name)
  download.file(with_token(url), dest, mode = "wb", quiet = TRUE)
  if (unname(md5sum(dest)) != md5) stop("Checksum mismatch for ", dest)
}

# Record what was downloaded, for the paper's data statement
writeLines(
  c(paste("record:", zenodo_record),
    paste("doi:", if (!is.null(meta$doi)) meta$doi else NA),
    paste("version:", if (!is.null(meta$metadata$version)) meta$metadata$version else NA),
    paste("downloaded:", format(Sys.time(), "%Y-%m-%d %H:%M %Z")),
    vapply(files, function(f) paste0("file: ", if (!is.null(f$key)) f$key else f$filename, "  ", f$checksum), "")),
  file.path(out_dir, "zenodo_manifest.txt")
)
