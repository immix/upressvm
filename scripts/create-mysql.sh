#!/usr/bin/env bash

DB=$1;
mysql --user=homestead --password=secret -e "DROP DATABASE IF EXISTS $DB";
mysql --user=homestead --password=secret -e "CREATE DATABASE $DB";
