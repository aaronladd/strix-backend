#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX;
use DBI;

#calling the "main" subroutine and passing any arugments to it. 
main(@ARGV);

#Sub Main
#	Arguments Account_Id
#Pulls info from the database, sets the account path to the user's email address
#Calls the fileCreation routine passing the newAcctPath
#Calls the defaultContact routine passing the newAcctPath and database information.
#Accepts all arguments passed from the command line only used the first one which should be the account id.
sub main {
	my $dataPull=dataBasePull(dataBaseConnection(),$_[0]);
	my $newAcctPath="/usr/local/nagios/etc/accounts/$dataPull->[0][7]";
	
	fileCreation($newAcctPath);
}

#Sub fileCreation
#	Arguments $newAccountPath
#Creates all necessary files in nagios configuration directory for specified account ID
#Accepts 1 argument which should be the newAccountPath
sub fileCreation{
	my $newAcctPath=$_[0];
	my @newDirectories=("contacts", "hosts");

	if(-e "$newAcctPath") {
		die "Directory $newAcctPath already exists\n";
	} else {
		mkdir "$newAcctPath";
	}
		
	foreach my $line (@newDirectories){
		mkdir "$newAcctPath/$line";
	}

	open CONTACTFILE, '>', "$newAcctPath/contacts/contacts.cfg" || die "Unable to open $newAcctPath/contacts/contacts.cfg\n";
	open CONTACTGROUPFILE, '>',"$newAcctPath/contacts/contacts_group.cfg" || die "Unable to open $newAcctPath/contacts/contacts_group.cfg\n";
	open HOSTFILE, '>', "$newAcctPath/hosts/host1.cfg" || die "Unable to open $newAcctPath/hosts/host1.cfg";
		
	close CONTACTFILE;
	close CONTACTGROUPFILE;
	close HOSTFILE;
}

#sub dataBaseConnection
#sets the database connection information and creates the $dbh variable
#	returns $dbh
sub dataBaseConnection {
	my $dsn='dbi:mysql:strixdb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}

#sub dataBasePull
#	Arguments $dbh $accountId
#defines the query being used
#prepares the query against the database connection then exectues it.
#fetches all information returned by the database and sets it to $dump
#finishes and disconnects from the database to stay clean
#	Returns $dump
sub dataBasePull {
	my $dbh=$_[0];
	my ($sth, $dump, $query);
	
	$query="SELECT * FROM account_information WHERE account_id='$_[1]'";
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr\n";
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return $dump;
}
