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
	my ($newAcctPath, $count, $line, $newHostFile)=$_[0], 0;
	my @newDirectories=("contacts", "hosts");
	my @contactFields=(";contact_id", "contact_name", "alias", "use", "contactgroups", "email", "address1", "address2");
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

	if (open CONTACTFILE, '>', "$newAcctPath/contacts/contacts.cfg") {
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
	my @newAccount=dataBasePull(dataBaseConnection(),$_[1],1);
	my ($newAcctPath, $count)=$_[0],0;
	my $contactFile="$newAcctPath/contacts/contacts.cfg";
	my $contactBackupFile="$newAcctPath/contacts/contacts.bkp_cfg";
	my @contactFields=(";contact_id", "contact_name", "alias", "use", "contactgroups", "email", "address1", "address2");
	my $dataPull=dataBasePull(dataBaseConnection(),$accountId,1);
	
	rename $contactFile $contactBackupFile;
	$dataPull->[0][1]=substr $dataPull->[0][1], -2, 2;
	
	open CONTACTFILE, ">$contactsGroupFile" or die $!;
	open CONTACTBACKUP, "<", $contactsGroupBackup or die $!;
	
	while(<CONTACTBACKUP>){
		chomp();
		$currentLine=$_;
		if($currentLine eq $contactFields[$count]){
			print CONTACTFILE "$contactFields[$count] $dataPull->[0][$count]\n"
			$count++;
		} else if($currentLine) {
			print CONTACTFILE "$currentLine\n"
		}
	}
}

sub dataBaseConnection {
	my ($dbh, $accountId, $queryNum, $sth, $dump)=$_[0], $_[1], $_[2];
	my @queryList;
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM account_information WHERE account_id='$accountId'";
	
	$sth=$dbh->prepare($queryList[$queryNum]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	
	#$sth->dump_results();  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return $dump;
}

sub dataBasePull {
	my $dsn='dbi:mysql:nagidb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
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
