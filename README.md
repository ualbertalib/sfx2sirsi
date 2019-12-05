Outline of Algorithm
===================== TEST

sfx2sirsi takes in an XML file of our e-journal holdings in SFX, combines those with summary holdings (date coverage) information also drawn from SFX, and produces update files for Sirsi/Symphony. 

Detailed Algorithm
===================
* SFX exports its data nightly
* When sfx2sirsi runs, it a) downloads the SFX marcxml data and b) downloads the summary holdings HTML data
* sfx2sirsi performs clean up on summary holdings data
* sfx2sirsi then reads the SFX data and creates a hash-digest for each record
* If sfx2sirsi is running a full update, then it ignores the previous run's hashes and updates all records
* If sfx2sirsi is running a nightly or incremental update, then it first reads the previous run's hashes (contained in the file data/hash) and only continues if one or more records have changed since the previous run.
* sfx2sirsi reads the cleaned up summary holdings data
* Then it iterates through each record, producing a SirsiRecord, and outputting each record to a file. The file is either sfx-sirsi-full.txt or sfx-sirsi-incremental.txt, depending on the mode of the update.
* Finally, sfx2sirsi writes a hash file of all records.

Usage
=====
Deploy the ruby directory to a server with curl access to both the SFX server and the batchjobs server. Set up crontabs to run nightly and incremental updates as often as desired. 

Rake Tasks
===========
* rake fetch_dates: Fetch summary holdings data
* rake fetch_sfx: Fetch SFX data
* rake full_update: Full update
* rake full_update_only: Full update (w/o fresh data)
* rake nightly_update: Nightly update
* rake nightly_update_only: Nightly update (w/o fresh data)
* rake tests: Run all tests


File Descriptions
==================

* tests: unit tests
* .gitignore: .gitignore file
* Gemfile: ruby libraries
* Gemfile.lock: lock file for ruby libraries
* README.md: README
* Rakefile: Rakefile used for automatic tasks (testing, updating, etc)
* clean_summary_holdings.rb: clean up raw data pulled from Jeremy's php script
* config_module.rb: ruby module for using util.conf for configuration settings
* fetch_sfx_data.rb: pulls down e-journal data from SFX server
* full.rb: script for running full update by hand
* run.rb: mainline script for updates
* sed_dates.sh: uses by clean_summary_holdings.rb to clean raw data
* sfx2sirsi.rb: Ruby class for record collection
* sfx2sirsi.sh: shell script that runs on SFX server to perform nightl export of e-journal data
* sirsi_record.rb: Ruby class for records to be sent to Sirsi/Symphony
* util.conf: configuration settings

External Dependencies:
======================
* PHP script that pulls target-specific date statements for each title and presents a full coverage statement in HTML (located on web server).
* Perl scripts that update Sirsi/Symphony and produce log files (located on Symphony server).

Data Files
===========
* Infiles: sfxdata.xml (e-journal data from SFX); summary holdings (date coverage) HTML file.
* Outfiles: hash (contains hash-digests of all records); sfx-sirsi-full.txt/sfx-sirsi-incremental.txt (files of records to be sent to Symphony to update the ILS)
* Symphony script log files: 
** badissn.txt: Records rejected because of bad issn
** holderr.txt: Records rejected because summary holdings mismatch
** noissn.txt: Records rejected because no issn
** hasRelatedRecs.txt: Records that have earlier or later titles
** matchissn.txt: Records that matched (and were either updated or not)
** noRelatedRecs.txt: Records that do not have earlier or later titles
** notSFX.txt: Records which are in Symphony, but not in SFX
** noURL.txt: Record rejected because bad or missing 856 link
** singleHold.txt: Records for which we only have a single subscription
** unchangedPubDates.txt: Records which were unchanged

* Note: These files are produced by the Symphony script and are used by the serials-admin Rails application.
