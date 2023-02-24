#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e  "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
#show services
OUR_SERVICES="$($PSQL "select * from services order by service_id")"
if [[ -z $OUR_SERVICES ]]
then 
echo "we dont have any service available"
else
echo "$OUR_SERVICES" | while read SERVICE_ID BAR NAME
do
echo  "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
     then 
     MAIN_MENU "That is not a number"
     else
     SERVICE=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE ]]
       then
       MAIN_MENU "I could not find that service. What would you like today?\n"
       else
       echo -e "\nWhat's your phone number?"
       read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
      # if customer not found
       if [[ -z $CUSTOMER_NAME ]]
        then
       # ask for customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # insert customer data
        UPDATE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
        fi
       SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE ")
       echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $customer_NAME?"
       read SERVICE_TIME
       customer_id="$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")" 
       if [[ $SERVICE_TIME ]]
           then
          INSERT_TIME=$($PSQL "insert into appointments(customer_id, service_id, time) values($customer_id, $SERVICE, '$SERVICE_TIME')")
         if [[ $INSERT_TIME ]]
         then   
           echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
         fi
      fi

    fi   
  fi
fi
}

MAIN_MENU
