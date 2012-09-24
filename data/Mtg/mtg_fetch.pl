#!/usr/bin/perl -w

# Gatherer parser for creating GCCG-compatible MTG set files
# (c) 2012 anonycat, released under GPL2
# usage: ./mtg_fetch.pl SET[,SET2,SET3...] ARGS
# where SET has an entry in the mtg_sets.txt file, which must be in the same directory
# Supported ARGS:
# text - fetch card text and create XML file
# image - fetch card images and create folder for each set
# keep - do not remove fetched HTML files after it's finished
# cache - use saved HTML files intead of re-requesting (after a previous call in which you specified the "keep" option)

use Text::Unaccent;
use LWP::Simple;

die "No set" if !(scalar @ARGV);

for my $set (split /,/,uc $ARGV[0])
{
my ($setname,$seturl,$setsize);
open SETS, "<mtg_sets.txt";
while(<SETS>)
{
	next if(m[^#|^//|^$]);
	if(/$set (.+?)(?: (\d{0,3}))?$/)
	{
		$setname=$1;
		$setsize=$2;
		if($setname=~/(.*?)\|\|\|(.*)$/)
		{
			$setname=$1;
			$seturl=$2;
		}
		else
		{
			$seturl=$setname;
		}
		last;
	}
}
close SETS;

if(!defined $setname)
{
	print "Unknown set code: $set\n";
	next;
}

my %redir = ();
open REDIR, "<mtg_multipart.txt";
while(<REDIR>)
{
	next if(m[^#|^//|^$]);
	$redir{$1}=$2 if(/(.*):::(.*)/);
}
close REDIR;

my $images = 1+index(join(" ",@ARGV),"image");
my $xml = 1+index(join(" ",@ARGV),"text");
my $cache = 1+index(join(" ",@ARGV),"cache");
my $keep = 1+index(join(" ",@ARGV),"keep");

getstore("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=checklist&set=|[\"$seturl\"]","$set-check.html") unless $cache;

my ($check,$text);

open NAMES, "<$set-check.html";
local $/;
$check = <NAMES>;

mkdir $set if $images;

if ($xml)
{
	open WRITE, ">", lc("$set.xml");
	print WRITE qq(<?xml version='1.0' encoding='latin1'?>
<!DOCTYPE ccg-setinfo SYSTEM "../gccg-set.dtd">
<ccg-setinfo name="$setname" dir="$set" abbrev="$set" game="Magic the Gathering">
 <cards>\n);
	getstore("http://gatherer.wizards.com/Pages/Search/Default.aspx?output=spoiler&method=text&set=|[\"$seturl\"]","$set-text.html") unless $cache;
	open TEXT, "<$set-text.html";
	$text = <TEXT>;
}

my $count=0;
my $cardid=0;
my $copy=1;
my $cardname="";
my $extra="";
$extra=qq( back="500") if($set eq "P1P"||$set eq "P2P");
$extra=qq( back="700") if($set eq "ARS");

my ($color,$rarity,$testcard,$filename,$flipname,$attrs,$split,$flip);
my %attrs;


while($check =~ m[<tr class="cardItem"><td class="number">(\d*)</td>.+?multiverseid=(\d+)".+?>(.+?)</a>.+?<td class="color">(.*?)</td><td class="rarity">(\w+)</td>]gc)
{
	$cardid=$2;
	$testcard=$3;
	$split = 0;
	$flip = 0;
	if(exists $redir{$testcard})
	{
		if($redir{$testcard} eq "NEXTIMG")
		{
			if($images)
			{
				mkdir $set."_flip" if(!-d $set."_flip");
				getstore("http://gatherer.wizards.com/Handlers/Image.ashx?type=card&multiverseid=$cardid",$set."_flip/$filename");
			}
			next;
		}
		elsif($redir{$testcard} eq "NEXT")
		{next;}
		elsif($redir{$testcard} =~ /SPLIT:(.*)/)
		{
			$split=1;
			$testcard .= $1;
		}
		elsif($redir{$testcard} =~ /FLIP(?:=(\d+))?:(.*)/)
		{
			$flip=defined $1 ? $1 : 1;
			$flipname = $2;
		}
	}
	if($cardname eq $testcard)
	{
		next if $cardname =~ m[//] || ($cardid>29290 && $cardid<29294); #don't reserve slots for Planeshift alternate-art foils
		++$copy;
		$filename=ImageName($cardname)."$copy.jpg";
	}
	else
	{
		$copy=1;
		$cardname=$testcard;
		$filename=ImageName($cardname).".jpg";
	}
	
	++$count;
	$color=$4;
	$rarity=$5;
	$rarity = "S$rarity" if $flip && ($set eq "ISD" || $set eq "DKA");
	
	if($images)
	{
		getstore("http://gatherer.wizards.com/Handlers/Image.ashx?type=card&multiverseid=$cardid","$set/$filename");
	}
	if($xml)
	{
		
	if($split)
	{
		my @splits = split m[ // ],$cardname;
		%attrs=();
		$color="";
		foreach(@splits)
		{
			if($text =~ m[">\Q$cardname ($_)\E</a>(.+?)(?:<tr>\s+<td>\s+Name:|</table>)]s)
			{
				$attrs = $1;
				while($attrs =~ m[<tr[^>]*>\s*<td>\s*(.+?):\s*</td>\s*<td>\s*(.*?)\s*</td>\s*</tr>]gcs)
				{
					if(exists $attrs{lc $1} && length $attrs{lc($1)})
					{
						my $spacer = (lc($1) eq "rules text")?"\n":" ";
						$color .= " // ".CostColor(FilterCost($2)) if lc($1) eq "cost";
						
						$attrs{lc($1)} .= "$spacer//$spacer$2";
					}					
					else
					{
						$attrs{lc($1)}=$2;
						$color=CostColor(FilterCost($2)) if lc($1) eq "cost";
					}
					
				}
			}
		}
	}
	elsif($text =~ m[(?:">\Q$cardname\E</a>| \Q($cardname)\E</a>)(.+?)(?:<tr>\s+<td>\s+Name:|</table>)]s)
	{
		$filename="Planes/$filename" if($set eq "P1P"||$set eq "P2P");
		$filename="Schemes/$filename" if($set eq "ARS");
		$attrs = $1;
		%attrs=();
		while($attrs =~ m[<tr[^>]*>\s*<td>\s*(.+?):\s*</td>\s*<td>\s*(.*?)\s*</td>\s*</tr>]gcs)
			{$attrs{lc($1)}=$2;}
		
		$cardname =~ s/"/&quot;/g;
		$color = join(" ",sort(split(m[/],$color))) if length $color;
	}
	else
	{
		print "ERROR: Unable to find match for $cardname!\n";
		next;
	}
	
	print WRITE qq(  <card name="), unac_string("UTF-8",$cardname), qq(" graphics="$filename" text="), FilterText($attrs{'rules text'}), qq("$extra>\n);
	print WRITE qq(   <attr key="rarity" value="$rarity" />\n);
	if(length($attrs{'cost'}))
		{print WRITE qq(   <attr key="cost" value="), FilterCost($attrs{'cost'}), qq(" />\n);}
	if($attrs{'type'} =~ s/\s*—\s*(.*)//)
		{print WRITE qq(   <attr key="type" value="$attrs{'type'}" />\n   <attr key="subtype" value="$1" />\n);}
	else
		{print WRITE qq(   <attr key="type" value="$attrs{'type'}" />\n);}
	if(length($color))
		{print WRITE qq(   <attr key="color" value="$color" />\n);}
	elsif($attrs{'type'} =~ /Land/)
		{print WRITE qq(   <attr key="color" value="Land" />\n);}
	elsif($attrs{'type'} =~ /(Plane$|Phenomenon|Scheme|Artifact)/)
		{print WRITE qq(   <attr key="color" value="$1" />\n);}
	else
		{print WRITE qq(   <attr key="color" value="Colorless" />\n);}
	if(exists($attrs{'pow/tgh'}) && $attrs{'pow/tgh'} =~ m|\(?([^/]+)/([^\)]+)\)?|)
		{print WRITE qq(   <attr key="power" value="$1" />\n   <attr key="toughness" value="$2" />\n);}
	if(exists($attrs{'loyalty'}) && $attrs{'loyalty'} =~ /\(?(\d+)\)?/)
		{print WRITE qq(   <attr key="loyalty" value="$1" />\n);}
		
	if($flip)
	{	
		if($text =~ m[(?:">\Q$flipname\E</a>| \Q($flipname)\E</a>)(.+?)(?:<tr>\s+<td>\s+Name:|</table>)]s)
		{
			$attrs = $1;
			%attrs=();
			while($attrs =~ m[<tr[^>]*>\s*<td>\s*(.+?):\s*</td>\s*<td>\s*(.*?)\s*</td>\s*</tr>]gcs)
				{$attrs{lc($1)}=$2;}
			
			if($flip > 1)
				{print WRITE qq(   <attr key="flipid" value="$flip" />\n);}
			print WRITE qq(   <attr key="flipname" value="$flipname" />\n);
			print WRITE qq(   <attr key="fliptext" value="), FilterText($attrs{'rules text'}), qq(" />\n);
			if($attrs{'type'} =~ s/\s*—\s*(.*)//)
				{print WRITE qq(   <attr key="fliptype" value="$attrs{'type'}" />\n   <attr key="flipsubtype" value="$1" />\n);}
			else
				{print WRITE qq(   <attr key="fliptype" value="$attrs{'type'}" />\n);}
			if(length($attrs{'color'}))
				{print WRITE qq(   <attr key="flipcolor" value=").join(" ",sort(split(m[/],$attrs{'color'}))).qq(" />\n);}
			elsif($attrs{'type'} =~ /(Land|Artifact)/)
				{print WRITE qq(   <attr key="flipcolor" value="$1" />\n);}
			elsif($set ne "ISD" && $set ne "DKA")
				{print WRITE qq(   <attr key="flipcolor" value="$color" />\n);}
			if(exists($attrs{'pow/tgh'}) && $attrs{'pow/tgh'} =~ m|\(?([^/]+)/([^\)]+)\)?|)
				{print WRITE qq(   <attr key="flippower" value="$1" />\n   <attr key="fliptoughness" value="$2" />\n);}
			if(exists($attrs{'loyalty'}) && $attrs{'loyalty'} =~ /\(?(\d+)\)?/)
				{print WRITE qq(   <attr key="fliployalty" value="$1" />\n);}
		}
		else
			{print "ERROR: Unable to find expected flipside $flipname!\n";}
	}
	print WRITE qq(  </card>\n);
	}
}
	
if ($xml)
{
	print WRITE qq( </cards>\n</ccg-setinfo>);
	close WRITE;
}

if ($images)
{
	qx(./image_crop.sh $set);
}

print "Expected $setsize cards in set $set but got $count","\n" if $count!=$setsize && $count!=0;
qx(rm -f $set-check.html $set-text.html) unless $keep;
}

sub ImageName
{
	($_) = shift;
	$_ = unac_string("UTF-8",$_);
	s/\W//g;
	return $_;
}

sub FilterCost
{
	($_) = shift;
	s/\((.)\/(.)\)/{\U$1$2\E}/g;
	s/(?<!{)(\d+|[WUBRGXYZ])(?!})/{$1}/g;
	return $_;	
}

sub CostColor
{
	($_) = shift;
	my @colors = ();
	push @colors,"Black" if /{B|B}/;
	push @colors,"Blue" if /{U|U}/;
	push @colors,"Green" if /{G|G}/;
	push @colors,"Red" if /{R|R}/;
	push @colors,"White" if /{W|W}/;
	return join " ",@colors;	
}

sub FilterText
{
	($_) = shift;
	s/\s*—\s*/ - /g;
	s/{Q}/{UT}/g; #the untap symbol is {UT} here
	s/{S}i}?/{S}/g; #fix bug with snow mana representation
	s/{\((.)\/(.)\)(?:}|(?={))/{\U$1$2\E}/g; #hybrid mana symbols need to be made uppercase in GCCG
	s/ ?\(.+?\)(?:(?! \w) )?//g; #strip reminder text, without messing up spacing if it occurs mid-sentence
	s/<br \/>/\n/g;
	s/\n\s*\n/\n/g; #avoid excess newlines
	s/^\n+//s;
	s/\n+$//s;
	s/Kaboom /Kaboom! /; #fix bug with this card's name
	s/"/&quot;/g;
	$_ = unac_string("UTF-8",$_);
	s/^(.)$/{$1}/; #text on basic lands consists of a single character, and should be converted to a mana symbol
	return $_;
}
