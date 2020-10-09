#
# Makefile to generate the pdf
#

# ----------------------------------------------------------
name = projekt									# Setting up $name variable
aux = out												# Setting up $name variable
folder = bin										# Setting up $name variable
# ----------------------------------------------------------

# ----------------------------------------------------------
.PHONY: build										# Setting up PHONY for Makefile not to be confused with a file
.PHONY: encrypt									# Setting up PHONY for Makefile not to be confused with a file
.PHONY: debugTeX								# Setting up PHONY for Makefile not to be confused with a file
.PHONY: debugBib								# Setting up PHONY for Makefile not to be confused with a file
.PHONY: debugMerge							# Setting up PHONY for Makefile not to be confused with a file
.PHONY: run											# Setting up PHONY for Makefile not to be confused with a file
.PHONY: clear										# Setting up PHONY for Makefile not to be confused with a file
.PHONY: clean										# Setting up PHONY for Makefile not to be confused with a file
.PHONY: help										# Setting up PHONY for Makefile not to be confused with a file
# ----------------------------------------------------------

# |------------------------------------------------------|
# | Execution order for individual flags to make command |
# |------------------------------------------------------|

# | ----------- | ------------------------------ |
# | Command 		| Execution order 							 |
# | ----------- | ------------------------------ |
# | Make				| build -> run -> clean -> clear |
# | Make build	| build 												 |
# | Make clear	| clean -> clear 								 |
# | Make clean	| clear 												 |
# | ----------- | ------------------------------ |

# |-----------------------------------------------------------------------------------|
# | build part is more complicated, so here is the execution order for that part only |
# |-----------------------------------------------------------------------------------|

# | ---- | ---------------------- | ----------------------------------------------------------------------------------- |
# | part | name							 			| Description               																													|
# | ---- | ---------------------- | ----------------------------------------------------------------------------------- |
# | 1. 	 | debugTeX -> debugBiB   | creates bin folder and runs python script against projekt1, projekt2 and literatura |
# | 2. 	 | debugBib -> debugMerge	| debugs bibliography file 																														|
# | 3. 	 | debugMerge -> build 		| compiles output PDF once more to ensure links and bibliography are in order 				|
# | 4. 	 | build -> encrypt 			| one more compilation and mv to the root folder 																			|
# | 5. 	 | encrypt                | encrypts the final output PDF file 																									|
# | ---- | ---------------------- | ----------------------------------------------------------------------------------- |

# |----------------------- PART 4 --------------------------------------------------|
# | 4.1 -> build step, prerequisite dubugMerge step                                 |
# | 4.2 -> cd to $folder (view folder variable at the beginning of the file)        |
# | 4.3 -> compiles $aux.pdf (out.pdf) using pdfcslatex                             |
# | 4.4 -> cd to root                                                               |
# | 4.5 -> moves $aux.pdf (out.pdf) to root and changes name to $name.pdf (projekt) |
# |---------------------------------------------------------------------------------|
build: debugMerge																							# 4.1                 |
	@cd ./$(folder); \																					# 4.2                 |
	 pdflatex $(aux).tex; \		  																# 4.3                 | <--- set your LaTeX compiler, pdfcslatex for MiXTeX base, for me, pdflatex
	 cd ../; \																									# 4.4                 |
	 mv ./$(folder)/$(aux).pdf $(name).pdf											# 4.5                 |
# |---------------------------------------------------------------------------------|

# |------------------------ PART 5 -------------------------------------------------|
# | 5.1 -> encrypt step, prerequisite build step																		|
# | 5.2 -> encrypting pdf usign qpdf and renaming projekt.pdf to out.pdf						|
# | 5.3 -> renaming out.pdf to projekt.pdf																					|
# | --------------------------------------------------------------------------------|
encrypt: build                                                # 5.1									|
	@qpdf projekt.pdf --encrypt "" own 128 --accessibility=y --extract=y --print=full --assemble=n --annotate=n --form=n --modify-other=n --modify=none -- out.pdf; \ # 5.2
	 mv out.pdf $(name).pdf                                     # 5.3									|
# |---------------------------------------------------------------------------------|

# |------------------------ PART 1 -------------------------------------------------------------------------------|
# | 1.1 -> debugTeX step, no prerequisite																																					|
# | 1.2 -> creates empty directory																																								|
# | 1.3 -> creates obash.tex file in that directory																																|
# | 1.4 -> runs python script against projekt1.tex																																|
# | 1.5 -> runs python script against projekt2.tex																																|
# | 1.6 -> creates empty bibliography file																																				|
# | 1.7 -> runs python script against literatura.bib and outputs it to the aforementioned empty bibliography file |
# | 1.8 -> force copy of projekt.tex																																							|
# | 1.9 -> force copy of titulniStrana.tex																																				|
# | 1.10 -> force copy of seznamZkratek.tex																																				|
# | 1.11 -> cd to the new (bin) folder																																						|
# | 1.12 -> checks if directory called /pics exists, if not -> creates it and creates soft link										|
# | 1.13 -> compiles main LaTeX file																																							|
# | 1.14 -> cd back to root																																												|
# |---------------------------------------------------------------------------------------------------------------|
debugTeX:																															# 1.1																				|
	@mkdir -p $(folder); \																							# 1.2																				|
	 echo " " > ./$(folder)/obsah.tex; \																# 1.3																				|
	 python3.9 aux.py 2 projekt1.tex >> ./$(folder)/projekt1.tex; \			# 1.4																				| <--- set your python version (3.7 base, for me 3.9)
	 python3.9 aux.py 2 projekt2.tex >> ./$(folder)/projekt2.tex; \			# 1.5																				| <--- set your python version (3.7 base, for me 3.9)
	 echo " " > ./$(folder)/$(aux).bib; \																# 1.6																				|
	 python3.9 aux.py 1 literatura.bib >> ./$(folder)/$(aux).bib; \			# 1.7																				| <--- set your python version (3 base, for me 3.9)
	 cp -f ./projekt.tex ./$(folder)/$(aux).tex; \											# 1.8																				|
	 cp -f ./titulniStrana.tex ./$(folder); \														# 1.9																				|
	 cp -f ./seznamZkratek.tex ./$(folder); \														# 1.10																			|
	 cd ./$(folder); \																									# 1.11																			|
	 ! [ -d ./pics ] && ln -s ../pics pics;\														# 1.12																			|
	 pdflatex $(aux).tex; \																						  # 1.13																			| <--- set your LaTeX compiler, pdfcslatex for MiXTeX base, for me, pdflatex
	 cd ../;																														# 1.14																			|
# |---------------------------------------------------------------------------------------------------------------|

# |------------------------ PART 2 --------------------------|
# | 2.1 -> debugBib step, prerequisite debugTeX step         |
# | 2.2 -> cd to bin                                         |
# | 2.3 -> runs bibtex against out                           |
# | 2.4 -> cd back to root                                   |
# |----------------------------------------------------------|
debugBib: debugTeX										# 2.1                  |
	@cd ./$(folder); \									# 2.2                  |
	 bibtex $(aux); \										# 2.3                  |
	 cd ../;														# 2.4                  |
# |----------------------------------------------------------|

# |------------------------ PART 3 --------------------------|
# | 3.1 -> debugMerge step, prerequisite debugBib step       |
# | 3.2 -> cd to bin                                         |
# | 3.3 -> compiles $aux.tex using pdfcslatex                |
# | 3.4 -> cd back to root                                   |
# |----------------------------------------------------------|
debugMerge: debugBib									# 3.1									 |
	@cd ./$(folder); \									# 3.2                  |
	 pdflatex $(aux).tex; \	  					# 3.3                  | <--- set your LaTeX compiler, pdfcslatex for MiXTeX base, for me, pdflatex
	 cd ../;														# 3.4                  |
# |----------------------------------------------------------|

# |------------------------ RUN -----------------------------|
# | RUN.1 -> run step for Make                               |
# | RUN.2 -> shows output pdf in evince                      |
# |----------------------------------------------------------|
run:																	 # RUN.1               |
	@evince $(name).pdf;\								 # RUN.2               |
# |----------------------------------------------------------|

# |------------------------ CLEAR -----------------------------------|
# | CLEAR.1 -> run step for Make/Make clear, prerequisite clean step |
# | CLEAR.2 -> deletes all generated files                           |
# |------------------------------------------------------------------|
clear: clean														# CLEAR.1                    |
	@rm -f ./$(name).pdf; \								# CLEAR.2                    |
# |------------------------------------------------------------------|

# |------------------------ CLEAN ---------------------------|
# | CLEAN.1 -> run step for Make/Make clean, no prerequisite |
# | CLEAN.2 -> deletes all temporary files                   |
# |----------------------------------------------------------|
clean:																	# CLEAN.1            |
	@rm -rf $(folder)											# CLEAN.2            |
# |----------------------------------------------------------|

# ------------------------ HELP, can be invoked by typing Make help --------------------------
help:
	@echo "build:    Generate pdf file."; \
	 echo "clear:    Delete all generated files."; \
	 echo "clean:    Delete all temporary files."; \
	 echo "help:     Print help for Makefile."
