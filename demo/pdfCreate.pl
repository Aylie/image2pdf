use strict;
use warnings;
use PDF::Create;

# create pdf file
my $pdf = PDF::Create->new('filename' => 'pdfCreate_jpg.pdf');

# add a a4 page
my $root = $pdf->new_page('MediaBox' => $pdf->get_page_size('A4'));

# get a4 size
#my @size = $pdf->get_page_size('A4');
#print @size."\n";
my $a4Width = 595;
my $a4Height = 842;

# open directory
my $path = "./image/jpg432/";
opendir(DIR, $path) or die "Error : open $path fail\n";

# read directory
while (my $image = readdir DIR) {
	next if ($image eq "." or $image eq "..");

	# new page inherit from $root
	my $page = $root->new_page;
	
	# load image
	my $jpg = $pdf->image($path.$image);

	# count scaling
	my $width = $jpg->{width};
	my $height = $jpg->{height};
#	print "width = $width\nheight = $height\n";
	my $scale = ($a4Width/$width) > ($a4Height/$height) ? $a4Width/$width : $a4Height/$height;
#	$scale = sprintf("%.50f", $scale); 
#	print "scale = $scale\n";

#	my $scale = 0.35;
	# add image to pdf
	$page->image( 'image' => $jpg,
		      'xscale' => $scale,
		      'yscale' => $scale,
		      'xpos' => 0,
		      'ypos' => 0		);
}

# close and save pdf
$pdf->close;
