###########################################################
###########################################################
###
### R file for simulating regression analyses and computing
### venn diagrams and ballantines.
###
### File created by Gjalt-Jorn Peters. Questions? You can
### contact me through http://behaviorchange.eu.
###
###########################################################
###########################################################

### For loading own functions
libraryPath <- "B:/Data/statistics/R/library/";

### Note that these first two functions don't actually
### do anything; they're just for loading packages and
### functions.

### This function checks whether a package is installed;
### if not, it installs it. It then loads the package.
safeRequire <- function(packageName) {
  if (!is.element(packageName, installed.packages()[,1])) {
    install.packages(packageName);
  }
  require(package = packageName, character.only=TRUE);
}

### This function checks whether the file for a
### self-made function exists; if so, it's loaded;
### if not, the file is downloaded from GitHub
loadOwnFunction <- function(fileName) {
  if (file.exists(paste0(libraryPath, paste0(fileName, ".r")))) {
    source(paste0(libraryPath, paste0(fileName, ".r")));
  } else {
    
    ### Note: I took this from
    ### https://github.com/gimoya/theBioBucket-Archives/blob/master/R/Functions/source_https.R
    ### and edited it to fit in here.
    
    # Filename: source_https.R
    # Purpose: function to source raw code from github project
    # Author: Tony Bryal
    # Date: 2011-12-10
    # http://tonybreyal.wordpress.com/2011/11/24/source_https-sourcing-an-r-script-from-github/
    safeRequire('RCurl');
    # read script lines from website using a security certificate
    script <- getURL(paste0("http://github.com/Matherion/library/raw/master/", fileName, ".r"),
                     followlocation = TRUE, cainfo = system.file("CurlSSL", "cacert.pem",
                                                                 package = "RCurl"));
    # parse lines and evaluate in the global environement
    eval(parse(text = script), envir= .GlobalEnv);
  }
}

###########################################################
### Load packages and functions
###########################################################

### Wrapper for computing partial correlations
loadOwnFunction('regSim');

###########################################################
### Start of simulations
###########################################################

means <- c(0, 0, 0);

covarianceMatrix <- matrix(c(  1,  .4,  .4,
                              .4,   1,  .4,
                              .4,  .4,   1), nrow=3, byrow=TRUE)
a <- regSim(means, covarianceMatrix);

covarianceMatrix <- matrix(c(  1, -.4,  .4,
                             -.4,   1,  .4,
                              .4,  .4,   1), nrow=3, byrow=TRUE)
b <- regSim(means, covarianceMatrix);

covarianceMatrix <- matrix(c( 1.00, 0.05, 0.30,
                              0.05, 1.00, 0.30,
                              0.30, 0.30, 1.00), nrow=3, byrow=TRUE)
c <- regSim(means, covarianceMatrix);

covarianceMatrix <- matrix(c( 1.00, 0.50, 0.70,
                              0.50, 1.00, 0.50,
                              0.70, 0.50, 1.00), nrow=3, byrow=TRUE)
d <- regSim(means, covarianceMatrix);

e <- regSim(means, covarianceMatrix, n=200);

#a;
#d;

###########################################################
###########################################################
### Using LaTeX (pdflatex) to generate a PDF
###########################################################
###########################################################

pdfLaTexPath <- "B:/Apps/MiKTeX/miktex/bin";

safeRequire('knitr');

textToKnit <- paste0('\\documentclass[a4paper,portrait,10pt]{article}

% For adjusting margins
\\usepackage[margin=15mm]{geometry}

% !Rnw weave = knitr

\\title{Regression simulations}
\\author{Gjalt-Jorn Peters}
\\begin{document}
\\raggedright
\\noindent
<< echo=FALSE, warning=FALSE, dev="pdf", fig.width=8/2.54, fig.height=8/2.54 >>=
grid.draw(a$venn.diagram);
@
\\begin{verbatim}
<< echo=FALSE, results="asis" >>=
cat(print(a, digits=4, showPlot=FALSE));
@
\\end{verbatim}
\\newpage
<< echo=FALSE, warning=FALSE, dev="pdf", fig.width=8/2.54, fig.height=8/2.54 >>=
grid.draw(d$venn.diagram);
@
\\begin{verbatim}
<< echo=FALSE, results="asis" >>=
cat(print(d, digits=4, showPlot=FALSE));
@
\\end{verbatim}
\\newpage
<< echo=FALSE, warning=FALSE, dev="pdf", fig.width=8/2.54, fig.height=8/2.54 >>=
grid.draw(e$venn.diagram);
@
\\begin{verbatim}
<< echo=FALSE, results="asis" >>=
cat(print(e, digits=4, showPlot=FALSE));
@
\\end{verbatim}
\\end{document}');

knit(text= textToKnit, output=paste0(getwd(), "/regSim.tex"));

### Convert the .tex file to a pdf
tryCatch(
  texOutput <- system(paste0('"', pdfLaTexPath, '/pdflatex" "',
                                 getwd(), '/regSim.tex" ',
                                 '-output-directory "', getwd(), '"'),
                          intern=TRUE)
  , error = function(e) {
    cat(paste("Error returned by pdflatex: ", e));
  }
);
