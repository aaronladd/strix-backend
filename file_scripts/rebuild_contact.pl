#!/usr/bin/perl -w
#/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

use strict;
use warnings;
use POSIX;
use DBI;

#calling the "main" subroutine and passing any arugments from the command line to it.
main(@ARGV);

#Subroutine main
#	Arguments $accountId
#Defines accountId then account path of the account and passes it to the rebuildContact routine
sub main {
	my $accountId=$_[0];
	my $email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email->[0][0]";
	
	rebuildContact($nagAcctPath, $accountId);
}

#Subroutine rebuildContact
#	Arguments $nagAcctPath $accountId
#Routine pulls contact file info from database, renames the contact file, and populates the new file.
#Any "null" values in the database are commented out for readability.
sub rebuildContact {
	my ($nagAcctPath, $count, $contactId);
	$nagAcctPath=$_[0];
	$count=0;
	$contactId=-1;
	my $dataPull=dataBasePull(dataBaseConnection(),$_[1],1);
	my $contactFile="$nagAcctPath/contacts/contacts.cfg";
	my $contactBackup="$nagAcctPath/contacts/contacts.bkp_cfg";
	my @contactFields=("contact_name", "alias", "use", "contactgroups", "email", "address1", "address2", "host_notifications_enabled", "service_notifications_enabled");
	my @newFields=();

	#file rename
	rename $contactFile, $contactBackup;
	
	open CONTACTFILE, '>', "$contactFile" or die $!;
	
	#looping through each contact, database information is appended to a blank array 
	#preceded by the contact field appropriate to build the configuration file
	#then written to the file
	while($contactId < $#{$dataPull}){
		$contactId++;
		
		#Runs through the array from indexs 2-8
		#for every value that is pulled from the database it puts it in line with the correct field
		#If the value is null the contact field is entered but commented out with ;
		for $count (2 .. $#{$dataPull->[0]}-1){
			if($dataPull->[$contactId][$count]){
				push @newFields, "$contactFields[$count-2] $dataPull->[$contactId][$count]";
			} else {
				push @newFields, ";$contactFields[$count-2]";
			}
		}
		
		#setting host and service notifications to on or off
		push @newFields, "$contactFields[7] $dataPull->[$contactId][9]";
		push @newFields, "$contactFields[8] $dataPull->[$contactId][9]";
		
		#writing the newly built array to the file line by line
		#define contact {
		#	@newFields
		#}
		print CONTACTFILE "define contact {\n";
		foreach my $line (@newFields){
			print CONTACTFILE "\t$line\n";
		}
		print CONTACTFILE "}\n";
		
		#nulling @newFields and clearing the count for the next run
		@newFields=();
		$count=0;
	}
	
	close CONTACTFILE;
}

#sub dataBaseConnection
#sets the database connection information and creates the $dbh variable
#	returns $dbh
sub dataBaseConnection {
	my $dsn='dbi:mysql:nagidb';
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
	my ($dbh, $accountId, $queryNum, $sth, $dump);
	my @queryList;
	$dbh=$_[0];
	$accountId=$_[1];
	$queryNum=$_[2];
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_contact WHERE account_id='$accountId'";
	
	$sth=$dbh->prepare($queryList[$queryNum]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	
	#$sth->dump_results();  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return $dump;
}
