#!/usr/bin/perl
#------------------------------------------------------------------------------
# Script to modify APK files to enable Sprint Mobile Installer in APKs
# !!! The original files must have already been copied to <name>.bak !!!
# This script MUST be executed in the root directory of PremiumCallerId
#------------------------------------------------------------------------------

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


# Modify default-mi-update-script.js
#-----------------------------------
open ( $inFile, "modules/sprint/assets/default-mi-update-script.js.bak" )
  or die "Could NOT open default-mi-update-script.js.bak!\nEnsure that the backup script has executed!\n";
open ( $outFile, ">", "modules/sprint/assets/default-mi-update-script.js")
  or die "Could NOT open default-mi-update-script.js for writing!\nPlease ensure that you have proper permissions setup\n";

$i = 1;
print "\n>>> MODIFICATIONS TO default-mi-update-script.js <<<\n" if ($debug);

while ( my $line = <$inFile> ) {
   if ( $line =~ /\/\/var MI_UPDATE_HTML = REAL_PATH \+ 'mi-update\.html';/ ) {
      print $outFile "  var MI_UPDATE_HTML = REAL_PATH + 'mi-update.html';\n";
      print "$i\t  var MI_UPDATE_HTML = REAL_PATH + 'mi-update.html';\n" if ($debug);

   } elsif ( $line =~ /var MI_UPDATE_HTML = TEST_PATH \+ 'mi-update\.html';/ ) {
         print $outFile "  //var MI_UPDATE_HTML = TEST_PATH + 'mi-update.html';\n";
         print "$i\t  //var MI_UPDATE_HTML = TEST_PATH + 'mi-update.html';\n" if ($debug);

   } elsif ( $line =~ /\/\/ceq\.load\(REAL_PATH \+ 'mi-core\.js'\);/ ) {
         print $outFile "ceq.log('About to load: ' + REAL_PATH + 'mi-core.js');\n";
         print $outFile "ceq.load(REAL_PATH + 'mi-core.js');\n";
         print "$i\tceq.log('About to load: ' + REAL_PATH + 'mi-core.js');\n";
         $i++;
         print "$i\tceq.load(REAL_PATH + 'mi-core.js');\n" if ($debug);

   } elsif ( $line =~ /ceq\.load\(TEST_PATH \+ 'mi-core\.js'\);/ ) {
         print $outFile "//ceq.load(TEST_PATH + 'mi-core.js');\n";
         print "$i\t//ceq.load(TEST_PATH + 'mi-core.js');\n" if ($debug);

   } elsif ( $line =~ /if \(ecid\.forceContentPack\(\)\)/ ) {
         print $outFile "//  if (ecid.forceContentPack())\n";
         print "$i\t//  if (ecid.forceContentPack())\n" if ($debug);

   } elsif ( $line =~ /MI_UPDATE_HTML = TEST_PATH \+ 'mi-update\.html'/ ) {
         print $outFile "//    MI_UPDATE_HTML = TEST_PATH + 'mi-update.html';\n";
         print "$i\t//    MI_UPDATE_HTML = TEST_PATH + 'mi-update.html';\n" if ($debug);

   } else {
      print $outFile $line;
      print "$i\t$line" if ($debug);
   }
   $i++;
}

close ( $inFile );
close ( $outFile );
