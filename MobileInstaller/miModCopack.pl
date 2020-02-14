#!/usr/bin/perl

# Script to modify content pack files so that the Mobile Installer bootup script will execute
#   and point to the proper locations for testing.
# The original files must have already been copied to <name>.bak, otherwise the script will fail
# This script is expected to be executed in the root directory of Scootaloo.

# Initialize variables
#-----------------------
# Read in a Bash config file
%shellVar;
$debug = 1;

# Populate the shell variables
open($fh, glob( "~/bin/mobileInstaller.conf") ) or die "Clouldn't open file";

print "\nMobile Installer config:\n" . "-" x 50 ."\n" if ($debug);
while ( $line = <$fh> ) {
   print "   $line" if ($debug);
   if ( $line =~ /(\S+)=(.+)/ ) {
      $shellVar{$1} = $2;
   }
}
close($fh);
print "-" x 50 ."\n" if ($debug);


# Modify the initialize.js file
#-------------------------------
open ( $inFile, "on-board/initialize.js.TMPL.bak" )
  or die "Could NOT open initialize.js.TMPL.bak!\nEnsure that the backup script has executed!\n";
open ( $outFile, ">", "on-board/initialize.js.TMPL")
  or die "Could NOT open initialize.js.TMPL for writing!\nPlease ensure that you have proper permissions setup\n";

$i = 1;
print "\n>>> MODIFICATIONS TO initialize.js <<<\n" if ($debug);
while ( my $line = <$inFile> ) {
   if ( $line =~ /ceq.setProperty\('smf-callback-script-uri'/ ) {
      print $outFile $line;
      print $outFile "ceq.load('content://com.cequint.hs.scp/p/sprint/nameid-debug/mi-bootup.js');\n";
      print "$i\t$line" if ($debug);
      print "$i\tceq.load('content://com.cequint.hs.scp/p/sprint/nameid-debug/mi-bootup.js');\n" if ($debug);
   }else {
      print $outFile $line;
      print "$i\t$line" if ($debug);
   }
   $i++;
}

close ( $inFile );
close ( $outFile );


# Modify the menu.html.TMPL file
#-------------------------------
open ( $inFile, "on-board/views/en_US/menu.html.TMPL.bak" )
  or die "Could NOT open menu.html.TMPL.bak!\nEnsure that the backup script has executed!\n";
open ( $outFile, ">", "on-board/views/en_US/menu.html.TMPL")
  or die "Could NOT open menu.html.TMPL
   for writing!\nPlease ensure that you have proper permissions setup\n";

# Initialize the holding arrray
@outputArray;

while ( my $line = <$inFile> ) {
   push(@outputArray, $line);
   if ( $line =~ /<li onclick='ceq.loadUrl\("http:\/\/localhost:41642\/dev-test\/landing-pad.html"/ ) {

      $len = @outputArray;

      print "Length of array is: $len\n" if ($debug);
      printf ( "Prior Line was: %s\n", $outputArray[$len - 2] ) if ($debug);
      # check for commented line
      if ( $outputArray[$len - 2] =~ /<!--/ ) {
         print "The prior line was a comment\n" if ($debug);
         # remove the block comment
         $outputArray[$len - 2] = "\n";

         # itterate to end of comment
         my $flag = 1;
         while ($flag) {
            $line = <$inFile>;
            print $line if ($debug);
            if ( $line =~ /-->/ ) {
               $flag = 0;
            } else {
               push(@outputArray, $line);
            }
         }  # while Flag

         # Add in the new Item for Landing Hook
         push( @outputArray, "\n" );
         push( @outputArray, "      <li onclick='ceq.loadUrl(\"content://com.cequint.hs.scp/p/sprint/nameid-debug/spt-landing-hook.html\")'>\n" );
         push( @outputArray, "         <div class=\"main-list-title\">Sprint Tests</div>\n" );
         push( @outputArray, "       </li>\n" );
      }
   }
}

foreach my $x (@outputArray) {
   print $outFile $x;
}

close ( $inFile );
close ( $outFile );


# Modify the mi-bootup.js file
#-----------------------------
open ( $inFile, "on-board/nameid-debug/mi-bootup.js.bak" )
  or die "Could NOT open initialize.js.TMPL.bak!\nEnsure that the backup script has executed!\n";
open ( $outFile, ">", "on-board/nameid-debug/mi-bootup.js")
  or die "Could NOT open initialize.js.TMPL for writing!\nPlease ensure that you have proper permissions setup\n";

print "\n>>> MODIFICATIONS TO mi-bootup.js <<<\n" if ($debug);
$i = 1;
while ( my $line = <$inFile> ) {
   if ( $line =~ /var REQUIRED_JSON = / ) {
      printf ( $outFile "var REQUIRED_JSON = '%sapps.json';\n", $shellVar{'WEBFOLDER'} ) if ($debug);
      printf ( "$i\tvar REQUIRED_JSON = '%sapps.json';\n", $shellVar{'WEBFOLDER'} ) if ($debug);
   } elsif ( $line =~ /ceq\.setProperty\(PREF_MI_UPDATE_SCRIPT, MI_UPDATE_SCRIPT\);/ ) {
      print $outFile "// ceq.setProperty REMOVED by script\n" if ($debug);
      print "$i\t// ceq.setProperty REMOVED by script\n" if ($debug);
   } else {
      print $outFile $line;
      print "$i\t$line" if ($debug);
   }
   $i++;
}

close ( $inFile );
close ( $outFile );
