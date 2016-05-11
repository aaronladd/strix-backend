#!/usr/bin/perl -w
#https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html#contact
use strict;
use warnings;
use POSIX;
use DBI;

#calling the "main" subroutine and passing any arguments from the command line to it.
main(@ARGV);

#Subroutine main
#	Arguments $accountId
#Defines accountId then account path of the account and passes it to the rebuildContact routine
sub main {
	my $accountId=$_[0];
	my $email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email->[0][0]";
	
	rebuildContactsGroup($nagAcctPath, $accountId);
}

#Subroutine rebuildContact
#	Arguments $nagAcctPath $accountId
#Routine pulls contact file info from database, renames the contact file, and populates the new file.
sub rebuildContactsGroup {
	my $dataPull=dataBasePull(dataBaseConnection(),$_[1],1);
	my ($nagAcctPath, $count, $groupId);
	$nagAcctPath=$_[0];
	$groupId=-1;
	my $contactsGroupFile="$nagAcctPath/contacts/contacts_group.cfg";
	my $contactsGroupBackup="$nagAcctPath/contacts/contacts_group.bkp_cfg";
	my @contactGroupFields=("contactgroup_name", "alias", "members");
	my @newFields=();
	
	rename $contactsGroupFile, $contactsGroupBackup;

	open CONTACTGROUPFILE, '>', "$contactsGroupFile" or die $!;

	#looping through each contact group, database information is appended to a blank array 
	#preceded by the contact field appropriate to build the configuration file
	#then written to the file
	while($groupId < $#{$dataPull}){
		$groupId++;
		
		#Runs through the array from indexs 2-5
		#for every value that is pulled from the database it puts it in line with the correct field
		for $count (2 .. $#{$dataPull->[0]}){
			if($dataPull->[$groupId][$count]){
				push @newFields, "$contactGroupFields[$count-2] $dataPull->[$groupId][$count]";
			}
		}
		
		#writing the newly built array to the file line by line
		#define contact_group {
		#	@newFields
		#}
		print CONTACTGROUPFILE "define contactgroup {\n";
		foreach my $line (@newFields){
			print CONTACTGROUPFILE "\t$line\n";
		}
		print CONTACTGROUPFILE "}\n";
		
		#nulling @newFields and clearing the count for the next run
		@newFields=();
	}
	
	close CONTACTGROUPFILE;
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
#	Arguments $dbh $accountId $queryNum
#defines the query being used
#prepares the query against the database connection then exectues it.
#fetches all information returned by the database and sets it to $dump
#finishes and disconnects from the database to stay clean
#	Returns $dump
sub dataBasePull {
	my ($dbh, $accountId, $sth, $dump);
	my @queryList;
	$dbh=$_[0];
	$accountId=$_[1];
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_contact_groups WHERE account_id='$accountId'";
	
	$sth=$dbh->prepare($queryList[$_[2]]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n"; 
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return($dump);
}
