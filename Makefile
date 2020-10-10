#
# Makefile to generate the pdf
#

# ----------------------------------------------------------
name = projekt
aux = out
folder = bin
# ----------------------------------------------------------

# ----------------------------------------------------------
.PHONY: build
.PHONY: encrypt
.PHONY: debugTeX
.PHONY: debugBib
.PHONY: debugMerge
.PHONY: run
.PHONY: clear
.PHONY: clean
.PHONY: help
# ----------------------------------------------------------

# |------------------------------------------------------|
# | Execution order for individual flags to make command |
# |------------------------------------------------------|

# | ----------- | ------------------------------ |
# | Command     | Execution order                |
# | ----------- | ------------------------------ |
# | Make        | build -> run -> clean -> clear |
# | Make build	| build                          |
# | Make clear	| clean -> clear                 |
# | Make clean	| clear                          |
# | ----------- | ------------------------------ |

# |-----------------------------------------------------------------------------------|
# | build part is more complicated, so here is the execution order for that part only |
# |-----------------------------------------------------------------------------------|

# | ---- | ---------------------- | ----------------------------------------------------------------------------------- |
# | part | name										| Description																																					|
# | ---- | ---------------------- | ----------------------------------------------------------------------------------- |
# | 1. 	 | debugTeX -> debugBiB   | creates bin folder and runs python script against projekt1, projekt2 and literatura |
# | 2. 	 | debugBib -> debugMerge | debugs bibliography file                                                            |
# | 3. 	 | debugMerge -> build 	  | compiles output PDF once more to ensure links and bibliography are in order         |
# | 4. 	 | build -> encrypt       | one more compilation and mv to the root folder                                      |
# | 5. 	 | encrypt                | encrypts the final output PDF file                                                  |
# | ---- | ---------------------- | ----------------------------------------------------------------------------------- |

# |----------------------- PART 4 --------------------------------------------------|
# | 4.1 -> build step, prerequisite dubugMerge step                                 |
# | 4.2 -> cd to $folder (view folder variable at the beginning of the file)        |
# | 4.3 -> compiles $aux.pdf (out.pdf) using pdfcslatex                             | <--- set your LaTeX compiler, pdfcslatex for MiXTeX base, for me, pdflatex
# | 4.4 -> cd to root                                                               |
# | 4.5 -> moves $aux.pdf (out.pdf) to root and changes name to $name.pdf (projekt) |
# |---------------------------------------------------------------------------------|
build: debugMerge
	@cd $(folder)/; \
	 pdflatex $(aux).tex; \
	 cd ../; \
	 mv $(folder)/$(aux).pdf $(name).pdf
# |---------------------------------------------------------------------------------|

# |------------------------ PART 5 -------------------------------------------------|
# | 5.1 -> encrypt step, prerequisite build step                                    |
# | 5.2 -> encrypting pdf usign qpdf and renaming projekt.pdf to out.pdf            |
# | 5.3 -> renaming out.pdf to projekt.pdf                                          |
# | --------------------------------------------------------------------------------|
encrypt: build
	@qpdf projekt.pdf --encrypt "" own 128 --accessibility=y --extract=y --print=full --assemble=n --annotate=n --form=n --modify-other=n --modify=none -- out.pdf; \
	 mv out.pdf $(name).pdf
# |---------------------------------------------------------------------------------|

# |------------------------ PART 1 -------------------------------------------------------------------------------|
# | 1.1 -> debugTeX step, no prerequisite                                                                         |
# | 1.2 -> creates empty directory                                                                                |
# | 1.3 -> creates obash.tex file in that directory                                                               |
# | 1.4 -> runs python script against projekt1.tex                                                                | <--- set your python version (3.7 base, for me 3.9)
# | 1.5 -> runs python script against projekt2.tex                                                                | <--- set your python version (3.7 base, for me 3.9)
# | 1.6 -> creates empty bibliography file                                                                        |
# | 1.7 -> runs python script against literatura.bib and outputs it to the aforementioned empty bibliography file | <--- set your python version (3 base, for me 3.9)
# | 1.8 -> force copy of projekt.tex                                                                              |
# | 1.9 -> force copy of titulniStrana.tex                                                                        |
# | 1.10 -> force copy of seznamZkratek.tex                                                                       |
# | 1.11 -> cd to the new (bin) folder                                                                            |
# | 1.12 -> checks if directory called /pics exists, if not -> creates it and creates soft link                   |
# | 1.13 -> compiles main LaTeX file                                                                              | <--- set your LaTeX compiler, pdfcslatex for MiXTeX base, for me, pdflatex
# | 1.14 -> cd back to root                                                                                       |
# |---------------------------------------------------------------------------------------------------------------|
debugTeX:
	@mkdir -p $(folder); \
	 echo " " > $(folder)/obsah.tex; \
	 python3.9 aux.py 2 projekt1.tex >> $(folder)/projekt1.tex; \
	 python3.9 aux.py 2 projekt2.tex >> $(folder)/projekt2.tex; \
	 echo " " > $(folder)/$(aux).bib; \
	 python3.9 aux.py 1 literatura.bib >> $(folder)/$(aux).bib; \
	 cp -f projekt.tex $(folder)/$(aux).tex; \
	 cp -f titulniStrana.tex $(folder)/; \
	 cp -f seznamZkratek.tex $(folder)/; \
	 cd $(folder)/; \
	 ! [ -d pics ] && ln -s ../pics pics;\
	 pdflatex $(aux).tex; \
	 cd ../;
# |---------------------------------------------------------------------------------------------------------------|

# |------------------------ PART 2 --------------------------|
# | 2.1 -> debugBib step, prerequisite debugTeX step         |
# | 2.2 -> cd to bin                                         |
# | 2.3 -> runs bibtex against out                           |
# | 2.4 -> cd back to root                                   |
# |----------------------------------------------------------|
debugBib: debugTeX
	@cd $(folder)/; \
	 bibtex $(aux); \
	 cd ../;
# |----------------------------------------------------------|

# |------------------------ PART 3 --------------------------|
# | 3.1 -> debugMerge step, prerequisite debugBib step       |
# | 3.2 -> cd to bin                                         |
# | 3.3 -> compiles $aux.tex using pdfcslatex                |  <--- set your LaTeX compiler, pdfcslatex for MiXTeX base, for me, pdflatex
# | 3.4 -> cd back to root                                   |
# |----------------------------------------------------------|
debugMerge: debugBib
	@cd $(folder)/; \
	 pdflatex $(aux).tex; \
	 cd ../;
# |----------------------------------------------------------|

# |------------------------ RUN -----------------------------|
# | RUN.1 -> run step for Make                               |
# | RUN.2 -> shows output pdf in evince                      |
# |----------------------------------------------------------|
run:
	@evince $(name).pdf;\
# |----------------------------------------------------------|

# |------------------------ CLEAR -----------------------------------|
# | CLEAR.1 -> run step for Make/Make clear, prerequisite clean step |
# | CLEAR.2 -> deletes all generated files                           |
# |------------------------------------------------------------------|
clear: clean
	@rm -f $(name).pdf; \
# |------------------------------------------------------------------|

# |------------------------ CLEAN ---------------------------|
# | CLEAN.1 -> run step for Make/Make clean, no prerequisite |
# | CLEAN.2 -> deletes all temporary files                   |
# |----------------------------------------------------------|
clean:
	@rm -rf $(folder);
# |----------------------------------------------------------|

# ------------------------ HELP, can be invoked by typing Make help --------------------------
help:
	@echo "build:    Generate pdf file."; \
	 echo "clear:    Delete all generated files."; \
	 echo "clean:    Delete all temporary files."; \
	 echo "help:     Print help for Makefile."

# Generate PDF and remove bin
all: build clean
