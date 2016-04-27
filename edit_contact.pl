#!/usr/bin/perl -w
#https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html#contact
use strict;
use warnings;
use POSIX;
use DBI;

main(@ARGV);

sub main {
	my ($accountId)=$_[0];
	my $email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email[0][0]";
	
	editContact($nagAcctPath, $accountId);
}

sub editContact {
	my ($nagAcctPath, $accountId, $count, $match, $contactNumber, $currentLine)=$_[0], $_[1] 0, false, 0;
	my $contactFile="$nagAcctPath/contacts/contacts.cfg";
	my $contactBackup="$nagAcctPath/contacts/contacts.bkp_cfg";
	my @contactFields=("contact_name", "alias", "use", "contactgroups", "email", "address1", "address2", "contact_id");
	my $datapull=dataBasePull(dataBaseConnection(),$accountId,1);
	
	rename $contactFile $contactBackup;	
	
	open CONTACTFILE, ">$contactFile" or die $!;
	open CONTACTBACKUP, "<", $contactBackup or die $!;
	while(<CONTACTBACKUP>){
		chomp();
		$currentLine=$_;
		$dataPull->[$contactNumber][1]=substr $dataPull->[$contactNumber][1], -2, 2;
		
		if($currentLine eq ";$contactFields[7] $dataPull->[$contactNumber][1]"){
			$match=true;
		} else if($match) {
			print CONTACTFILE "$contactFields[$count] $dataPull->[$contactNumber][$count+2]\n"
			$count++;
			if($count == $#contactFields){
				$match=false;
				$contactNumber++;
			}
		} else if(eof(CONTACTBACKUP)){
			#separate out the new row to add to the end of the file. From the db pull.
			addGroup($contactsGroupFile, @newGroup);
		} else if($currentLine){
			print CONTACTFILE "$currentLine\n";
		}
	}
	close CONTACTFILE;
	close CONTACTBACKUP;
}

sub dataBasePull {
	my ($dbh, $accountId, $queryNum, $sth, $dump)=$_[0], $_[1], $_[2];
	my @queryList;
	
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

sub dataBaseConnection {
	my $dsn='dbi:mysql:nagidb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}
