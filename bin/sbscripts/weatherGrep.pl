use XML::Simple;

$xml = new XML::Simple;
$dat = $xml->XMLin($ARGV[0]);
@curr = split /:/, $dat->{channel}->{item}[0]->{title};
@hilow = split / /, $dat->{channel}->{item}[1]->{description};
$curr[1] =~ s/^\s+|\s+$//g; # trim both ends
$curr[2] =~ s/^\s+|\s+$//g;

# print including weather condition
# print $curr[1] . ':' . $curr[2] . '/' . $hilow[1] . "/" . $hilow[4];
print $curr[2] . '/' . $hilow[1] . "/" . $hilow[4];
