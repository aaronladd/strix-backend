#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX;
use DBI;

main($ARGV[0]);

sub main {
	my $id=$_[0];
	my @email=dataBasePull(dataBaseConnection(), $id, 1);
	
	fileCreation($email[0]);
	
	defaultContact($id, $email[0]);
}

sub fileCreation{
	my $newAcctPath="/usr/local/nagios/etc/accounts/$_[0]";
	my @newDirectories=("contacts", "hosts");
	my ($x, $line, $newHostFile, $FILE)=0;

	my @contactFields=("contact_name", "alias", "use", "contactgroups", "email", "address1", "address2");
	my @hostFields=("use", "host_name", "alias", "display_name", "address", "contact_groups");
	my @serviceFields=("use", "host_name", "service_description", "check_command");
	my @contactGroupFields=("contactgroup_name", "alias", "members");

	if(-e "$newAcctPath") {
		die "Unable to create $newAcctPath";
	} else {
		mkdir "$newAcctPath";
	}
		
	while($x < 2) {
		if (-e "$newAcctPath/$newDirectories[$x]") {
			die "Unable to create $newAcctPath/$newDirectories[$x]\n"
		} else {
			mkdir "$newAcctPath/$newDirectories[$x]";
		}
		$x++;
	}

	if (open $FILE, '>', "$newAcctPath/contacts/contacts.cfg") {
		print $FILE "define contact {\n";

		foreach $line (@contactFields){
			print $FILE "$line\n";
		}

		print $FILE "}";
		close $FILE;
	} else {
		die "Unable to open $newAcctPath/contacts/contacts.cfg\n";
	}

	if(open $FILE, '>',"$newAcctPath/contacts/contacts_group.cfg") {
		print $FILE "define contactgroup {\n";

		foreach $line (@contactGroupFields){
			print $FILE "$line\n";
		}

		print $FILE "}";
		close $FILE;
	} else {
		die "Unable to open $newAcctPath/contacts/contacts_group.cfg\n";
	}
	$x=1;
	while ($x<5) {
		if($x<2) {
			$newHostFile="$newAcctPath/hosts/host$x.cfg";
		} else {
			$newHostFile="$newAcctPath/hosts/host$x.cfg_off";
		}
		if(open $FILE, '>', "$newHostFile") {
			print $FILE "define host {\n";

			foreach $line (@hostFields){
				print $FILE "$line\n";
			}

			print $FILE "}\n\n";

			print $FILE "define service {\n";

			foreach $line (@serviceFields){
				print $FILE "$line\n";
			}

			print $FILE "}";
			close $FILE;
		} else {
			die "Unable to open $newHostFile";
		}
		$x++;
	}
}

sub defaultContact {
	my @newAccount=dataBasePull(dataBaseConnection(), $_[0], 2, $_[1]);
	my $x=0;
	my $contactFile="/usr/local/nagios/etc/accounts/$_[0]/contacts/contacts.cfg";
	my $contactBackupFile="/usr/local/nagios/etc/accounts/$_[0]/contacts/contacts.bkp_cfg";
	my @contactFields=("contact_name", "alias", "use", "contactgroups", "email", "address1", "address2");
	
	rename $contactFile $contactBackupFile;

	open CONTACTFILE, ">$contactsGroupFile" or die $!;
	open CONTACTBACKUP, "<", $contactsGroupBackup or die $!;
	
	while(<CONTACTBACKUP>){
		chomp();

		if($_ eq $_contactFields[$x]){
			if ($newAccount[$x]){
				print CONTACTFILE "$contactFields[$x] $newAccount[$x]\n";
			} else {
				print CONTACTFILE ";$contactFields[$x] $newAccount[$x]\n";
			}
			$x++;
		} else {
			print CONTACTFILE "$_\n"
		}
	}
}

sub dataBaseConnection {
	my $host='db.apathabove.net';
	my $port='9800';
	my $dsn='dbi:mysql:nagidb';
	my $user='nagidb';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect("dbi:Proxy:hostname=$host;port=$port;dsn=$dsn",$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}

sub dataBasePull {
	my ($dbh, $id, $queryID, $account, $sth, $query) = $_[0], $_[1], $_[2], $_[3];
	
	if($queryID == 1) {
		$query="SELECT account FROM table WHERE id='$id'";
	} else {
		$query="SELECT username, name, package, email FROM table3 WHERE id='$id' and email='$account'";
	}
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr\n";
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	my @dataPull=$sth->fetchrow();
	$sth->finish();
	$sth->disconnect || die "Failed to disconnect\n";
	return (@dataPull);
}

#--accounts
#--|--email_address
#--|--|--contacts
#--|--|--|--contacts.cfg
#--|--|-----contacts_group.cfg
#--|-----hosts
#--|-----|--host1.cfg
#--|-----|--host2.cfg
#--|-----|--host3.cfg
#--|--------host4.cfg
#--|--email_address
#--|--|--contacts
#--|--|--|--contacts.cfg
#--|--|-----contacts_group.cfg
#--|-----hosts
#--|-----|--host1.cfg
#--|-----|--host2.cfg
#--|-----|--host3.cfg
#-----------host4.cfg
