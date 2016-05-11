#!/usr/bin/perl -w
#https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html#contact
#/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

use strict;
use warnings;
use POSIX;
use DBI;

#calling the "main" subroutine and passing any arguments from the command line to it.
main(@ARGV);

#Subroutine main
#	Arguments $accountId
#Defines accountId then account path of the account and passes it to the rebuildAllHosts routine
sub main {
	my $accountId=$_[0];
	my $email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email->[0][0]";
	
	rebuildAllHosts($nagAcctPath, $accountId);
}

#Subroutine rebuildContact
#	Arguments $nagAcctPath $accountId
#Routine pulls host and service file info from database, renames the host directory, and populates the new files.
#each file is made up of host information and then multiple services that are monitored within the host
#Any "null" values in the database are commented out for readability.
sub rebuildAllHosts {
	my ($nagAcctPath, $count, $hostId, $hostFile, $hostFileNumber, $services, $serviceNum, $accountId, $queryHostId);
	$nagAcctPath=$_[0];
	$accountId=$_[1];
	$hostId=-1;
	$serviceNum=-1;
	my $hosts=dataBasePull(dataBaseConnection(),$accountId,1);
	my $hostDir="$nagAcctPath/hosts";
	my $hostDirBackup="$nagAcctPath/hosts_bkp";
	my @hostFields=("host_name", "alias", "address", "use", "contacts", "contact_groups");
	my @serviceFields=("host_name", "service_description", "check_command", "use", "contacts", "contact_groups");
	my @newFields=();

	#renaming the directory and then recreating the original
	rename $hostDir, $hostDirBackup;
	mkdir $hostDir || die $!;
	
	#looping through each host, database information is appended to a blank array 
	#preceded by the contact field appropriate to build the configuration file
	#then written to the file
	while($hostId < $#{$hosts}){
		$hostId++;
		#nagios reads host files in host#.cfg format
		#taking hostId which starts at 0
		#incrementing and setting the hostfile name to include that number
		$hostFileNumber=$hostId+1;
		$hostFile="$hostDir/host$hostFileNumber.cfg";
	
		open HOSTFILE, '>', "$hostFile" or die $!;
		
		#counting through indexes 2->8
		#for every value that is pulled from the database it puts it in line with the correct field
		#If the value is null the contact field is entered but commented out with ;
		for $count (2 .. $#{$hosts->[0]}){
			if($hosts->[$hostId][$count]){
				push @newFields, "$hostFields[$count-2] $hosts->[$hostId][$count]";
			} else {
				push @newFields, ";$hostFields[$count-2]";
			}
		}
		
		#writing the newly built array to the file line by line
		#define host {
		#	@newFields
		#}
		print HOSTFILE "define host {\n";
		foreach my $line (@newFields){
			print HOSTFILE "\t$line\n";
		}
		print HOSTFILE "}\n";
		
		#nulling @newFields and clearing the count for adding services
		@newFields=();
		
		#pulling service information from the database
		#passing database connection info, accountId, queryNumber, and hostId as it's viewed in the database
		$services=dataBasePull(dataBaseConnection(),$_[1],2,$hosts->[$hostId][1]);
		
		#looping through each service, database information is appended to a blank array 
		#preceded by the contact field appropriate to build the configuration file
		#then written to the file
		while ($serviceNum < $#{$services}){
			$serviceNum++;
		
			#counting through indexes 3->9
			#for every value that is pulled from the database it puts it in line with the correct field
			#If the value is null the contact field is entered but commented out with ;
			for $count (3 .. $#{$services->[0]}){
				if($services->[$serviceNum][$count]){
					push @newFields, "$serviceFields[$count-3] $services->[$serviceNum][$count]";
				} else {
					push @newFields, ";$serviceFields[$count-3]";
				}
			}
			
			#writing the newly built array to the file line by line
			#define host {
			#	@newFields
			#}
			#define service {
			#	@newFields
			#}
			print HOSTFILE "define service {\n";
			foreach my $line (@newFields){
				print HOSTFILE "\t$line\n";
			}
			print HOSTFILE "}\n";
			
			#clearing newFields array for other services
			@newFields=();
		}
		
		#resetting service number to -1, clearing @newFields, and closing the current file
		@newFields=();
		$serviceNum=-1;
		close HOSTFILE;
	}
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
#	Arguments $dbh $accountId $queryNum $hostId
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
	$queryList[1]="SELECT * FROM nagios_host WHERE account_id='$accountId'";
	#if the hostId is passed then the below query is available, prevents a call to unset variable if the hostId isn't passed
	if($_[3]){
		$queryList[2]="SELECT * FROM nagios_host_services WHERE account_id='$accountId' AND host_id='$_[3]'";
	}
	
	$sth=$dbh->prepare($queryList[$queryNum]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return $dump;
}
