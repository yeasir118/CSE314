#!/usr/bin/bash

mapfile expected_output < ./demo_submissions/expected_output.txt

for submission in ./demo_submissions/*;
do
    # check if the submission is a zip file
    if [ ${submission: -4} == ".zip" ]; then
        unzip -q $submission -d ./extracted_files
    # check if the submission is a .tar.xz file
    elif [ ${submission: -7} == ".tar.xz" ]; then
        tar -xf $submission -C ./extracted_files
    # check if the submission is a .rar file
    elif [ ${submission: -4} == ".rar" ]; then
        unrar x $submission ./extracted_files
    elif [ -f $submission ]; then
        filename_with_extension=$(basename $submission)
        filename="${filename_with_extension%.*}"
        mkdir -p ./extracted_files/$filename
        cp $submission ./extracted_files/$filename
    fi
done

extensions=("py c cpp sh")
for folder in ./extracted_files/*;
do
    if [ -d $folder ]; then
        if [ $(ls $folder | wc -l) -eq 1 ]; then
            file_name_with_extension=$(ls $folder)
            file_name="${file_name_with_extension%.*}"
            extension="${file_name_with_extension##*.}"

            if [ $file_name == $(basename $folder) ]; then
                ext_match=0
                for ext in ${extensions[@]};
                do
                    if [ $extension == $ext ]; then
                        ext_match=1
                        break
                    fi
                done
                if [ $ext_match -eq 0 ]; then
                    echo $(basename $folder) " has wrong extension"
                else 
                    if [ $extension == "py" ]; then
                        # save the output of the python file in a file named $(file_name)_output.txt
                        python3 $folder/$file_name_with_extension > $folder/$file_name"_output.txt"
                    elif [ $extension == "c" ]; then
                        # compile the c file and save the output in a file named $(file_name)_output.txt
                        gcc $folder/$file_name_with_extension -o $folder/$file_name
                        $folder/$file_name > $folder/$file_name"_output.txt"
                    elif [ $extension == "cpp" ]; then
                        # compile the cpp file and save the output in a file named $(file_name)_output.txt
                        g++ $folder/$file_name_with_extension -o $folder/$file_name
                        $folder/$file_name > $folder/$file_name"_output.txt"
                    elif [ $extension == "sh" ]; then
                        # run the shell script and save the output in a file named $(file_name)_output.txt
                        chmod +x $folder/$file_name_with_extension
                        bash $folder/$file_name_with_extension > $folder/$file_name"_output.txt"
                    fi

                    mapfile output < $folder/$file_name"_output.txt"
                    # compare output with expected_output to check if lines present in expected_output are present in output
                    for line in "${expected_output[@]}";
                    do
                        if [[ ! " ${output[@]} " =~ " ${line} " ]]; then
                            echo $(basename $folder) " has output mismatch"
                            break
                        fi
                    done
                fi 
            else
                echo $(basename $folder) " has name mismatch"
            fi
        fi
    fi
done