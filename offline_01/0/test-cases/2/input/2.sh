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
cp ./submissions/expected_output.txt ./output/submissions/expected_output.txt
echo id,marks,marks_deducted,total_marks,remarks > ./output/submissions/marks.csv
cp plagiarism.txt ./output/plagiarism.txt
cp sample_input.txt ./output/sample_input.txt

for submission in ./submissions/*;
do

    marks=0
    deducted_marks=0
    total_marks_csv=0
    remarks=""

    has_issue=0
    zipped_folder_name=$(basename $submission)
    zip_folder_ext="${zipped_folder_name##*.}"
    folder=$(basename $submission .zip)
    # echo $folder

    # creating a directory for each submission
    if [[ -d $submission ]]; then
        remarks="issue case #1"
        deducted_marks=$penalty_submission
        cp -r $submission ./output/submissions/checked
    else
        ext_exist=0
        for ext in ${zip_types[@]};
        do
            if [[ $zip_folder_ext == $ext ]]; then
                ext_exist=1
                break
            fi
        done
        if [[ $ext_exist -eq 1 ]]; then
            if [[ $zip_folder_ext == "zip" ]]; then
                unzip -q $submission -d ./output/submissions/checked
                folder=$(basename $submission .zip)
            elif [[ $zip_folder_ext == "tar.xz" ]]; then
                tar -xf $submission -C ./output/submissions/checked
            elif [[ $zip_folder_ext == "rar" ]]; then
                unrar x $submission ./output/submissions/checked
            fi
        elif [[ -f $submission ]]; then
            filename_with_extension=$(basename $submission)
            filename="${filename_with_extension%.*}"
            mkdir -p ./output/submissions/checked/$filename
            cp $submission ./output/submissions/checked/$filename

            folder=$filename
        else
            remarks="issue case #2"
            cp $submission ./output/submissions/issues
            echo "$(basename $submission),0,0,0,$remarks" >> ./output/submissions/marks.csv
            has_issue=1
            break
        fi
    fi
    # evaluation
    mapfile plagiarism < ./output/plagiarism.txt
    file_name_with_extension=$(ls ./output/submissions/checked/$folder)
    file_name="${file_name_with_extension%.*}"
    extension="${file_name_with_extension##*.}"

    if [[ $has_issue -eq 0 ]]; then
        if [[ $file_name != $folder  ]]; then
            remarks="issue case #4"
            deducted_marks=$penalty_submission
        fi
        extension_match=0
        for ext in ${programming_languages[@]};
        do 
            if [[ $extension == $ext ]]; then
                extension_match=1
                break
            fi
        done
        
        if [[ $extension_match -eq 0 ]]; then
            remarks="issue case #3"
            mv ./output/submissions/checked/$folder ./output/submissions/issues
            echo "$folder,0,0,0,$remarks" >> ./output/submissions/marks.csv
            has_issue=1
            break
        fi

        if [[ $extension == "py" ]]; then
            python3 ./output/submissions/checked/$folder/$file_name_with_extension > ./output/submissions/checked/$folder/$file_name"_output.txt"
        elif [[ $extension == "c" ]]; then
            gcc ./output/submissions/checked/$folder/$file_name_with_extension -o ./output/submissions/checked/$folder/$file_name
            ./output/submissions/checked/$folder/$file_name > ./output/submissions/checked/$folder/$file_name"_output.txt"
        elif [[ $extension == "cpp" ]]; then
            g++ ./output/submissions/checked/$folder/$file_name_with_extension -o ./output/submissions/checked/$folder/$file_name
            ./output/submissions/checked/$folder/$file_name > ./output/submissions/checked/$folder/$file_name"_output.txt"
        elif [[ $extension == "sh" ]]; then
            chmod +x ./output/submissions/checked/$folder/$file_name_with_extension
            ./output/submissions/checked/$folder/$file_name_with_extension > ./output/submissions/checked/$folder/$file_name"_output.txt"
        fi

        mapfile output < ./output/submissions/checked/$folder/$file_name"_output.txt"
        for line in "${expected_output[@]}";
        do
            if [[ ! " ${output[@]} " =~ " ${line} " ]]; then
                deducted_marks=$((deducted_marks+penalty_unmatched))
            fi
        done

        marks=$((total_marks-deducted_marks))
        total_marks_csv=$marks
        for id in ${plagiarism[@]};
        do 
            if [[ $folder == $id ]]; then
                echo plagiarism "$folder"
                total_marks_csv=-$penalty_plagiarism
                remarks="plagiarism detected"
            fi
        done
        echo "$folder,$marks,$deducted_marks,$total_marks_csv,$remarks" >> ./output/submissions/marks.csv
    fi
done