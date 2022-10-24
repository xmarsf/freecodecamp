#! /bin/bash

PSQL="psql --username=postgres --dbname=postgres -t --no-align -c"
$PSQL "drop database salon"
$PSQL "create database salon"
PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

$PSQL "create table customers(customer_id serial primary key, phone varchar unique, name varchar)"
$PSQL "create table services(service_id serial primary key, name varchar)"
$PSQL "create table appointments(appointment_id serial primary key, customer_id int references customers(customer_id), service_id int references services(service_id), time varchar)"

$PSQL "insert into services(name) values('cut') ,('color') ,('perm') ,('style'), ('trim')"
