use strict;
use warnings;
use PDF::API2;
use Getopt::Long;

# parse arguments
my $imgPerPage = 1;
my $pathIn = "./image/ppt/png/";
my $pathOut = "./pdfapi2_png.pdf";

GetOptions(
	"img/page=i"	=> \$imgPerPage,	#int
	"input=s"	=> \$pathIn,		#string
	"output=s"	=> \$pathOut,		#string
) or die "Error : command line arguments error\n";

# create pdf file
my $pdf = PDF::API2->new();

# get a4 size
#my @size = $pdf->get_page_size('A4');
#print @size."\n";
#my $a4page = $pdf->page();
#$a4page->mediabox('A4');
my $a4Width = 595;
my $a4Height = 842;

# open directory
opendir(DIR, $pathIn) or die "Error : open $pathIn fail\n";

# read directory
while (my $image = readdir DIR) {
	next if ($image eq "." or $image eq "..");

	# load image
	my $png = $pdf->image_png($path.$image);

	# count scaling
	my $imgWidth = $png->width();
	my $imgHeight = $png->height();
#	print "width = $width\nheight = $height\n";
	
	my $scale = 0;
	my $docWidth = $a4Width;
	my $docHeight = $a4Height;
	
	# Add a page
	my $page = $pdf->page();

	if ($imgWidth > $imgHeight) {
		$docWidth = $a4Height;
		$docHeight = $a4Width;
	}
	# Set page size
	$page->mediabox($docWidth, $docHeight);

	# calculate scaling
	$scale = ($docWidth/$imgWidth) < ($docHeight/$imgHeight) ? $docWidth/$imgWidth : $docHeight/$imgHeight;
	
	$imgWidth *= $scale;
	$imgHeight *= $scale;

	# calculate pos
	my $xpos = ($docWidth - $imgWidth) / 2;
	my $ypos = ($docHeight - $imgHeight) / 2;

	# add image to pdf
	my $gfx = $page->gfx;
	$gfx->image($png, $xpos, $ypos, $imgWidth, $imgHeight);
}

# close and save pdf
$pdf->saveas($pathOut);
