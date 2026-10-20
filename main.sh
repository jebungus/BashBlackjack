#!/bin/bash

# player name
user=$(whoami)

#file i/o names
userSave="save.txt" # gets player stats from input
history="history.txt" # stores history of current game in an output file

>history.txt #clears history before game begins

echo "Current User: $user"
echo

if grep -Fxq "$user" save.txt
then
    echo "Welcome back $user"
    lineNum=$(expr $(grep -n "$user" save.txt -m 1 | cut -d: -f1) + 1)
    
    chips=$(awk "NR==$lineNum" save.txt)
    
else
    echo "Welcome $user!"
    echo "Here is a Welcome Gift of 500 Chips!"

    chips=500
    echo $user >> save.txt
    echo 500 >> save.txt
    echo >> save.txt
fi
echo



function updateChips {
lNum=$2

sed -i " $lNum d" save.txt
sed -i " $lNum i $1" save.txt
echo $1
}




function getPlayerTotal {
sum=0

for i do
  if [ "$i" -eq 11 ]; then
  sum=$(expr $sum + 10)

  elif [ "$i" -eq 12 ]; then

  sum=$(expr $sum + 10)

  elif [ "$i" -eq 13 ]; then

  sum=$(expr $sum + 10)

  elif [ "$i" -eq 1 ]; then
  
    if [ "$sum" -gt 10 ]; then

    sum=$(expr $sum + 1)

    else
    sum=$(expr $sum + 11)

    fi

  else
   
    sum=$(expr $sum + $i)

  fi
done

echo $sum

}


function displayPlayerStats {
allDisplay=""
sum=0

for i do
  if [ "$i" -eq 11 ]; then
  allDisplay+=" J"
  sum=$(expr $sum + 10)
  

  elif [ "$i" -eq 12 ]; then

  allDisplay+=" Q"
  sum=$(expr $sum + 10)
  
  elif [ "$i" -eq 13 ]; then
  allDisplay+=" K"
  sum=$(expr $sum + 10)
  
  elif [ "$i" -eq 1 ]; then
  allDisplay+=" A"
    if [ "$sum" -gt 10 ]; then
    
    sum=$(expr $sum + 1)
    
    else
    sum=$(expr $sum + 11)

    fi
  
  else
    allDisplay+=" $i"
    sum=$(expr $sum + $i)
    
  fi
done

echo "Player Cards:$allDisplay. Total: $sum"

}


#displays just the face-up card of the dealer
function displayDealer {
allDisplay=""

if [ "$1" -eq 11 ]; then
allDisplay+=" J"

elif [ "$1" -eq 12 ]; then

allDisplay+=" Q"

elif [ "$1" -eq 13 ]; then
allDisplay+=" K"
sum=$(expr $sum + 10)

elif [ "$1" -eq 1 ]; then
allDisplay+=" A"

else
  allDisplay+=" $1"


fi

echo "Dealer Showing:$allDisplay"

}












#displays the dealer's hands and automatically takes actions for the house
function displayDealerFull {

#full card display must be reset each recursive loop
allDisplay=""
sum=0
condition=0


for i do
 
  if [ "$i" -eq 11 ]; then
  allDisplay+=" J"
  sum=$(expr $sum + 10)
  

  elif [ "$i" -eq 12 ]; then

  allDisplay+=" Q"
  sum=$(expr $sum + 10)
  
  elif [ "$i" -eq 13 ]; then
  allDisplay+=" K"
  sum=$(expr $sum + 10)
  
  elif [ "$i" -eq 1 ]; then
  allDisplay+=" A"
    if [ "$sum" -gt 10 ]; then
    
    sum=$(expr $sum + 1)
    
    else
    sum=$(expr $sum + 11)

    fi
  
  else
    allDisplay+=" $i"
    sum=$(expr $sum + $i)
    
  fi
done

echo "Dealer Cards:$allDisplay. Total: $sum"
echo

if [ "$sum" -gt 21 ]; then
echo "Dealer Has $sum. Dealer Bust! You Win!"
condition=3

elif [ "$sum" = 21 ]; then
echo "Dealer Has $sum. Dealer Wins!"
condition=2

elif [ "$sum" -gt 16 ]; then
echo "Dealer Has $sum. Dealer Stands."
condition=1

elif [ "$sum" -le 16 ]; then
echo "Dealer Has $sum. Dealer Hits."
condition=0
fi





#what to do based on result of dealer's hand

#generate next Card and recurse: condition 0
if [ "$condition" = 0 ]; then
dealerCardMisc+=" $(($RANDOM % 13 + 1))"
displayDealerFull $1 $2 $dealerCardMisc

#Stand and check for player result: condition 1
elif [ "$condition" = 1 ]; then
return $sum

#Dealer Blackjack: condition 2
elif [ "$condition" = 2 ]; then
return 2

#Dealer Bust: condition 3
else 
return 3

fi

}








#begins the game
function deal() {

echo "How much would you like to bet? You currently have $chips chips."
read response




while [  "$response" != "quit"  -a  "$response" != "Quit"  -a  "$response" != "q"  ]

do
bet=$response
echo

while [ "$response" -gt "$chips" -o "$response" -lt 1 ]
do
echo "You don't have enough chips. How much would you like to bet? You currently have $chips"
read response
done


dealerCardMisc=()

#deal new cards
let "playerCard1 = $(($RANDOM % 13 + 1))"


let "playerCard2 = $(($RANDOM % 13 + 1))"


#dealer's cards
let "dealerCard1 = $(($RANDOM % 13 + 1))"

let "dealerCard2 = $(($RANDOM % 13 + 1))"


#display cards

displayPlayerStats $playerCard1 $playerCard2

displayDealer $dealerCard1

echo


#to keep track of actions taken in while loop
actionsTaken=0





#Check for instant blackjack
total=$(getPlayerTotal $playerCard1 $playerCard2)

if [ "$total" = 21 ]; then
echo "BlackJack! You Win!"
chips=$(updateChips $(expr $bet + $chips) $lineNum)

else

#player decision
echo "Your Options: Hit, Stand, Double Down, Surrender"

read response
playerCardMisc=()
#options during a round repeat until bust or stand
#Beginning of main While loop -=-=-=-=-=-=
while [ "$response" != "quit"  -a  "$response" != "Quit"  -a  "$response" != "q" ]
do
actionsTaken=$(expr $actionsTaken + 1)


echo

#player Hits
if [ "$response" = "Hit" ]; then


  #generate next Card
    playerCardMisc+=" $(($RANDOM % 13 + 1))"


  #display player Cards
    displayPlayerStats $playerCard1 $playerCard2 $playerCardMisc




  #check for bust
  total=$(getPlayerTotal $playerCard1 $playerCard2 $playerCardMisc)
  
  if [ "$total" -gt 21 ]; then
  
    echo "Bust! Dealer Wins!"
    chips=$(updateChips $(expr $chips - $bet) $lineNum)
    actionsTaken=0
    break;
  #check for win
  elif [ "$total" = 21 ]; then
    actionsTaken=0
    echo "Blackjack! You Win"
    chips=$(updateChips $(expr $chips + $bet) $lineNum)
    break;
  else
    echo "Dealer Is Showing: $dealerCard1"

  fi

#End of Hit Option -=-=-=


#Stand
elif [ "$response" = "Stand" ]; then

displayPlayerStats $playerCard1 $playerCard2 $playerCardMisc
displayDealerFull $dealerCard1 $dealerCard2

#get return value indicating dealer's hand
dealerCondition=$?



#2 = dealer blackjack
if [ "$dealerCondition" = 2 ]; then
displayPlayerStats $playerCard1 $playerCard2 $playerCardMisc
chips=$(updateChips $(expr $chips - $bet) $lineNum)


#3 = dealer bust
elif [ "$dealerCondition" = 3 ]; then

chips=$(updateChips $(expr $chips + $bet) $lineNum)



#anything else = dealer's total
else 
displayPlayerStats $playerCard1 $playerCard2 $playerCardMisc
  if [ "$total" = "$dealerCondition" ]; then #push
    echo "Push! No Winner!"
    
  elif [ "$total" -gt "$dealerCondition" ]; then #player wins
    echo "You Win!"
    chips=$(updateChips $(expr $chips + $bet) $lineNum)
    
  else #dealer wins
    echo "Dealer Wins!"
    chips=$(updateChips $(expr $chips - $bet) $lineNum)
  fi
fi
actionsTaken=0
break


#Double Down
#Treated as one Hit and then a Stand
#also doubles bet
elif [ "$response" = "Double Down" -o "$response" = "dd" -o "$response" = "double down" ]; then
echo $actionsTaken
  if [ "$actionsTaken" = 1 ]; then
  
  
  if [ "$(expr $bet \* 2)" -le "$chips" ]; then
    bet=$(expr $bet \* 2)
  else
    echo "You do not have enough chips to double down."
    echo
    echo "Your Options: Hit, Stand, Double Down, Surrender"
    read response
    continue
  fi
  #generate next Card
  playerCardMisc+=" $(($RANDOM % 13 + 1))"

  #display player Cards
  displayPlayerStats $playerCard1 $playerCard2 $playerCardMisc

  #check for bust
  total=$(getPlayerTotal $playerCard1 $playerCard2 $playerCardMisc)
  
  if [ "$total" -gt 21 ]; then
  
    echo "Bust! Dealer Wins!"
    chips=$(updateChips $(expr $chips - $bet) $lineNum)
    break
  #check for win
  elif [ "$total" = 21 ]; then

    echo "Blackjack! You Win"
    chips=$(updateChips $(expr $chips + $bet) $lineNum)
    break

  fi

  response="Stand"
  actionsTaken=0
  continue


  
  else
  echo "You Cannot Double Down After The First Turn"
  fi


#Surrender
elif [ "$response" = "Surrender" ]; then
  echo "You Surrendered! Dealer Wins!"
  bet=$(expr $bet / 2)
  chips=$(updateChips $(expr $chips - $bet) $lineNum)
  actionsTaken=0
  break;

  
else
echo "Invalid Response! Your Options: Hit, Stand, Double Down, Surrender"
actionsTaken=0
fi
#End of Options -=-=-





#repeat until Quit
read response
done
#end of inner while loop
fi
# fi is here from above if statement
#in other words, the whole while loop is only if there is no instant Blackjack





echo "How much would you like to bet? You currently have $chips chips."
read response


done
#end of outer while loop
}
deal

