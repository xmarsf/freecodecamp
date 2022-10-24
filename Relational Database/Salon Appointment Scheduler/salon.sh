#! /bin/bash
echo -e '\n~~~~~ MY SALON ~~~~~\n'

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"


MAIN() {
    if [[ -z $1 ]]
    then
      echo -e "\nWelcome to My Salon, how can I help you?\n"
    else
      echo -e "\n$1"
    fi
    SHOW_LIST_SERVICES
    read SERVICE_ID_SELECTED
    PICK_SERVICE $SERVICE_ID_SELECTED
    if [[ $SERVICE_NAME ]]
    then
        GET_CUSTOMER
        CREATE_APPOINTMENT
    fi
}

SHOW_LIST_SERVICES(){
    SERVICES_RESULT=$($PSQL "select service_id, name from services order by service_id")
    echo "$SERVICES_RESULT" | while IFS="|" read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
}

PICK_SERVICE(){
    REPICK_SERVICE="I could not find that service. What would you like today?"
    if [[ -z $1 ]]
    then
        MAIN "$REPICK_SERVICE"
    else
        SERVICE_RESULT=$($PSQL "select * from services where service_id = $1")
        if [[ -z $SERVICE_RESULT ]]
        then
            MAIN "$REPICK_SERVICE"
        else
            SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
        fi
    fi
    

}

GET_CUSTOMER(){
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
}

CREATE_APPOINTMENT(){
    echo -e "\nWhat time would you like your $SERVICE_NAME, Fabio?"
    read SERVICE_TIME
    INSERT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    exit 0
}

MAIN
