use strict;
use warnings;
use PDF::Haru;

# create pdf file
my $pdf = PDF::Haru::New();

# open directory
my $path = "./image/jpg432/";
opendir(DIR, $path) or die "Error : open $path fail\n";

# read directory
while (my $image = readdir DIR) {
	next if ($image eq "." or $image eq "..");

	# load image
	my $png = $pdf->LoadJpegImageFromFile($path.$image);

	# add page
	my $page = $pdf->AddPage();

	# set page size and orientation
	$page->SetSize(HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT);
	my $a4Width = $page->GetWidth();
	my $a4Height = $page->GetHeight();
#	print "size = $a4Width x $a4Height\n";

	# draw image to pdf
	$page->DrawImage($png, 0, 0, $a4Width, $a4Height);
}

# save pdf file
$pdf->SaveToFile("haru_jpg.pdf");

# cleaup
$pdf->Free();


