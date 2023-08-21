#!/bin/bash

echo -e "\n ~~ Salon services ~~ \n"

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

PICK_SERVICE() {
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  echo -e "\nSelect a service:\n"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  # if choice is nan
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    PICK_SERVICE
  else
    SERVICE_CHOICE_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    # if service doesnt exit
    if [[ -z $SERVICE_CHOICE_RESULT ]]
    then
      PICK_SERVICE
    else
      BOOK_SERVICE
    fi
  fi
}

BOOK_SERVICE() {
  echo -e "\nEnter a phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if there is not any user registered with this phone
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nEnter your name:"
    read CUSTOMER_NAME
    REGISTER_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  echo -e "\nEnter a time for the booking (hh:mm):"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # once having all info, make the booking
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # sum up the booking
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


PICK_SERVICE
