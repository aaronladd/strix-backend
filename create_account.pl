#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX;
use DBI;

main(@ARGV);

sub main {
	my $accountId=$_[0];
	my $dataPull=dataBasePull(dataBaseConnection(),$accountId);
	my $newAcctPath="/usr/local/nagios/etc/accounts/$dataPull->[0][7]";
	
	fileCreation($newAcctPath);	
	defaultContact($newAcctPath,$dataPull);
}

sub fileCreation{
	my $newAcctPath=$_[0];
	my @newDirectories=("contacts", "hosts");

	if(-e "$newAcctPath") {
		die "Directory $newAcctPath already exists\n";
	} else {
		mkdir "$newAcctPath";
	}
		
	foreach my $line (@newDirectories){
		if (-e "$newAcctPath/$line") {
			die "Directory $newAcctPath/$line  already exists.\n"
		} else {
			mkdir "$newAcctPath/$line";
		}
	}

	open CONTACTFILE, '>', "$newAcctPath/contacts/contacts.cfg" || die "Unable to open $newAcctPath/contacts/contacts.cfg\n";
	open CONTACTGROUPFILE, '>',"$newAcctPath/contacts/contacts_group.cfg" || die "Unable to open $newAcctPath/contacts/contacts_group.cfg\n";
	open HOSTFILE, '>', "$newAcctPath/hosts/host1.cfg" || die "Unable to open $newAcctPath/hosts/host1.cfg";
		
	close CONTACTFILE;
	close CONTACTGROUPFILE;
	close HOSTFILE;
}

sub defaultContact {
	my $newAcctPath=$_[0];
	my $dataPull=$_[1];
	my $contactFile="$newAcctPath/contacts/contacts.cfg";
	my $contactBackupFile="$newAcctPath/contacts/contacts.bkp_cfg";
	my @contactFields=(";contact_id 01", "contact_name", ";alias", "use", ";contactgroups", "email", ";address1", ";address2", "host_notifications_enabled 0", "service_notifications_enabled 0");
	
	$contactFields[1]="$contactFields[1] $dataPull->[0][1]";
	$contactFields[3]="$contactFields[3] $dataPull->[0][3]";
	$contactFields[5]="$contactFields[5] $dataPull->[0][7]";
	
	rename $contactFile, $contactBackupFile;
		
	open CONTACTFILE, ">$contactFile" or die $!;
	print CONTACTFILE "define contact{\n";
	foreach my $line (@contactFields){
		print CONTACTFILE "\t$line\n";
	}
	print CONTACTFILE "}\n";
	close CONTACTFILE;
}

sub dataBaseConnection {
	my $dsn='dbi:mysql:strixdb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}

sub dataBasePull {
	my $dbh=$_[0];
	my $accountId=$_[1];
	my ($sth, $dump, $query);
	
	$query="SELECT * FROM account_information WHERE account_id='$accountId'";
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr\n";
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";  
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
