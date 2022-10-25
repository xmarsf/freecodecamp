#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

show_element() {
  param=$1
  # check if param is a number
  re='^[0-9]+$'
  if ! [[ $param =~ $re ]] ; then
    where_clause="where symbol = '$param' or name = '$param'"
  else
    where_clause="where em.atomic_number = $param"
  fi
  query="select em.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
  from elements as em 
  left join properties as pr on em.atomic_number = pr.atomic_number
  left join types on pr.type_id = types.type_id 
  $where_clause
  limit 1"
  search_result=$($PSQL "$query")
  if [[ -z $search_result ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$search_result" | while IFS='|' read atomic_number symbol name element_type atomic_mass melting_point_celsisus boiling_point_celsius
    do
      echo "The element with atomic number $atomic_number is $name ($symbol). It's a $element_type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsisus celsius and a boiling point of $boiling_point_celsius celsius."
    done
  fi
}


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  show_element $1
fi