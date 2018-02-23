PDF_TEXT = ShuishuLogogramNameList.txt ShuishuRadicalNameList.txt

all: $(PDF_TEXT)

ShuishuLogogramNameList.txt: srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf
	pdftotext -raw -f 87 -l 92 srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf $@

ShuishuRadicalNameList.txt: srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf
	pdftotext -raw -f 93 -l 93 srcPDF/17366r-n4922-5th-ed-pdam2-2-chart.pdf $@

clean:
	rm -f $(PDF_TEXT)
