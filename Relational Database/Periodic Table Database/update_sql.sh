#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

$PSQL "ALTER table properties rename column weight to atomic_mass;"
$PSQL "ALTER table properties rename column melting_point to melting_point_celsius;"
$PSQL "ALTER table properties rename column boiling_point to boiling_point_celsius;"
$PSQL "alter table properties alter column melting_point_celsius set not null;"
$PSQL "alter table properties alter column boiling_point_celsius set not null;"

$PSQL "alter table elements alter column symbol set not null, add constraint symbol_unq unique(symbol),
 alter column name set not null, add constraint name_unq unique(name);"

$PSQL "create table types(type_id serial primary key, type varchar not null unique);"
$PSQL "alter table properties add column type_id int;"


# select type from elements and insert back to types table
TYPES_RESULT=$($PSQL "select distinct(type) from properties;")

echo "$TYPES_RESULT" | while read TYPE_NAME
do
  INSERT_TYPE_RESULT=$($PSQL "insert into types(type) values ('$TYPE_NAME');")
  TYPE_ID=$($PSQL "select type_id from types where type='$TYPE_NAME'")
  UPDATE_PROPERTIES_RESULT=$($PSQL "update properties set type_id=$TYPE_ID where type='$TYPE_NAME'")
done

$PSQL "alter table properties add constraint atomic_fk foreign key (atomic_number) references elements (atomic_number),
 add constraint type_fk foreign key (type_id) references types (type_id), 
 alter column type_id set not null;"

$PSQL "update elements set symbol=initcap(symbol);"
$PSQL "alter table properties alter column atomic_mass type DECIMAL"
$PSQL "update properties set atomic_mass=atomic_mass::REAL::DECIMAL;"
