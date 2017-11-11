#!/usr/bin/perl -w
use Tk;
use Tk::Dialog;
use Tk::Font;
use Tk::NoteBook;
use Tk::Menubutton;
use Tk::Scrollbar;
use Tk::TextUndo;
use Tk::After;
use IO::Socket::INET;
require Tk::ROText;
my $myIP='user';
my $peerIP='peer';
my $filePath;
my @allIP;
my @colorlist;
my $n=-1;
my $fileName;
my $confirm;
my $myName;
my $y=-1;
my $collaborate=0;
my @finalist;
my $text_start;
my $font;
my $z=-1;
my $i=-1;
my $list;
my $log;
my $txt;
my $color='black';
my $color1='black';
my $wrap='word';
my $MySocket1=new IO::Socket::INET->new(LocalPort=>2000,Proto=>'udp',Blocking => 0);
my $main = MainWindow->new();
   $main->title("editor");
   $main->geometry('500x500');
my $mainFrame = $main->Frame();
my $textFrame = $mainFrame->NoteBook();
my $status = $mainFrame->Frame(-height=>2, -relief=>'raised');
my $chatframe = $mainFrame->Frame(-height=>2, -relief=>'raised');
my $lineno = $status->Label(-text=>"            ");
my $textAreaAndYScrollFrame = $textFrame->Frame();
my $textAreaFrame = $textAreaAndYScrollFrame->Frame();
my $yscrollFrame = $textAreaAndYScrollFrame->Frame();
my $text = $textFrame->TextUndo(-background=>'white',-foreground=>$color,-wrap=>$wrap);
   $text->bind('<Any-KeyPress>'=>\&keyhandler);
   $font = $text->Font();
my $menubarFrame = $mainFrame->Frame(-relief=>'raised', -borderwidth=>2);
my $fileDrop = $menubarFrame->Menubutton(-text=>'File', -underline=>0);
my $fileMenu = $fileDrop->Menu();
   $fileDrop->configure(-menu=>$fileMenu);
   $fileMenu->command(-label=>'New', -command=>\&newFile, -underline=>0);
   $fileMenu->command(-label=>'Open', -command=>\&openFile, -underline=>0);
   $fileMenu->separator();
my $col=$fileMenu->command(-label=>'Collaborate',-command=>\&collaborate, -underline=>2);
   $fileMenu->separator();
   $fileMenu->command(-label=>'Save', -command=>\&saveFile, -underline=>0);
   $fileMenu->command(-label=>'Save As', -command=>\&saveAs, -underline=>5);
   $fileMenu->separator();
   $fileMenu->command(-label=>'Include File', -command=>\&includeFile, -underline=>0);
   $fileMenu->command(-label=>'Clear File', -command=>\&clearFile, -underline=>2);
   $fileMenu->separator();
   $fileMenu->command(-label=>'Close', -command=>\&closeFile, -underline=>0);
   $fileMenu->separator();
   $fileMenu->command(-label=>'Exit', -command=>\&exitEditor, -underline=>1);		
my $editDrop = $menubarFrame->Menubutton(-text=>'Edit', -underline=>0);
my $editMenu = $editDrop->Menu();
   $editDrop->configure(-menu=>$editMenu);
my $ud=$editMenu->command(-label=>'Undo', -command=>\&undoMenu, -underline=>0);
my $rd=$editMenu->command(-label=>'Redo', -command=>\&redoMenu, -underline=>0);
   $editMenu->separator();
   $editMenu->command(-label=>'Copy', -command=>\&copyMenu, -underline=>0);
   $editMenu->command(-label=>'Cut', -command=>\&cutMenu, -underline=>1);
   $editMenu->command(-label=>'Paste', -command=>\&pasteMenu, -underline=>0);
   $editMenu->separator();
   $editMenu->command(-label=>'Select All', -command=>\&selectAllMenu, -underline=>0);
   $editMenu->command(-label=>'Unselect All', -command=>\&unselectAllMenu, -underline=>1);
my $viewDrop = $menubarFrame->Menubutton(-text=>'View', -underline=>0);
my $viewMenu = $viewDrop->Menu();
   $viewDrop->configure(-menu=>$viewMenu);
   $viewMenu->command(-label=>'Goto Line Number', -command=>\&gotoLineMenu, -underline=>0);
   $viewMenu->command(-label=>'What Line Number', -command=>\&whatLineMenu, -underline=>1);
   $viewMenu->separator;
my $viewFont = $viewMenu->cascade(-label=>'Font');
my $fstyle;
   $viewFont->radiobutton(-invoke=>1, -label=>'Courier', -value=>'courier', -variable=>\$fstyle, -command=>\&fontStyle);
   $viewFont->radiobutton(-label=>'Helvetica', -value=>'helvetica', -variable=>\$fstyle, -command=>\&fontStyle);
   $viewFont->radiobutton(-label=>'Times', -value=>'times', -variable=>\$fstyle, -command=>\&fontStyle);
my $fsize;
   $viewFont->separator;
   $viewFont->radiobutton(-label=>'8', -value=>8, -variable=>\$fsize, -command=>\&fontSize);
   $viewFont->radiobutton(-invoke=>1, -label=>'12', -value=>12, -variable=>\$fsize, -command=>\&fontSize);
   $viewFont->radiobutton(-label=>'16', -value=>16, -variable=>\$fsize, -command=>\&fontSize);
   $viewFont->radiobutton(-label=>'20', -value=>20, -variable=>\$fsize, -command=>\&fontSize);
   $viewFont->radiobutton(-label=>'24', -value=>24, -variable=>\$fsize, -command=>\&fontSize);
my $searchDrop = $menubarFrame->Menubutton(-text=>'Search', -underline=>0);
my $searchMenu = $searchDrop->Menu();
   $searchDrop->configure(-menu=>$searchMenu);
   $searchMenu->command(-label=>'Find', -command=>\&searchFind, -underline=>0);
   $searchMenu->command(-label=>'Find Next', -command=>\&searchNext, -underline=>5);
   $searchMenu->command(-label=>'Find Previous', -command=>\&searchPrev, -underline=>5);
   $searchMenu->command(-label=>'Find and Replace', -command=>\&searchReplace, -underline=>9);
my $helpDrop = $menubarFrame->Menubutton(-text=>'Help', -underline=>0);
my $helpMenu = $helpDrop->Menu();
   $helpDrop->configure(-menu=>$helpMenu);
   $helpMenu->command(-label=>'About', -command=>\&About, -underline=>0);
   $mainFrame->pack(-side=>'top', -fill=>'both', -expand=>1);
   $menubarFrame->pack(-side=>'top', -fill=>'x');
   $fileDrop->pack(-side=>'left');
   $editDrop->pack(-side=>'left');
   $viewDrop->pack(-side=>'left');
   $searchDrop->pack(-side=>'left');
   $helpDrop->pack(-side=>'right');
   $textFrame->pack(-side=>'top', -fill=>'both', -expand=>1);
my $yscroll = $yscrollFrame->Scrollbar(-command=>['yview', $text]);
my $xscrollFrame = $textFrame->Frame();
my $xscroll = $xscrollFrame->Scrollbar(-orient=>'horizontal', -command=>['xview', $text]);
   $text->configure(-yscrollcommand=>['set', $yscroll], -xscrollcommand=>['set', $xscroll]);
   $textAreaAndYScrollFrame->pack(-side=>'top', -fill=>'both', -expand=>1);
   $textAreaFrame->pack(-side=>'left', -fill=>'both', -expand=>1);
   $text->place(-in=>$textAreaFrame, -x=>1, -y=>1, -relwidth=>'1.0', -relheight=>'1.0');
   $yscrollFrame->pack(-side=>'right', -fill=>'y');
   $yscroll->pack(-side=>'right', -fill=>'y');
   $xscrollFrame->pack(-side=>'top', -fill=>'x');
   $xscroll->pack(-side=>'top', -anchor=>'s', -fill=>'x');
$status->pack(-side=>'top', -anchor=>'s', -fill=>'x');
$lineno->pack(-side=>'left', -anchor=>'w');

my $line = $lineno->repeat(10,
sub
{
 my $line=$text->index('insert');
 my $l=int($line);
 my $col=$line-int($line);
 my $col1 = sprintf("%.2f", $col);
 $col1 =~s/.*\.//;
 $col1=~s/0//;
 $lineno->configure(-text=>"Line Number:$l  Column Number:$col1");
});
my $after = $text->repeat(10,
sub 
{ 
 my $A;
 if($MySocket1->recv($A,128))
 {
  if($A =~ m/^!!&&!!/)
  {
   $A =~ s/!!&&!!//;
   @colorlist=split /,/,$A;
  }
  elsif($A =~ m/^!&&&&&!/)
  {
   $y++;
   $A =~ s/!&&&&&!//;
   my @temp=split /,/, $A;
   my $confrm=pop(@temp);
   if($confrm eq 'y')
   {
    $z++;
    $color1=pop(@temp);
    $peerIP=pop(@temp);
    $out[$z]=new IO::Socket::INET->new(PeerPort=>2000,Proto=>'udp',PeerAddr=>$peerIP);
    $finalist[$z]=$peerIP;
    $allIP[$z]=$peerIP;
    $colorlist[$z]=$color1;
    $list->tagConfigure("color$z", -foreground => $colorlist[$z]);
    $list->insert("end",$allIP[$z]."\n","color$z");
   }
   if($y==$i)
   {
     $i=$z;
     my $b;
     my $l=$text->index('1.0');
     my $l1=$text->index('end');
        $msg=$text->get($l,$l1);
        $color = $mainFrame->chooseColor(-title => 'color', -initialcolor => $color);
        $log->configure(-foreground=>$color);
        my $main = MainWindow -> new();
        $main->Label(-text=>'Enter username : ')->pack(-pady=>4);
        my $name = $main -> Entry(-background=>'white');
        $name -> pack;
        $main->Button(-text => 'Done',-command => sub{$myName=$name -> get();$main -> withdraw;})->pack(-pady=>4);
        $msg=$l."##!".$msg."##!".$myIP;
     my $colorlst;
     my $iplist;
     for($a=0;$a<=$i;$a++)
     {
      $iplist='!&&!';
      $colorlst='!!&&!!';
      for($b=0;$b<=$i;$b++)
      {
     my @fields = split /##!/, $A;
       $temp1=$finalist[$b];
       $temp2=$out[$a]->peerhost;
       if($temp1 ne $temp2)
       {
        $iplist.=$finalist[$b].',';
        $colorlst.=$colorlist[$b].',';
        
       }
      }
      $iplist.=$myIP.",".$temp2.",".$fstyle.",".$fsize;
      $colorlst.=$color;
      $out[$a]->send($colorlst);
      $out[$a]->send($iplist);
     }
     for($a=0;$a<=$i;$a++)
     {
      $out[$a]->send($msg);
     }
     $collaborate=1;
     $col->configure(-state=>'disabled');
     $viewFont->configure(-state=>'disabled');
     $ud->configure(-state=>'disabled');
     $rd->configure(-state=>'disabled');
    } 
   }
   elsif($A =~ m/^!&&&&!/)
   {
    $A =~ s/!&&&&!//;
    my @iplst=split /,/, $A;
    $peerIP=pop(@iplst);
    $myIP=pop(@iplst);
    my $main = MainWindow -> new();
    $temp=new IO::Socket::INET->new(PeerPort=>2000,Proto=>'udp',PeerAddr=>$peerIP);
    $main->Label(-text=>"IP $peerIP is requesting to collaborate.\nDo you wish to continue ?")->pack(-pady=>4);
    $main->Button(-text => 'Yes',-command => 
    sub
    {
     &clearFile();
     $main -> withdraw;
     $list=$mainFrame->Scrolled('ROText',-scrollbars=>'ose',height=>10,-width=>20,-background => 'white')->pack(-  side=>'right',-fill=>'x',-pady=>4);
    $list->tagConfigure('black',-foreground=>'black');
    $list->insert("end",'Shared with -->'."\n\n",'black');
    $log = $mainFrame->Scrolled('ROText',-scrollbars=>'ose',-height=>8,-background => 'white')->pack(-side=>'top',-     fill=>'x',-pady=>4);
    $log->tagConfigure('black',-foreground=>'black');
    $log->insert("end",'Chat facility -->'."\n\n",'black');
    $txt = $mainFrame->Entry(-background=>'white')->pack(-side=>'top',-fill=> 'x');
     $txt->bind('<Return>' => 
     sub
     {
      my $chat = $txt->get;
      $txt->delete(qw/0 end/);
      $log->insert("end","$myName: $chat\n");
      $log->see("end");
      $chat1='!&&&!';
      my $j;
      if($collaborate==1)
      {
       $chat1.=$chat.",".$myName.",".$myIP;
       for($j=0;$j<=$i;$j++)
       {
        $out[$j]->send($chat1);
       }
      }
     });
     $color = $mainFrame->chooseColor(-title => 'color', -initialcolor => $color);
     $log->configure(-foreground=>$color);
     $msg='!&&&&&!'.$myIP.','.$color.',y';
     $temp->send($msg);
     $temp->close();  
    })->pack(-side=>'left');
    $main->Button(-text => 'No',-command => 
    sub
    {
     $msg='!&&&&&!'.$myIP.',n';
     $temp->send($msg);
     $temp->close();  
     $main -> withdraw;
    })->pack(-side=>'right');
   }
   elsif($A =~ m/^!&&!/)
    {
     $A =~ s/!&&!//;
     @allIP=split /,/, $A;
     $fsize=pop(@allIP);
     $fstyle=pop(@allIP);
     $myIP=pop(@allIP);
     $font->configure(-size=>$fsize, -family=>$fstyle);
     $textFrame->configure(-font=>$font);
     $i=-1;
     for(my $z=0;$allIP[$z];$z++)
     {
      $list->tagConfigure("color$z", -foreground => $colorlist[$z]);
      $list->insert("end",$allIP[$z]."\n","color$z");
     }
     foreach $ipl (@allIP)
     {
      $i++;
      $out[$i]=new IO::Socket::INET->new(PeerPort=>2000,Proto=>'udp',PeerAddr=>$ipl);
     }
     my $main = MainWindow -> new();
        $main->Label(-text=>'Enter username : ')->pack(-pady=>4);
     my $name = $main -> Entry(-background=>'white');
     $name -> pack;
     $main->Button(-text => 'Done',-command => sub{$myName=$name -> get();$main -> withdraw;})->pack(-pady=>4);
     $collaborate=1;
     $col->configure(-state=>'disabled');
     $viewFont->configure(-state=>'disabled');
     $ud->configure(-state=>'disabled');
     $rd->configure(-state=>'disabled');
    }
     elsif($A =~ m/^!&&&!/)
     {
         $A =~ s/!&&&!//;
      my @temp=split /,/, $A;
         $peerIP=pop(@temp);
         $n=0;
         while($allIP[$n] ne $peerIP)
         {
          $n++;
          }
      my $peerName=pop(@temp);
         $log->tagConfigure("color$n", -foreground => $colorlist[$n]);
         $log->insert("end","$peerName: $temp[0]\n","color$n");
         $log->see("end");
     }
     else 
     {
     my @fields = split /##!/, $A;
        $peerIP=pop(@fields);
     $n=0;
     while($allIP[$n] ne $peerIP)
     {
      $n++;
     }
     my $line=$fields[0];
     my $text_typing = $text->index('insert');
     my $t = $text->get($line);
     $text->SetCursor($line);
     my $line1=$text_typing;
     if($t eq '')
      {
       while(int($line1) ne int($line))
       {
        $text->openLine;
        $line1++;
       }
      }
      my $text_start = $text->index('insert');
      if($fields[1]=~m/%%%.*%%%/)
      {
       my @del = split /%%%/, $fields[1];
       $text->delete($del[1]);
      }
      elsif($fields[1]=~m/!!!.*!!!/)
      {
       my @del = split /!!!/, $fields[1];
       $text->insert($del[1],"\n");
       $text_typing++;
      }
      else
      {
       $text->tagConfigure("color$n", -foreground => $colorlist[$n]);
       $text->insert("$line",$fields[1],"color$n");
      }
      $text->see($text_typing);
      $text->SetCursor($text_typing);
      $text->update();
     }
 }
} );

MainLoop();

sub collaborate
{
 my $main = MainWindow -> new();
    $main->Label(-text=>'Enter your IP :')->pack(-pady=>4);
 my $ipw = $main -> Entry(-background=>'white');
    $ipw -> pack();
    $main->Label(-text=>'IP list to collaborate :')->pack(-pady=>4);
 my $ip = $main -> Entry(-background=>'white');
    $ip -> pack();
    $main->Button(-text => 'Collaborate',-command => sub{collab($ip,$ipw),$main -> withdraw})->pack(-pady=>4);
    $list=$mainFrame->Scrolled('ROText',-scrollbars=>'ose',height=>10,-width=>20,-background => 'white')->pack(-  side=>'right',-fill=>'x',-pady=>4);
    $list->tagConfigure('black',-foreground=>'black');
    $list->insert("end",'Shared with -->'."\n\n",'black');
    $log = $mainFrame->Scrolled('ROText',-scrollbars=>'ose',-height=>8,-background => 'white')->pack(-side=>'top',-     fill=>'x',-pady=>4);
    $log->tagConfigure('black',-foreground=>'black');
    $log->insert("end",'Chat facility -->'."\n\n",'black');
    $txt = $mainFrame->Entry(-background=>'white')->pack(-side=>'top',-fill=> 'x');
    $txt->bind('<Return>' => 
sub
{
 my $chat = $txt->get;
    $txt->delete(qw/0 end/);
    $log->insert("end","$myName: $chat\n");
    $log->see("end");
    $chat1='!&&&!';
    my $j;
    if($collaborate==1)
    {
    $chat1.=$chat.",".$myName.",".$myIP;
    for($j=0;$j<=$i;$j++)
    {
     $out[$j]->send($chat1);
    }
    }
 
});
}
sub collab
{
 my ($widget,$widget1) = @_;
 my $ip = $widget -> get();
    $myIP= $widget1-> get();
    $i=-1;
 my @iplst=split /,/, $ip;
    foreach $ipl (@iplst)
    {
     $i++;
     $out[$i]=new IO::Socket::INET->new(PeerPort=>2000,Proto=>'udp',PeerAddr=>$ipl);
    }
 my $msg;
 for($a=0;$a<=$i;$a++)
    {
     $msg='!&&&&!';
     $msg.=$iplst[$a].','.$myIP;
     $out[$a]->send($msg);
     $out[$a]->close();
    }
}

sub newFile
{   
 &closeFile();
}

sub keyhandler
{
 if($collaborate==1)
 {
 my ($c) = @_;
 my $e = $c->XEvent;
 my ($x,$y,$W,$K,$A) = ($e->x, $e->y, $e->K, $e->W, $e->A);
 my $B;
 my $text_b=$text_start;
 $text_start = $text->index('insert');
  if ($W eq "BackSpace")
  {
   $A="%%%$text_start%%%"; 
  }
 if ($W eq "Return")
  {
   $A="!!!$text_b!!!";
  }
 $B=$text_start."##!".$A."##!".$myIP;
 my $j;
 for($j=0;$j<=$i;$j++)
 {
  $out[$j]->send($B);
 }
 }
}

sub saveFile
{
 $n=-1;
 foreach $ipl(@allIP)
 {
  $n++;
  $text->tagDelete("color$n");
 }
 $text->Save();
 my $saveName = $text->FileName();
 if($saveName eq '')
 {		
  return 'CanceledSave';
 }
 else
 {			
  $filePath = &regexPath($saveName);
  $fileName = &regexFile($saveName);
 }
}

sub saveAs
{
 $n=-1;
 foreach $ipl(@allIP)
 {
  $n++;
  $text->tagDelete("color$n");
 }
 $text->FileSaveAsPopup();
 my $saveAsName = $text->FileName();
 if($saveAsName eq "")
 {	
  return 'CanceledSave';
 }
 else
 {
  $filePath = &regexPath($saveAsName);
  $fileName = &regexFile($saveAsName);
 }
}

sub openFile
{
 $text->FileLoadPopup();
 my $openedFile = $text->FileName();
 $filePath = &regexPath($openedFile);
 $fileName = &regexFile($openedFile);
}

sub userWantsToSaveBuffer
{
 my $dialog = $main->Dialog(-title=>"Save File ?",
                            -text=>"Do you want to save file? ",
		            -bitmap=>'question',
		            -default_button=>'Yes',
		            -buttons=>[qw/Yes No Cancel/]);
 return $dialog->Show();
}

sub closeFile
{
 my $saveBuffer = &userWantsToSaveBuffer();
 if($saveBuffer eq 'Yes')
 {
  if(&saveFile() eq 'CanceledSave')
  {
   return ;
  }
 }
 elsif($saveBuffer eq 'Cancel')
 {
  return ;
 }
 &clearFile();
}

sub clearFile
{
 $text->ConfirmEmptyDocument();
}
sub exitEditor
{
 &closeFile();
 exit(0);
}

sub includeFile
{
 $text->IncludeFilePopup();
}

sub regexPath
{				
 my ($path2file) = @_;
 if ($path2file =~ /(.*\/)/ig)
 {		
  return $1;
 }
 elsif($path2file =~ /(.*\\)/ig)
 {
  return $1;
 }
}

sub regexFile
{			
 my ($fileFromPath) = @_;
 if($fileFromPath =~ /.*\/(.*)/ig)
 {	
  return $1;
 }
 elsif($fileFromPath =~ /.*\\(.*)/ig)
 {	
  return $1;
 }
}

sub undoMenu
{
 $text->undo();
}

sub redoMenu
{
 $text->redo();
}

sub copyMenu
{
 $text->clipboardColumnCopy();
}

sub cutMenu
{
 $text->clipboardCut();
}

sub pasteMenu
{
 $text->clipboardPaste();
}

sub selectAllMenu
{
 $text->selectAll();
}

sub unselectAllMenu
{
 $text->unselectAll();
}
for($a=0;$a<=$i;$a++)
    {
     $out[$a]->send($msg);
    }
sub gotoLineMenu
{
 $text->GotoLineNumberPopup;
}

sub whatLineMenu
{
 $text->WhatLineNumberPopup;
}

sub searchFind
{
 $text->FindPopUp();
}

sub searchNext
{
 $text->FindSelectionNext();
}

sub searchPrev
{
 $text->FindSelectionPrevious();
}

sub searchReplace
{
 $text->findandreplacepopup();
}


sub fontStyle
{
 my $f = $textFrame->cget(-font);
 my $size = $textFrame->fontActual($f, -size);
    $font->configure(-size=>$size, -family=>$fstyle);
    $textFrame->configure(-font=>$font);
} 

sub fontSize
{
 my $f = $text->cget(-font);
 my $family = $text->fontActual($f, -family);
    $font->configure(-size=>$fsize, -family=>$family);
    $text->configure(-font=>$font);
}

sub About
{
 my $about = $main->Toplevel(-relief=>'raised', -borderwidth=>10);
    $about->title("About Me");
    $about->geometry('+300+300');
 my $label = $about->Label(-text=>'
    Real-Time Collaborative Text Editor
    Developed by :
    Cijo George
    R.Srijith
    George Mathew
    Jibil Louis   ');
 $label->pack();
}

