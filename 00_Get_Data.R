# Download the source data from Zenodo (Korte 2026, "VHS Mining Ethnology,
# Sociology, and Economics") and verify every file against Zenodo's MD5
# checksums. Files land in files/zenodo/ (git-ignored).
#
# While the record is an unpublished draft, it can only be read with a
# share-link token. Copy the part after "token=" from the share link and set it
# before running this script (do not commit it):
#   Sys.setenv(ZENODO_TOKEN = "<token>")
# Once the record is published, leave ZENODO_TOKEN unset.

library("jsonlite")
library("tools")

zenodo_record <- Sys.getenv("ZENODO_RECORD", "19063511")
zenodo_token  <- Sys.getenv("ZENODO_TOKEN", "")
out_dir       <- "files/zenodo"

# Files 01_Data_Import.R needs
required_files <- c(
  "Ethnology.csv", "Sociology.csv", "Economics.csv",
  "Courses_1962-2017.csv", "Enrollments_1962-2017.csv"
)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Drafts are served under /draft and need the token; published records don't
api_base <- paste0("https://zenodo.org/api/records/", zenodo_record,
                   if (zenodo_token != "") "/draft")
with_token <- function(url) {
  if (zenodo_token == "") url else paste0(url, "?token=", zenodo_token)
}

listing <- tryCatch(
  fromJSON(with_token(paste0(api_base, "/files")), simplifyVector = FALSE),
  error = function(e) {
    stop("Could not read the file list of Zenodo record ", zenodo_record, ". ",
         if (zenodo_token == "") "If the record is still a draft, set ZENODO_TOKEN (see top of script)."
         else "Check that ZENODO_TOKEN is the current share-link token.",
         call. = FALSE)
  }
)

entries <- listing$entries
if (length(entries) == 0) stop("Zenodo record ", zenodo_record, " lists no files.")

for (f in entries) {
  dest <- file.path(out_dir, f$key)
  md5  <- sub("^md5:", "", f$checksum)

  if (file.exists(dest) && unname(md5sum(dest)) == md5) {
    message("Up to date: ", f$key)
    next
  }
  message("Downloading ", f$key)
  download.file(with_token(f$links$content), dest, mode = "wb", quiet = TRUE)
  if (unname(md5sum(dest)) != md5) stop("Checksum mismatch for ", f$key)
}

missing <- setdiff(required_files, vapply(entries, `[[`, "", "key"))
if (length(missing) > 0) {
  stop("Zenodo record is missing files the analysis needs: ", paste(missing, collapse = ", "))
}

# Record what was downloaded (no token), for the paper's data statement
writeLines(
  c(paste("record:", zenodo_record),
    paste("concept DOI: 10.5281/zenodo.19063510"),
    paste("status:", if (zenodo_token == "") "published" else "draft (share link)"),
    paste("downloaded:", format(Sys.time(), "%Y-%m-%d %H:%M %Z")),
    vapply(entries, function(f) paste0("file: ", f$key, "  ", f$checksum), "")),
  file.path(out_dir, "zenodo_manifest.txt")
)
