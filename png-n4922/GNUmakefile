all: ../srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf
	ucsIntFirst=`echo "ibase=16 ; 1B300" | bc` ; \
	ucsIntLast=`echo "ibase=16 ; 1B52F" | bc` ; \
	for ucsInt in `seq $$ucsIntFirst $$ucsIntLast` ; \
	do \
		ucsHex=`printf "U+%05X" $$ucsInt` ; \
		if test `grep -l $$ucsHex < geometry.txt | wc -l` -gt 0 -a ! -r $$ucsHex.png ; \
		then \
			cmd=`grep $$ucsHex < geometry.txt | \
			     awk '{printf("pdftoppm -png -r 600 -W %d -H %d -x %d -y %d -f %d -l %d $< %s\n", $$2, $$3, $$4, $$5, $$6, $$6, $$1)}'` ; \
			echo $$cmd ; \
			eval $$cmd ; \
		fi ; \
	done

clean:
	rm -f *.png
