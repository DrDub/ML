#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

my$files={};
my%allrefs = ();
my@rec=( [ [], "." ] );

do {
    my$p = shift @rec;
    my@path = @{$p->[0]};
    my$dir = $p->[1];
    #print">> $dir\n";
    opendir(DIR, $dir) || die "$dir: $!";
    my@all = readdir DIR;
    closedir DIR;
    my$e = "";
    foreach my$f(@all) {
        next if $f=~m/^\./;
        #print"\t$f\n";
        if ( -d "$dir/$f" ) {
            my@p2=@path;
            push@p2,$f;
            push@rec, [ \@p2, "$dir/$f" ];
        }elsif($f=~m/\.tex$/){
            if(! $e) {
                $e = $files;
                foreach my$p(@path) {
                    if(!defined($e->{$p})){
                        $e->{$p} = {};
                    }
                    $e = $e->{$p};
                }
            }
            my@refs = ();
            open(F, "$dir/$f") or die "$dir/$f: $!";
            my@text = <F>;
            close F;
            chomp@text;
            my$text = join(" ",@text);
            my@hrefs = split(m/\\href\{/, $text);
            shift@hrefs; # first is bogus
            my%seen=();
          foreach my$ref(@hrefs){
                $ref =~ s/\}.*//; # clean
                next if($ref=~m/^http/); # external
                $ref =~ s/\\\#.*//; # internal links, drop them for the time being
                # resolve
                my@parts = split("/", $ref);
                my@relative = @path;
                foreach my$seg(@parts){
                    next if $seg eq ".";
                    if($seg eq ".."){
                        pop@relative;
                    }else{
                        push@relative,$seg;
                    }
                }
                $ref = "./" . join("/", @relative) . ".tex";
                next if defined($seen{$ref});
                $seen{$ref}=1;
                push@refs, $ref;
            }
            $e->{$f} = [ [ @path ], "$dir/$f", \@refs ];
            $allrefs{"$dir/$f"} = \@refs;
        }
    }
} while @rec;

#print Dumper($files);
#print Dumper(\%allrefs);

print <<'HERE'
% Options for packages loaded elsewhere
\PassOptionsToPackage{unicode}{hyperref}
\PassOptionsToPackage{hyphens}{url}
%
\documentclass[
]{book}
\usepackage[unicode=true,pdfusetitle,
 bookmarks=true,bookmarksnumbered=false,bookmarksopen=false,
 breaklinks=false,pdfborder={0 0 1},backref=false,colorlinks=true]
 {hyperref}
\usepackage{lmodern}
\usepackage{amssymb,amsmath}
\usepackage{ifxetex,ifluatex}
\ifnum 0\ifxetex 1\fi\ifluatex 1\fi=0 % if pdftex
  \usepackage[T1]{fontenc}
  \usepackage[utf8]{inputenc}
  \usepackage{textcomp} % provide euro and other symbols
\else % if luatex or xetex
  \usepackage{unicode-math}
  \defaultfontfeatures{Scale=MatchLowercase}
  \defaultfontfeatures[\rmfamily]{Ligatures=TeX,Scale=1}
\fi
% Use upquote if available, for straight quotes in verbatim environments
\IfFileExists{upquote.sty}{\usepackage{upquote}}{}
\IfFileExists{microtype.sty}{% use microtype if available
  \usepackage[]{microtype}
  \UseMicrotypeSet[protrusion]{basicmath} % disable protrusion for tt fonts
}{}
\makeatletter
\@ifundefined{KOMAClassName}{% if non-KOMA class
  \IfFileExists{parskip.sty}{%
    \usepackage{parskip}
  }{% else
    \setlength{\parindent}{0pt}
    \setlength{\parskip}{6pt plus 2pt minus 1pt}}
}{% if KOMA class
  \KOMAoptions{parskip=half}}
\makeatother
\usepackage{xcolor}
\IfFileExists{xurl.sty}{\usepackage{xurl}}{} % add URL line breaks if available
\IfFileExists{bookmark.sty}{\usepackage{bookmark}}{\usepackage{hyperref}}
\urlstyle{same} % disable monospaced font for URLs
\usepackage{color}
\usepackage{fancyvrb}
\newcommand{\VerbBar}{|}
\newcommand{\VERB}{\Verb[commandchars=\\\{\}]}
\DefineVerbatimEnvironment{Highlighting}{Verbatim}{commandchars=\\\{\}}
% Add ',fontsize=\small' for more characters per line
\newenvironment{Shaded}{}{}
\newcommand{\AlertTok}[1]{\textcolor[rgb]{1.00,0.00,0.00}{\textbf{#1}}}
\newcommand{\AnnotationTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}
\newcommand{\AttributeTok}[1]{\textcolor[rgb]{0.49,0.56,0.16}{#1}}
\newcommand{\BaseNTok}[1]{\textcolor[rgb]{0.25,0.63,0.44}{#1}}
\newcommand{\BuiltInTok}[1]{#1}
\newcommand{\CharTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\CommentTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textit{#1}}}
\newcommand{\CommentVarTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}
\newcommand{\ConstantTok}[1]{\textcolor[rgb]{0.53,0.00,0.00}{#1}}
\newcommand{\ControlFlowTok}[1]{\textcolor[rgb]{0.00,0.44,0.13}{\textbf{#1}}}
\newcommand{\DataTypeTok}[1]{\textcolor[rgb]{0.56,0.13,0.00}{#1}}
\newcommand{\DecValTok}[1]{\textcolor[rgb]{0.25,0.63,0.44}{#1}}
\newcommand{\DocumentationTok}[1]{\textcolor[rgb]{0.73,0.13,0.13}{\textit{#1}}}
\newcommand{\ErrorTok}[1]{\textcolor[rgb]{1.00,0.00,0.00}{\textbf{#1}}}
\newcommand{\ExtensionTok}[1]{#1}
\newcommand{\FloatTok}[1]{\textcolor[rgb]{0.25,0.63,0.44}{#1}}
\newcommand{\FunctionTok}[1]{\textcolor[rgb]{0.02,0.16,0.49}{#1}}
\newcommand{\ImportTok}[1]{#1}
\newcommand{\InformationTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}
\newcommand{\KeywordTok}[1]{\textcolor[rgb]{0.00,0.44,0.13}{\textbf{#1}}}
\newcommand{\NormalTok}[1]{#1}
\newcommand{\OperatorTok}[1]{\textcolor[rgb]{0.40,0.40,0.40}{#1}}
\newcommand{\OtherTok}[1]{\textcolor[rgb]{0.00,0.44,0.13}{#1}}
\newcommand{\PreprocessorTok}[1]{\textcolor[rgb]{0.74,0.48,0.00}{#1}}
\newcommand{\RegionMarkerTok}[1]{#1}
\newcommand{\SpecialCharTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\SpecialStringTok}[1]{\textcolor[rgb]{0.73,0.40,0.53}{#1}}
\newcommand{\StringTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\VariableTok}[1]{\textcolor[rgb]{0.10,0.09,0.49}{#1}}
\newcommand{\VerbatimStringTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\WarningTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}
\usepackage{graphicx}
\newcommand\Warning{%
 \makebox[1.4em][c]{%
 \makebox[0pt][c]{\raisebox{.1em}{\small!}}%
 \makebox[0pt][c]{\color{red}\Large$\bigtriangleup$}}}%

\DeclareUnicodeCharacter{221E}{$\inf$}
\DeclareUnicodeCharacter{25CF}{$\bullet$}
\DeclareUnicodeCharacter{FE0F}{\Warning}
\DeclareUnicodeCharacter{26A0}{\Warning}
\DeclareUnicodeCharacter{1F600}{:-D}
\DeclareUnicodeCharacter{1F609}{:-)}
\DeclareUnicodeCharacter{2212}{---}
\usepackage{longtable,booktabs}
% Correct order of tables after \paragraph or \subparagraph
\usepackage{etoolbox}
\makeatletter
\patchcmd\longtable{\par}{\if@noskipsec\mbox{}\fi\par}{}{}
\makeatother
% Allow footnotes in longtable head/foot
\IfFileExists{footnotehyper.sty}{\usepackage{footnotehyper}}{\usepackage{footnote}}
\makesavenoteenv{longtable}
\setlength{\emergencystretch}{3em} % prevent overfull lines
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
\setcounter{secnumdepth}{-\maxdimen} % remove section numbering

\title{RubixML Documentation\thanks{This documentation licensed CC BY-NC 4.0}}
\author{Andrew DalPino}


\begin{document}
\maketitle
\clearpage

\tableofcontents{}
\clearpage


HERE
    ;

my%inversecounts = ();
foreach my$f(keys %allrefs) {
    if(! defined($inversecounts{$f})){
        $inversecounts{$f} = 0;
    }
    foreach my$o(@{$allrefs{$f}}){
        if(! defined($inversecounts{$o})){
            $inversecounts{$o} = 1;
        }else{
            $inversecounts{$o}++;
        }
    }
}

foreach my$k(keys %inversecounts){
    if($k =~ m/index/){
        $inversecounts{$k} = -999;
    }
}

@rec=($files);

while(@rec) {
    my$e = shift @rec;
    my@files = ();
    foreach my$k(keys %$e){
        if($k=~m/\.tex$/){
            push@files, $e->{$k};
        }else{
            push@rec, $e->{$k};
        }
    }
    @files = sort { $inversecounts{$a->[1]} <=> $inversecounts{$b->[1]} } @files;
    if(@files && scalar(@{$files[0]->[0]}) == 0){
        print '\chapter{Introduction}' ."\n";
    }elsif(@files && scalar(@{$files[0]->[0]}) == 1){
        my$name = $files[0]->[0]->[0];
        my$cap = substr($name, 0, 1);
        $cap=~tr/a-z/A-Z/;
        $name = $cap . substr($name, 1);
        print '\chapter{' . $name .'}' ."\n";
    }
    foreach my$f(@files){
        my@path = @{$f->[0]};
        my$path = join("/",@path);
        if($path){
            $path="$path/";
        }
        open(F,$f->[1]) or die ("Open: " . $f->[1] . ": $!");
        print "\n\n\n" . '%%%%% ' . $f->[1] . "\n\n";
        while(<F>){
            if(m/\\label\{/){
                # add path to labels
                my@parts = split(/\\label\{/, $_);
                my$line = shift@parts;
                foreach my$seg(@parts){
                    my($label,$rest) = $seg=~m/([^}]+)\}(.*)/;
                    $line .= '\label{' . $path .$label.'}'.$rest;
                }
                $_ = $line;
            }
            if(m/\\href\{/){
                my@parts = split(/\\href\{/, $_);
                my$line = shift@parts;
                foreach my$seg(@parts){
                    my($ref,$rest)= $seg=~m/([^}]+)\}(.*)/;
                    if($ref=~m/^http/){
                        # all good
                        $line .= '\href{'.$ref.'}'.$rest."\ ";
                    }else{
                        # resolve
                        $ref=~s/\\#.*//;
                        my@parts = split("/", $ref);
                        my@relative = @path;
                        foreach my$seg2(@parts){
                            next if $seg2 eq ".";
                            if($seg2 eq ".."){
                                pop@relative;
                            }else{
                                push@relative,$seg2;
                            }
                        }
                        $ref = join("/", @relative);
                        $line .= '\ref{'.$ref.'}'.$rest;
                    }
                }
                $_ = $line;
            }
            if(m/\\includegraphics\{http/){
                my@parts = split(/\\includegraphics\{/, $_);
                my$line = shift @parts;
                foreach my$seg(@parts) {
                    if($seg=~m/^http/){
                        my($url,$rest) = $seg=~m/([^}]+)\}(.*)/;
                        my$f = $url;
                        $f=~s/\?raw=true//g;
                        $f=~s/.*\///;
                        if( ! -f $f) {
                            print STDERR "Fetch $url...\n";
                            `wget $url -O $f`;
                        }
                        $line .= '\includegraphics[width=\textwidth]{'.$f.'}'.$rest;
                    }else{
                        $line .= '\includegraphics{'.$seg;
                    }
                }
                $_ = $line;
            }
            s/\&verbar\;/|| /g;
            print;
        }
        print '\clearpage' . "\n";
        close F;
    }
}



print <<'HERE'
\end{document}
HERE
    ;
