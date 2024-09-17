#!/usr/bin/bash

# check if there is one command line argument or not
if [ $# -ne 1 ]; then
    echo "Please provide the input file"
    exit 1
elif [ ! -f $1 ]; then
    echo "corrupted input file"
    exit 1
fi

# read the input file and store it in an array
mapfile -t information < $1
if [ ${#information[@]} -ne 11 ]; then
    echo "wrong number of lines in the input file"
    exit 1
fi

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

mapfile expected_output < ./submissions/expected_output.txt
# rm ./submissions/expected_output.txt

mkdir -p ./output
mkdir -p ./output/submissions
mkdir -p ./output/submissions/checked
mkdir -p ./output/submissions/issues
cp expected_output.txt ./output/submissions/expected_output.txt
echo id,marks,marks_deducted,total_marks,remarks > ./output/submissions/marks.csv
cp plagiarism.txt ./output/plagiarism.txt
cp sample_input.txt ./output/sample_input.txt
echo "folders created"

for submission in ./submissions/*;
do
    folder_name=$(basename $submission)
    folder_ext="${folder_name##*.}"
    if [[ -d $submission ]]; then
        cp -r $submission ./output/submissions/checked
    fi
done