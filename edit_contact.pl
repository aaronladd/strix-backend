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
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email[0]";
	@email=();
	
	my @dataPull=dataBasePull(dataBaseConnection(),$accountId,1);
	editContact($nagAcctPath, @dataPull);
	@dataPull=();
	
	editContactsGroup($nagAcctPath, $accountID);
}

sub editContact {
	my ($nagAcctPath, $accountId, $count, $match)=$_[0], $_[1] 0, false;
	my $contactFile="$nagAcctPath/contacts/contacts.cfg";
	my $contactBackup="$nagAcctPath/contacts/contacts.bkp_cfg";
	my @contactFields=("contact_name", "alias", "use", "contactgroups", "email", "address1", "address2", "contact_id");
		
	rename $contactFile $contactBackup;	
	$dataPull[1]=substr $dataPull[1], -2, 2;
	
	open CONTACTFILE, ">$contactFile" or die $!;
	open CONTACTBACKUP, "<", $contactBackup or die $!;
	while(<CONTACTBACKUP>){
		chomp();
		if($_ eq ";$contactFields[7] $dataPull[1]"){
			$match=true;
		} else if($match) {
			print CONTACTFILE "\t$contactFields[$count] $dataPull[$count+2]\n"
			$count++;
			if($count == $#contactFields){
				$match=false;
			}
		} else {
			print CONTACTFILE "$_\n";
		}
	}
	close CONTACTFILE;
	close CONTACTBACKUP;
}

sub editContactsGroup {
	my ($nagAcctPath, $accountID, $count, $match, @dataPull)=$_[0], $_[1], 0, false;
	my $contactsGroupFile="$nagAcctPath/contacts/contacts_group.cfg";
	my $contactsGroupBackup="$nagAcctPath/contacts/contacts_group.bkp_cfg";
	my @contactGroupFields=("contactgroup_name", "alias", "members", "group_id");
	my @dataPull=dataBasePull(dataBaseConnection(),$accountId,2);
	
	rename $contactsGroupFile $contactsGroupBackup;
	
	open GROUPFILE, ">$contactsGroupFile" or die $!;
	open GROUPBACKUP, "<", $contactsGroupBackup or die $!;
	
	while(<GROUPBACKUP>){
		chomp();
		if($_ eq ";$contactGroupFields[3] $group_id"){
			$match=true;
		} else if($match) {
			print GROUPFILE "\t$contactGroupFields[$count] $dataPull[$count+2]\n"
			$count++;
			if($count == $#contactFields){
				$match=false;
			}
		} else if(eof(GROUPBACKUP)){
			#separate out the new row to add to the end of the file. From the db pull.
			addGroup($contactsGroupFile, @newGroup);
		} else if($_){
			print GROUPFILE "$_\n";
		}
	}
	
	close GROUPFILE;
	close GROUPBACKUP;
}


sub dataBasePull {
	my ($dbh, $id, $account, $sth)=$_[0], $_[1];
	my @queryList;
	
	$queryList[0]="SELECT email FROM table WHERE account_id='$id'";
	$queryList[1]="SELECT * FROM table2 WHERE account_id='$id' AND contact_name='$contactName'";
	$queryList[2]="SELECT * FROM table3 WHERE account_id='$id' AND host_number='$hNum'";
	#select * from nagios_contact where account_id='1';
	
	$sth=$dbh->prepare($query[0]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	
	#$sth->dump_results();  
	#$sth->fetchall_arrayref();
	return($sth);
	
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
}

sub dataBaseConnection {
	my $host='localhost';
	#my $port='9800';
	my $dsn='dbi:mysql:nagidb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect("dbi:Proxy:hostname=$host;port=$port;dsn=$dsn",$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}
