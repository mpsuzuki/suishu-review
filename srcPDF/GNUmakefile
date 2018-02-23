PDFS_2016 = \
	16263-shuishu.pdf

PDFS_2017 = \
	17239-n4839-shuishu.pdf \
	17336-n4894-shuishu-adhoc.pdf \
	17366r-n4922-5th-ed-pdam2-2-chart.pdf

all:
	for f in $(PDFS_2016) ; do if test ! -r $${f} ; then wget -nc http://www.unicode.org/L2/L2016/$${f} ; fi ; done
	for f in $(PDFS_2017) ; do if test ! -r $${f} ; then wget -nc http://www.unicode.org/L2/L2017/$${f} ; fi ; done
