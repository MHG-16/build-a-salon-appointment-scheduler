#!/bin/bash 
PSQL="psql -X --username=freecodecamp --dbname=salon  --tuples-only -c"

echo -e "\n~~ My salon ~~\n"

SERVICES=$($PSQL "SELECT service_id, name FROM services")

echo -e "Welcome to My Salon, how can I help you?\n"

#DISPLAY SERVICES
DISPLAY_SERVICES(){
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    if [[ ! -z $NAME && $NAME != name ]]
    then
      echo "$SERVICE_ID) $NAME"
    fi
  done
}

DISPLAY_SERVICES
read SERVICE_ID_SELECTED
# GET SERVICE_ID
SERVICE_NAME_RETURNED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

while [[ -z $SERVICE_NAME_RETURNED ]]
do
  # display services again
  DISPLAY_SERVICES "I could not find that service. What would you like today?"
  read SERVICE_ID_SELECTED
  # GET SERVICE_ID
  SERVICE_NAME_RETURNED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
#Check customer with this nummer if not exists
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  #INSERT new_customer into customers
  CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME_RETURNED | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
read SERVICE_TIME
APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
if [[ $APPOINTMENT_INSERT_RESULT == "INSERT 0 1" ]]
then
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME_RETURNED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
fi