use strict;
use warnings;
use PDF::API2;
use Getopt::Long;

sub GetPos
{
	my ($imgNum, $imgCnt, $blockWidth, $blockHeight) = @_
	my $type = ($imgNum == 9)? ($imgNum / 3) : ($imgNum / 2);
	my $crop = $imgNum / $type;
	
	$imgCnt = $imgCnt % $imgNum;
	my $xpos = ($imgCnt % $type) * $bloickWidth;
	my $ypos = ($crop - $imgCnt / $crop) * $blockHeight;

	return ($xpos, $ypos);
}

sub GetSize
{
	my ($imgNum, $docWidth, $docHeight) = @_
	my $type = ($imgNum == 9)? ($imgNum / 3) : ($imgNum / 2);
	my $crop = $imgNum / $type;
	
	if (1 == $imgNum)
		return ($docWidth, $docHeight);

	$imgWidth = $docHeight / $type;
	$imgHeight = $docWidth / $crop;
	
	return ($imgWidth, $imgHeight);
}



# define arguments
my $imgPerPage = 1;
my $pathIn = "./image/ppt/png/";
my $pathOut = "./pdfapi2_png.pdf";

# parse arguments
GetOptions(
	"img/page=i"	=> \$imgPerPage,	#int
	"input=s"	=> \$pathIn,		#string
	"output=s"	=> \$pathOut,		#string
) or die "Error : command line arguments error\n";

# create pdf file
my $pdf = PDF::API2->new();

# get a4 size
#my $a4page = $pdf->page();
#$a4page->mediabox('A4');
my $a4Width = 595;
my $a4Height = 842;
my $imgCnt = -1;
my ($imgWidth, $imgHeight) = GetSize($imgPerPage, $a4Width, $a4Height);

# open directory
opendir(DIR, $pathIn) or die "Error : open $pathIn fail\n";

# read directory
while (my $image = readdir DIR) {
	next if ($image eq "." or $image eq "..");

	# load image
	my $png = $pdf->image_png($path.$image);
	$imgCnt++;

#	# count scaling
#	my $imgWidth = $png->width();
#	my $imgHeight = $png->height();
#	print "width = $width\nheight = $height\n";
	
#	my $scale = 0;
#	my $docWidth = $a4Width;
#	my $docHeight = $a4Height;
	
	if (0 == (imgCnt % $imgPerPage)) {
		# Add a page
		my $page = $pdf->page();

		# Set page size
		$page->mediabox($a4Width, $a4Height);
	}

#	if ($imgWidth > $imgHeight) {
#		$docWidth = $a4Height;
#		$docHeight = $a4Width;
#	}

#	# calculate scaling
#	$scale = ($docWidth/$imgWidth) < ($docHeight/$imgHeight) ? $docWidth/$imgWidth : $docHeight/$imgHeight;
	
#	$imgWidth *= $scale;
#	$imgHeight *= $scale;

	# calculate pos
	my ($xpos, $ypos) = GetPos()

	# add image to pdf
	my $gfx = $page->gfx;
	$gfx->image($png, $xpos, $ypos, $imgWidth, $imgHeight);
}

# close and save pdf
$pdf->saveas($pathOut);
