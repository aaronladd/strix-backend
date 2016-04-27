#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX;
use DBI;

main(@ARGV);

sub main {
	my $accountId=$_[0];
	my $email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $newAcctPath="/usr/local/nagios/etc/accounts/$email->[0][0]";
	
	fileCreation($newAcctPath);	
	defaultContact($newAcctPath,$accountId);
}

sub fileCreation{
	my $newAcctPath=$_[0];
	my $count=0;
	my ($line, $newHostFile);
	my @newDirectories=("contacts", "hosts");
	my @contactFields=(";contact_id", "contact_name", "alias", "use", "contactgroups", "email", "address1", "address2",  "host_notifications_enabled", "service_notifications_enabled");
	my @contactGroupFields=(";group_id", "contactgroup_name", "alias", "members");
	my @hostFields=("use", "host_name", "alias", "display_name", "address", "contact_groups");
	my @serviceFields=("use", "host_name", "service_description", "check_command");

	if(-e "$newAcctPath") {
		die "Unable to create $newAcctPath";
	} else {
		mkdir "$newAcctPath";
	}
		
	while($count < 2) {
		if (-e "$newAcctPath/$newDirectories[$count]") {
			die "Unable to create $newAcctPath/$newDirectories[$count]\n"
		} else {
			mkdir "$newAcctPath/$newDirectories[$count]";
		}
		$count++;
	}

	if(open CONTACTFILE, '>', "$newAcctPath/contacts/contacts.cfg") {
		print CONTACTFILE "define contact {\n";

		foreach $line (@contactFields){
			print CONTACTFILE "$line\n";
		}

		print CONTACTFILE "}";
		close CONTACTFILE;
	} else {
		die "Unable to open $newAcctPath/contacts/contacts.cfg\n";
	}

	if(open CONTACTGROUPFILE, '>',"$newAcctPath/contacts/contacts_group.cfg") {
		print CONTACTGROUPFILE "define contactgroup {\n";

		foreach $line (@contactGroupFields){
			print CONTACTGROUPFILE "$line\n";
		}

		print CONTACTGROUPFILE "}";
		close CONTACTGROUPFILE;
	} else {
		die "Unable to open $newAcctPath/contacts/contacts_group.cfg\n";
	}
	$count=1;
	while ($count<5) {
		if($count<2) {
			$newHostFile="$newAcctPath/hosts/host$count.cfg";
		} else {
			$newHostFile="$newAcctPath/hosts/host$count.cfg_off";
		}
		if(open HOSTFILE, '>', "$newHostFile") {
			print HOSTFILE "define host {\n";

			foreach $line (@hostFields){
				print HOSTFILE "$line\n";
			}

			print HOSTFILE "}\n\n";

			print HOSTFILE "define service {\n";

			foreach $line (@serviceFields){
				print HOSTFILE "$line\n";
			}

			print HOSTFILE "}";
			close HOSTFILE;
		} else {
			die "Unable to open $newHostFile";
		}
		$count++;
	}
}

sub defaultContact {
	my $dataPull=dataBasePull(dataBaseConnection(),$_[1],1);
	my $newAcctPath=$_[0];
	my $count=0;
	my $currentLine;
	my $contactFile="$newAcctPath/contacts/contacts.cfg";
	my $contactBackupFile="$newAcctPath/contacts/contacts.bkp_cfg";
	my @contactFields=(";contact_id 01", "contact_name", ";alias", "use", ";contactgroups", "email", ";address1", ";address2", "host_notifications_enabled 1", "service_notifications_enabled 1");
	
	$contactFields[1]="$contactFields[1] $dataPull->[0][1]";
	$contactFields[3]="$contactFields[3] $dataPull->[0][3]";
	$contactFields[5]="$contactFields[5] $dataPull->[0][7]";
	
	rename $contactFile, $contactBackupFile;
		
	open CONTACTFILE, ">$contactFile" or die $!;
	foreach my $line (@contactFields){
		print CONTACTFILE "$line\n";
	}
	close CONTACTFILE;
}

sub strixdbConnection {
	my $dsn='dbi:mysql:strixdb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}

sub dataBasePull {
	my $dbh=$_[0];
	my $accountId=$_[1];
	my $queryNum=$_[2];
	my ($sth, $dump, $query);
	
	if($queryNum == 0){
		$query="SELECT email FROM account_information WHERE account_id='$accountId'";
	} elsif ($queryNum == 1){
		$query="SELECT * FROM account_information WHERE account_id='$accountId'";
	}
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	
	#$sth->dump_results();  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return $dump;
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
