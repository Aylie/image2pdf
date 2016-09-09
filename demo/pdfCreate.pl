use strict;
use warnings;
use PDF::Create;

# create pdf file
my $pdf = PDF::Create->new('filename' => 'pdfCreate_test.pdf');

# add a a4 page
my $a4 = $pdf->new_page('MediaBox' => $pdf->get_page_size('A4'));
my $a4L = $pdf->new_page('MediaBox' => $pdf->get_page_size('A4L'));

# get a4 size
#my @size = $pdf->get_page_size('A4');
#print @size."\n";
my $a4Width = 595;
my $a4Height = 842;

# open directory
my $path = "./image/test_jpg/";
opendir(DIR, $path) or die "Error : open $path fail\n";

# read directory
while (my $image = readdir DIR) {
	next if ($image eq "." or $image eq "..");

	# load image
	my $jpg = $pdf->image($path.$image);

	# count scaling
	my $width = $jpg->{width};
	my $height = $jpg->{height};
#	print "width = $width\nheight = $height\n";
	
	my $page;
	my $scale = 0;
	my $docWidth = $a4Width;
	my $docHeight = $a4Height;

	if ($width > $height) {
		$page = $a4L->new_page;
		$docWidth = $a4Height;
		$docHeight = $a4Width;
	}
	else {
		$page = $a4->new_page;
	}
	# calculate scaling
	$scale = ($docWidth/$width) < ($docHeight/$height) ? $docWidth/$width : $docHeight/$height;
	
	# calculate pos
	my $xpos = ($docWidth - $width*$scale) / 2;
	my $ypos = ($docHeight - $height*$scale) / 2;

	# add image to pdf
	$page->image( 'image' => $jpg,
		      'xscale' => $scale,
		      'yscale' => $scale,
		      'xpos' => $xpos,
		      'ypos' => $ypos		);
}

# close and save pdf
$pdf->close;
