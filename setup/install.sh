#!/bin/bash
#!/usr/bin/bash
#!/usr/local/bin/bash

# sanitize the tables
psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME} -f setup/sanitize_call_data.sql
psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME} -f setup/sanitize_neighborhood_data.sql

# create views
psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME} -f views/open_tickets_stats.sql -q
psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME} -f views/closed_tickets_stats.sql -q
psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME} -f views/call_records_for_review.sql -q
psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME} -f views/call_records_with_call_for_details.sql -q
