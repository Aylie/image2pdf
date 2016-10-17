use strict;
use warnings;
use POSIX;
use PDF::API2;
use Getopt::Long;

sub Usage
{
	print ("-imgperpage=[#image/page], range = 1~9\n");
	print ("-input=[input image directory path]\n");
	print ("-output=[output pdf path]\n");
}

# initialize arguments
my $imgPerPage = 1;
my $pathIn = "./image/mix/";
my $pathOut = "./";
my $usage = 0;

# parse arguments
GetOptions(
	"imgperpage=i"	=> \$imgPerPage,	#int
	"input=s"	=> \$pathIn,		#string
	"output=s"	=> \$pathOut,		#string
	"help"		=> \$usage,		#flag
) or die "Error : command line arguments error\n";

if (1 == $usage) {
	&Usage();
}
# check input #image/page
if ($imgPerPage < 0 or $imgPerPage > 9) {
	&Usage();
	exit;
}
# check input path format
if (defined($pathIn) and ($pathIn ne /\/$/)) {
	$pathIn = $pathIn."/";
}
# check output path format
if (defined($pathOut) and ($pathOut ne /\/$/)) {
	$pathOut = $pathOut."/";
}

# create pdf file
my $pdf = PDF::API2->new();

# initial doc properties
my $a4Width = 595;
my $a4Height = 842;
my $blank = 50;
my $imgCnt = -1;
my $docWidth = $a4Width;
my $docHeight = $a4Height;
if (($imgPerPage == 2) or ($imgPerPage == 5) or ($imgPerPage == 6) or ($imgPerPage == 7) or ($imgPerPage == 8)) {
	$docWidth = $a4Height;
	$docHeight = $a4Width;
}

# count block size
my $type = $imgPerPage;
if (2 < $type) {
	$type = ($imgPerPage == 9)? ($imgPerPage / 3) : ($imgPerPage / 2);
	$type = ceil($type);
}
my $crop = ceil($imgPerPage / $type);
my $blockWidth = $docWidth / $type;
my $blockHeight = $docHeight / $crop;
my $page;

# open directory
opendir(DIR, $pathIn) or die "Error : open $pathIn fail\n";

# read directory
while (my $image = readdir DIR) {
	next if ($image eq "." or $image eq "..");

	# load image
	my $png = $pdf->image_png($pathIn.$image);
	$imgCnt++;

	# get image size
	my $imgWidth = $png->width();
	my $imgHeight = $png->height();

	# add new page
	if (0 == ($imgCnt % $imgPerPage)) {
		# Add a page
		$page = $pdf->page();

		# Set page size
		$page->mediabox($docWidth, $docHeight);
	}

	# calculate scaling
	my $scale = 1;
	# left blank between images
	my $placeWidth = $blockWidth - $blank;
	my $placeHeight = $blockHeight - $blank;
	$scale = ($placeWidth/$imgWidth) < ($placeHeight/$imgHeight) ? $placeWidth/$imgWidth : $placeHeight/$imgHeight;

	# resize image
	$imgWidth *= $scale;
	$imgHeight *= $scale;

	# calculate pos
	my $blockCnt = $imgCnt % $imgPerPage;
	my $xpos = ($blockCnt % $type) * $blockWidth;
	my $ypos = 0;
	if (1 < $crop) {
		$ypos = ($crop - floor($blockCnt / $type) - 1) * $blockHeight;
	}

	# alignment = center
	$xpos += ($blockWidth - $imgWidth) / 2;
	$ypos += ($blockHeight - $imgHeight) / 2;

	# add image to pdf
	my $gfx = $page->gfx;
	$gfx->image($png, $xpos, $ypos, $imgWidth, $imgHeight);

	# add black frame to image
	my $frame = $page->gfx;
	# set color
	$frame->strokecolor('black');
	# set width
	$frame->linewidth(1);
	# set position and size (xpos, ypos, width, height)
	$frame->rect($xpos-0.5, $ypos-0.5, $imgWidth+1, $imgHeight+1);
	# place rectangle frame
	$frame->stroke;
}

# close and save pdf
$pdf->saveas($pathOut."pdfapi2_png.pdf");
