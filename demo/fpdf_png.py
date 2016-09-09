import os
from fpdf import FPDF

PATH = "../image/png432/"
imagelist = os.listdir(PATH)

pdf = FPDF()
"""
pdf.add_page()
pdf.image("../image/page_9.png", 0, 0, 210, 297)
pdf.add_page()
pdf.image("../image/page_116.png", 0, 0)
"""
for image in imagelist:
	image = PATH + image
	#print(image)
	pdf.add_page()
	pdf.image(image,0, 0, 210, 297)
"""
PATH = "../image/image200/"
imagelist = os.listdir(PATH)

for image in imagelist:
	image = PATH + image
	#print(image)
	pdf.add_page()
	pdf.image(image,0, 0, 210, 297)
"""
pdf.output("fpdf_png.pdf", "F")

