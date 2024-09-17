#!/usr/bin/bash

echo "Hello World!"

echo "first part"; echo "second part"

variable="Some String"

echo "$variable"
echo '$variable'

# parameter expansion
# difference between "${variable}" and "$variable"
# "${variable}" is used to Expand the value. We can modify it before printing it
# "$variable" is used to print the value as it is
echo "${variable}"

# substitute first occurrence of "Some" with "A"
echo "${variable/Some/A}"

length=7
echo "${variable:0:length}"
echo "${variable: -5}"
echo "${variable: -5:3}"

echo "${#variable}"

other_variable="${variable}"
echo "${other_variable}"

# indirect expansion
# difference between "${!other_variable}" and "$other_variable"
# "${!other_variable}" is used to Expand the value of the variable whose name is the value of other_variable
# "$other_variable" is used to print the value of other_variable
other_variable="variable"
echo "${!other_variable}"

# default value
echo "${undefined_variable:-"default value if undefined_variable is not set"}"

# array
array=(one two three four five six)
echo "${array[0]}"
echo "${array[@]}"
echo "${#array[@]}"
echo "size of third element is: ${#array[2]}"

for item in "${array[@]}";
do
    echo "$item"
done

for i in "${!array[@]}";
do
    echo "$i: ${array[$i]}"
done

echo {1..10}
echo {a..h}

echo "Current working directory: $(pwd)"

# read
echo "Enter your name: "
read name
echo "Hello $name"

if [[ "$name" != "$USER" ]]; then
    echo "You are not $USER"
else
    echo "You are $USER"
fi

echo "Enter your age: "
read age

if [[ "$name" != "Aorko" ]] && [[ "$age" -lt 18 ]]; then
    echo "You are not Aorko and you are under 18"
else
    echo "You are Aorko or you are 18 or older"
fi

# =~ is used for matching a string with a given regex pattern
if [[ "$name" =~ ^[A-Z] ]]; then
    echo "Your name starts with a capital letter"
else
    echo "Your name does not start with a capital letter"
fi

echo "Always executed" || echo "Executed only if the first command fails"
echo "Always executed" && echo "Executed only if the first command succeeds"

# expressions
echo $(( 10 + 5 ))