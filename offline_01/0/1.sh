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

mapfile expected_output < ./demo_submissions/expected_output.txt

for submission in ./demo_submissions/*;
do
    if [ -d $submission ]; then
        cp -r $submission ./extracted_files
    else
        submission_extension="${submission##*.}"
        exist=0
        for ext in ${zip_types[@]};
        do
            if [ $submission_extension == $ext ]; then
                exist=1
                break
            fi
        done
        if [ $exist -eq 1 ]; then
            # check if the submission is a zip file
            if [ ${submission: -4} == ".zip" ]; then
                unzip -q $submission -d ./extracted_files
            # check if the submission is a .tar.xz file
            elif [ ${submission: -7} == ".tar.xz" ]; then
                tar -xf $submission -C ./extracted_files
            # check if the submission is a .rar file
            elif [ ${submission: -4} == ".rar" ]; then
                unrar x $submission ./extracted_files
            fi
        elif [ -f $submission ]; then
            filename_with_extension=$(basename $submission)
            filename="${filename_with_extension%.*}"
            mkdir -p ./extracted_files/$filename
            cp $submission ./extracted_files/$filename
        else
            echo "archive format not supported. skipping evaluation for " $(basename $submission)
        fi
    fi
done

echo "log" > ./log.txt
echo "id,marks,marks_deducted,total_marks,remarks" > ./result.csv
for folder in ./extracted_files/*;
do
    if [ -d $folder ]; then
        if [ $(ls $folder | wc -l) -eq 1 ]; then
            file_name_with_extension=$(ls $folder)
            file_name="${file_name_with_extension%.*}"
            extension="${file_name_with_extension##*.}"

            if [ $file_name == $(basename $folder) ]; then
                ext_match=0
                for ext in ${programming_languages[@]};
                do
                    if [ $extension == $ext ]; then
                        ext_match=1
                        break
                    fi
                done
                if [ $ext_match -eq 0 ]; then
                    echo "Submitted file not in allowed programming languages. Skipping evaluation for " $(basename $folder)
                    echo "$(basename $folder),0,0,$total_marks,submitted file not in allowed programming languages" >> ./result.csv
                else 
                    if [ $extension == "py" ]; then
                        python3 $folder/$file_name_with_extension > $folder/$file_name"_output.txt"
                    elif [ $extension == "c" ]; then
                        gcc $folder/$file_name_with_extension -o $folder/$file_name
                        $folder/$file_name > $folder/$file_name"_output.txt"
                    elif [ $extension == "cpp" ]; then
                        g++ $folder/$file_name_with_extension -o $folder/$file_name
                        $folder/$file_name > $folder/$file_name"_output.txt"
                    elif [ $extension == "sh" ]; then
                        chmod +x $folder/$file_name_with_extension
                        bash $folder/$file_name_with_extension > $folder/$file_name"_output.txt"
                    fi

                    mapfile output < $folder/$file_name"_output.txt"
                    deducted_marks=0
                    for line in "${expected_output[@]}";
                    do
                        if [[ ! " ${output[@]} " =~ " ${line} " ]]; then
                            # echo $(basename $folder) " has output mismatch"
                            deducted_marks=$((deducted_marks+penalty_unmatched))
                        fi
                    done
                    marks=$((total_marks-deducted_marks))
                    echo "$(basename $folder),$marks,$deducted_marks,$total_marks" >> ./result.csv
                    # echo "Marks for " $(basename $folder) " is " $marks
                fi 
            else
                echo "The extracted folder name does not match the file name for " $(basename $folder)
                echo "$(basename $folder),0,0,$total_marks,extracted folder name does not match the file name" >> ./result.csv
            fi
        fi
    fi
done