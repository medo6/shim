The API doc uses R markdown and knitr. This way the API examples are
actually _run_ as part of the doc creation process (effectively
another level of tests).

Open the help.Rmd document in RStudio. It assumes that shim is running
on localhost and port 8080. Then create the processed help.html file
and copy it after success to the wwwroot/help.html file.

Alternatively, you can run the `./generate.sh` script and follow the
prompts.
