use Image::Magick;

opendir(DIR, './');
my @files = grep { -f && /\.tif$/ } readdir(DIR);
closedir(DIR);

@files = sort @files;

# Load up thumbnails
# Unless the thumbnail file exists, and
# is newer than the file it's a thumbnail for, generate the
# thumbnail
foreach $file (@files) 
{
	($basename,$ext) = $file =~ m/(.*)\.([^.]+)$/;
	print "$file : <$basename><$ext>\n";

	if(!-e "./$basename.jpg" || !-e ("tn_$basename" . "_$ext.jpg"))
	{
		my $q = new Image::Magick;
		unless ($q) 
		{
			print ("Couldn't create a new Image::Magick object");
			return;
		}
		$q->Read("./$basename.$ext");
		my ($o_width, $o_height) = $q->Get('width', 'height');

		if(!-e "./$basename.jpg")
		{
			print "No ./$basename.jpg\n";
			my $t_width = $o_width/2;
			my $t_height = $o_height/2;

			$q->Resize( width => $t_width, height => $t_height);
			$q->Set(quality=>85);
			$q->Write("./$basename.jpg");
		}

		if(!-e ("tn_$basename" . "_jpg.jpg"))
		{
			print "No tn_$basename" . "_jpg.jpg\n";
			if($o_width>$o_height)
			{
				$t_width = 100;
				my $ratio = $o_width / $o_height;
				$t_height = $t_width / $ratio;
			}
			else
			{
				$t_height = 100;
				my $ratio = $o_width / $o_height;
				$t_width = $t_height * $ratio;
			}

			$q->Resize( width => $t_width, height => $t_height);
			$q->Write("tn_$basename" . "_jpg.jpg");
		}

		undef $q;
	}
}
