#!/bin/bash
# ~~~~ SALON APPOINTMENT SCHEDULER ~~~~

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_MENU() 
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "select * from services order by service_id")
  echo -e "$SERVICES" | sed -r 's/^ *([0-9]+) \|/\1)/'
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    SERVICE_MENU "I could not find that service. What would you like today?"
  else
    # check service name
    SERVICE_NAME_PICKED=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    # trim any spaces in the name
    SERVICE_NAME_TRIMMED=$(echo $SERVICE_NAME_PICKED | sed -r 's/^ *| *$//g')

    if [[ -z $SERVICE_NAME_TRIMMED ]]
    then
      #send to main menu
      SERVICE_MENU "I could not find that service. What would you like today?"
    else
      # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      # trim any spaces in the name
      CUSTOMER_NAME_TRIMMED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME_TRIMMED', '$CUSTOMER_PHONE')")
      fi

      # get customer_id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

      # get service time
      echo -e "\nWhat time would you like your color, $CUSTOMER_NAME_TRIMMED?"
      read SERVICE_TIME

      # trim any spaces in the time
      SERVICE_TIME_TRIMMED=$(echo $SERVICE_TIME | sed -r 's/^ *| *$//g')

      # insert appointment
      APPT_INSERT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_TRIMMED')")

      # confirm booking to user
      echo -e "\nI have put you down for a $SERVICE_NAME_TRIMMED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi

  
}

SERVICE_MENU 