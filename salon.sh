#! /bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU () {
    if [[ $1 ]]
    then
      echo -e "\n$1"
    fi

    SHOW_SERVICES
    read SERVICE_ID_SELECTED

    SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

    if [[ -z $SELECTED_SERVICE ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      fi

      echo -e "\nWhat time would you like your $SELECTED_SERVICE, $CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_SERVICE=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

    fi


}
SHOW_SERVICES () {

    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME;
    do
    echo "$SERVICE_ID) $SERVICE_NAME"
    done

}

MAIN_MENU
