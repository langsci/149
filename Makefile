# specify the main file and all the files that you are including
SOURCE=  hoehle-include.tex main.tex $(wildcard local*.tex) $(wildcard chapters/*.tex) \
langsci/langscibook.cls

LANGSCI-STYLES=~/Documents/Dienstlich/Projekte/OALI/Git-HUB/latex/langsci/

# specify your main target here:
pdf: main.bbl main.pdf  #by the time main.pdf, bib assures there is a newer aux file

all: pod cover

complete: index main.pdf

index:  main.snd

bib: main.bbl

satz.pdf: main.pdf
	cp main.pdf satz.pdf
#	git commit

# everything depends on page numbers. bibtex items reference chapters of the main book.
# Therefore independent make goals do not work.
# biber has to run in order to make chapter footers

main.pdf: $(SOURCE)
	xelatex -no-pdf main 
	sed -i.backup 's/Komplemen- tierer/Komplementierer/' main.toc #fix formatting error in toc 
	sed -i.backup 's/Komplemen- tierer/Komplementierer/' main.bbl
	sed -i.backup 's/of secondary/of\\\\secondary/' main.toc #fix formatting error in toc
	biber main 
	xelatex -no-pdf main 
	touch main.adx main.sdx main.ldx
	sed -i.backup s/.*\\emph.*// main.adx #remove titles which biblatex puts into the name index
	sed -i.backup s/.*Duden.*// main.adx  #remove Duden, he did not write the grammar
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' main.sdx # ordering of references to footnotes
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' main.adx
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' main.ldx
# 	sed -i.backup 's/Tappe/Tappe\\\\/' main.toc #fix formatting error in toc
# 	sed -i.backup 's/eine natürliche/eine natürliche\\\\/' main.toc #fix formatting error in toc
	sed -i.backup 's/Komplemen- tierer/Komplementierer/' main.toc #fix formatting error in toc
	sed -i.backup 's/Komplemen- tierer/Komplementierer/' main.bbl
	sed -i.backup 's/of secondary/of\\\\secondary/' main.toc #fix formatting error in toc
	python3 fixindex.py
	mv mainmod.adx main.adx
	makeindex -o main.and main.adx
	makeindex -o main.lnd main.ldx
	makeindex -o main.snd main.sdx 
	xelatex main 


#create a png of the cover
cover: FORCE
	convert main.pdf\[0\] -quality 100 -background white -alpha remove -bordercolor black -border 2  cover.png
	cp cover.png googlebooks_frontcover.png
	convert -geometry 50x50% cover.png covertwitter.png
	display cover.png

#prepare for print on demand services	
pod: bod createspace googlebooks

#prepare for submission to BOD
bod: bod/bodcontent.pdf 

bod/bodcontent.pdf: complete
	sed "s/output=short/output=coverbod/" main.tex >bodcover.tex 
	xelatex bodcover.tex  
	xelatex bodcover.tex  
	mv bodcover.pdf bod
	./filluppages 4 main.pdf bod/bodcontent.pdf 

# prepare for submission to createspace
createspace:  createspace/createspacecontent.pdf 

createspace/createspacecontent.pdf: complete
	sed "s/output=short/output=covercreatespace/" main.tex >createspacecover.tex 
	xelatex createspacecover.tex 
	xelatex createspacecover.tex 
	mv createspacecover.pdf createspace
	./filluppages 1 main.pdf createspace/createspacecontent.pdf 

googlebooks: googlebooks_interior.pdf

googlebooks_interior.pdf: complete
	cp main.pdf googlebooks_interior.pdf
	pdftk main.pdf cat 1 output googlebooks_frontcover.pdf 


langsci-styles:
	rsync -a $(LANGSCI-STYLES) langsci


#housekeeping	
clean:
	rm -f *.bak *~ *.backup *.tmp \
	*.adx *.and *.idx *.ind *.ldx *.lnd *.sdx *.snd *.rdx *.rnd *.wdx *.wnd \
	*.log *.blg *.ilg \
	*.aux *.toc *.cut *.out *.tpm *.bbl *-blx.bib *_tmp.bib \
	*.glg *.glo *.gls *.wrd *.wdv *.xdv \
	*.run.xml \
	chapters/*aux chapters/*~ chapters/*.bak chapters/*.backup

realclean: clean
	rm -f *.dvi *.ps *.pdf 

FORCE:



