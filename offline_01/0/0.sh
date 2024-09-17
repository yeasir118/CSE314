#!/usr/bin/bash

# echo the value of addition of 1 and 2
echo $((1 + 2))

a=5
b=3
echo $((a+b))

# read values from delete.txt
mapfile -t values < delete.txt
echo "${values[@]}"

echo "${values[3]}"
echo "${values[4]}"
echo $((values[3]-values[4]))

fourth=${values[3]}
fifth=${values[4]}
echo $((fourth-fifth))

mapfile -t information < $1

zip=${information[0]}
zip_types=(${information[1]})
programming_languages=(${information[2]})
for i in ${!programming_languages[@]};
do
    if [ ${programming_languages[$i]} == "python" ]; then
        programming_languages[$i]="py"
    fi
done
total_marks="${information[3]}"
penalty_unmatched="${information[4]}"
working_directory=${information[5]}
id_range=(${information[6]})
expected_output_file_path=${information[7]}
penalty_submission=$(echo "${information[8]}" | tr -d ' ')
plagiarism_file=${information[9]}
penalty_plagiarism=${information[10]}

echo $((total_marks-penalty_unmatched))
marks=$((total_marks+penalty_unmatched))
echo $marks