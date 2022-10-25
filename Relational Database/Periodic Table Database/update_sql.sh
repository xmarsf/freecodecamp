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
declare -A TYPE_ID_BY_NAME
while read TYPE_NAME
do
  INSERT_TYPE_RESULT=$($PSQL "insert into types(type) values ('$TYPE_NAME');")
  TYPE_ID=$($PSQL "select type_id from types where type='$TYPE_NAME'")
  TYPE_ID_BY_NAME[$TYPE_NAME]=$TYPE_ID
  UPDATE_PROPERTIES_RESULT=$($PSQL "update properties set type_id=$TYPE_ID where type='$TYPE_NAME'")
done <<< $(echo "$TYPES_RESULT")

$PSQL "alter table properties add constraint atomic_fk foreign key (atomic_number) references elements (atomic_number),
 add constraint type_fk foreign key (type_id) references types (type_id), 
 alter column type_id set not null;"

$PSQL "update elements set symbol=initcap(symbol);"
$PSQL "alter table properties alter column atomic_mass type DECIMAL"
$PSQL "update properties set atomic_mass=atomic_mass::REAL::DECIMAL;"

type_nonmetal_id=${TYPE_ID_BY_NAME[nonmetal]}
$PSQL "insert into elements (atomic_number,symbol,name) values('9', 'F', 'Fluorine'), ('10', 'Ne', 'Neon');"
$PSQL "insert into properties (atomic_number, type, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) values
('9', 'nonmetal', 18.998, -220, -188.1, $type_nonmetal_id), ('10', 'nonmetal', 20.18, -248.6, -246.1, $type_nonmetal_id);"
$PSQL "alter table properties drop column type;"
$PSQL "delete from properties where atomic_number=1000;"
$PSQL "delete from elements where atomic_number=1000;"
