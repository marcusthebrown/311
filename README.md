# 311 app

We want to build something better than the default Socrata 311 site:
http://311explorer.nola.gov/main/category/

Here are some vague user stories explaining the main features:

As a citizen,
* I want to lookup info about my 311 request (by entering a reference # received from 311 or searching my previous history).
* I want to visualize ticket types with bar charts (counts) and pie graphs (percentage).
* I want to visualize the data on a map around me and filter and sort by ticket type, open/closed, date range.
* I want to browse curated datasets before exploring the data myself (maybe showing less data that's
more recent data will be useful; maybe by sharing my location, I can see more relevant data on a map
zoomed to my address).
* I want to see open requests near me.
* I want to submit issues that integrate with the City's system (the city 311 system can notify the user).
* I want the ability to choose the amount of information to share about myself (email required to submit ticket?)

Other nice to have features:
* Commenting and upvoting on issues nearby me
* Get notified about issues created by others (star/follow)
* See filter of all issues a user has submitted (email required)
* Map feature: Request per district (styled where color gets darker for more requests)
* Frequency: analyze the frequency of 311 incidents (median time, types
  that stay open the longest, etc)


## database setup

First you need to install PostgreSQL and PostGIS.

Once those are available, if you use `bash`, you can just run the `setup.sh`
script.

```
./setup.sh
```

If not, you can run the commands below to get the 311 data into your database.

```
# identify where to save the two data files
call_data_file="./nola311_raw.csv"
neighborhood_areas_file="./neighborhood_areas.geo.json"

# create the db
createuser nola311
createdb nola311 -O nola311

# download the source data
/usr/local/bin/wget --show-progress -O "$call_data_file" "https://data.nola.gov/api/views/3iz8-nghx/rows.csv?accessType=DOWNLOAD"
/usr/local/bin/wget --show-progress -O "$neighborhood_areas_file" "http://portal.nolagis.opendata.arcgis.com/datasets/e7daa4c977d14e1b9e2fa4d7aff81e59_0.geojson"

# create the table and import the data from the csv
psql --set=call_data_file="$call_data_file" --set=neighborhood_areas_file="$neighborhood_areas_file" -U postgres -d nola311 -f setup/schema_and_csv_import.sql

# sanitize the table
psql -U nola311 -d nola311 -f setup/sanitize.sql

# create views
psql -U nola311 -d nola311 -f views/open_tickets_stats.sql
psql -U nola311 -d nola311 -f views/closed_tickets_stats.sql
psql -U nola311 -d nola311 -f views/call_records_for_review.sql
psql -U nola311 -d nola311 -f views/call_records_with_call_for_details.sql
```

## some sample queries

```sql
-- what are the top issues that people call about?
select issue_type, count(*) as num_calls from nola311.calls group by issue_type order by num_calls desc;

-- which council district has the most calls?
select council_district, count(*) as num_calls from nola311.calls group by council_district order by num_calls desc;
```
