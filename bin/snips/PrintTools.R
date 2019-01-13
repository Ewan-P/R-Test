##### Possible print functions
https://stackoverflow.com/questions/10587621/how-to-print-to-paper-a-nicely-formatted-data-frame

The printr package is a good option for printing data.frames, help pages, vignette listings, and dataset listings in knitr documents.

From the documentation page:
  
options(digits = 4)
set.seed(123)
x = matrix(rnorm(40), 5)
dimnames(x) = list(NULL, head(LETTERS, ncol(x)))
knitr::kable(x, digits = 2, caption = "A table produced by printr.")

