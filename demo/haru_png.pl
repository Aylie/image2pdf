use strict;
use warnings;
use PDF::Haru;

sub Rotate{
	my ($self, $degree) = @_;
	my $docWidth = $self->GetWidth;
	my $docHeight = $self->GetHeight;
	$degree /= 90;
	
	if (1 == $degree % 2) {
		$self->SetWidth($docHeight);
		$self->SetHeight($docWidth);
	}	
}

sub GetScale{
	my ($docWidth, $docHeight, $imgWidth, $imgHeight) = @_;
	my $scale = 1;
	my $xscale = $docWidth / $imgWidth;
	my $yscale = $docHeight / $imgHeight;

	# image is smaller than page
	if (($xscale > 1) and ($yscale > 1)) {
		return $scale;
	}

	$scale = ($xscale < $yscale)? $xscale : $yscale;
	return $scale;
}

sub GetPos{
	my ($docWidth, $docHeight, $imgWidth, $imgHeight) = @_;
	
	my $xpos = ($docWidth - $imgWidth) / 2;
	my $ypos = ($docHeight - $imgHeight) / 2;
	
	return ($xpos, $ypos);
}

# create pdf file
my $pdf = PDF::Haru::New();

# open directory
my $path = "./image/test_png/";
opendir(DIR, $path) or die "Error : open $path fail\n";

# read directory
while (my $image = readdir DIR) {
	next if ($image eq "." or $image eq "..");

	# load image
	my $png = $pdf->LoadPngImageFromFile2($path.$image);
#	my ($width, $height) = $png->GetSize;
	my $width = $png->GetWidth;
	my $height = $png->GetHeight;
	
	# add page
	my $page = $pdf->AddPage;

	# set page size and orientation
	$page->SetSize(HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT);
	if ($width > $height) {
#		$page->Rotate(90);
		Rotate($page, 90);
	}
	my $docWidth = $page->GetWidth;
	my $docHeight = $page->GetHeight;
#	print "size = $docWidth x $docHeight\n";
	
	# caculate scaling
	my $scale = GetScale($docWidth, $docHeight, $width, $height);
#	print "scale = $scale\n";	

	# calculate scaling size of image
	$width *= $scale;
	$height *= $scale;

	# calculate pos
	my ($xpos, $ypos) = GetPos($docWidth, $docHeight, $width, $height);	
#	print "pos = $xpos $ypos\n";	

	# draw image to pdf
	$page->DrawImage($png, $xpos, $ypos, $width, $height);
}

# save pdf file
$pdf->SaveToFile("haru_png.pdf");

# cleaup
$pdf->Free();


