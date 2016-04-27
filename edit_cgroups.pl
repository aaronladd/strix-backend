#!/usr/bin/perl -w
#https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html#contact
use strict;
use warnings;
use POSIX;
use DBI;

main(@ARGV);

sub main {
	my ($accountId)=$_[0];
	my @email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email->[0][0]";
	@email=();
	
	editContactsGroup($nagAcctPath, $accountId);
}

sub editContactsGroup {
	my ($nagAcctPath, $accountID, $count, $match, $contactNumber, $currentLine)=$_[0], $_[1], 0, false, 0;
	my $contactsGroupFile="$nagAcctPath/contacts/contacts_group.cfg";
	my $contactsGroupBackup="$nagAcctPath/contacts/contacts_group.bkp_cfg";
	my @contactGroupFields=("contactgroup_name", "alias", "members", "group_id");
	my $dataPull=dataBasePull(dataBaseConnection(),$accountId,2);
	
	rename $contactsGroupFile $contactsGroupBackup;
	
	open GROUPFILE, ">$contactsGroupFile" or die $!;
	open GROUPBACKUP, "<", $contactsGroupBackup or die $!;
	
	while(<GROUPBACKUP>){
		chomp();
		$currentLine=$_;
		$dataPull->[$contactNumber][1]=substr $dataPull->[$contactNumber][1], -2, 2;
		
		if($currentLine eq ";$contactGroupFields[3] $dataPull->[$contactNumber][1]"){
			$match=true;
		} else if($match) {
			print GROUPFILE "$contactGroupFields[$count] $dataPull->[$count+2]\n"
			$count++;
			if($count == $#contactFields){
				$match=false;
				$contactNumber++;
			}
		} else if(eof(GROUPBACKUP)){
			#separate out the new row to add to the end of the file. From the db pull.
			addGroup($contactsGroupFile, @newGroup);
		} else if($currentLine){
			print GROUPFILE "$currentLine\n";
		}
	}
	
	close GROUPFILE;
	close GROUPBACKUP;
}


sub dataBasePull {
	my ($dbh, $accountId, $queryNum, $sth, $dump)=$_[0], $_[1] $_[2];
	my @queryList;
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_contact_groups WHERE account_id='$accountId'";
	
	$sth=$dbh->prepare($queryList[$queryNum]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	
	#$sth->dump_results();  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return($dump);
}

sub dataBaseConnection {
	my $dsn='dbi:mysql:nagidb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}
