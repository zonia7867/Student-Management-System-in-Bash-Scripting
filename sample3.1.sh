#!/bin/bash

teacher_record_file="teacher_record.txt"
student_record_file="student.txt"

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG_CYAN='\033[46m'


#---------------MAIN MENU-----------------
#the main_menu function displays the name of the group members.
#it checks if the user is teacher or student, and then open login page
#if user is student then login would ask for rollno and password
#if user is teacher then login asks for teacher full name and password
main_menu() {
 	echo
    	echo
    	echo -e "${PURPLE}=========================================${NC}"
    	echo -e "${PURPLE}||                                     ||${NC}"
    	echo -e "${PURPLE}||    ${BLACK}${BG_CYAN}STUDENT MANAGEMENT SYSTEM (SMS)${NC}${PURPLE}  ||${NC}"
    	echo -e "${PURPLE}||                                     ||${NC}"
    	echo -e "${PURPLE}||       ${BLACK}${BG_CYAN}BY: Zonia Amer 23F-0801${NC}${PURPLE}       ||${NC}"
	echo -e "${PURPLE}||       ${BLACK}${BG_CYAN}   Abrar Fazal 23F-0619${NC}${PURPLE}       ||${NC}"
    	echo -e "${PURPLE}||                                     ||${NC}"
    	echo -e "${PURPLE}||           ${BLACK}${BG_CYAN}Section: BCS-4B${NC}${PURPLE}           ||${NC}"
    	echo -e "${PURPLE}||                                     ||${NC}"
    	echo -e "${PURPLE}=========================================${NC}"
        echo
	echo -e "${BLACK}${BG_CYAN}-------------MAIN MENU------------------${NC}"
	echo
	echo "1. Teacher"
	echo "2. Student"
	echo "3. Exit SMS"
	echo
	echo -e "${CYAN}Enter your choice${NC}"
	read userType

	case $userType in
	1)
		teacher_login;;
	2)
		student_login;;
	3)
		echo "Exiting SMS"
		exit 0;;
	4)
		echo -e "${RED}Enter a valid choice (1/2/3)${NC}"
		sleep 2
		main_menu;;

	esac
}

#---------------LOGIN TEACHER ------------------------
#teacher_login function asks for the teacher full name and password
#it will check if teacher credential match the one store in file.
#if yes the login the teacher
teacher_login() {
	echo -e "${BLACK}${BG_CYAN}------------ TEACHER LOGIN -------------${NC}"
	echo

	sys_t_name=$(head -n 1 $teacher_record_file | cut -d'|' -f1)
	sys_t_pass=$(head -n 1 $teacher_record_file | cut -d'|' -f2)

	echo "Enter full name: "
	read t_name
	echo "Enter password: "
	read t_password
	echo

	if [[ $t_name == $sys_t_name && $t_password == $sys_t_pass ]]; then
		echo -e "${GREEN}Teacher login successful :)${NC}"
		sleep 2
		teacher_menu
	else
		echo -e "${RED}Incorrect username or password${NC}"
		sleep 2
		main_menu
	fi
}

#-------------------LOGIN STUDENT------------------
#student_login function asks for student rollno and password
#irt checks if the student's record exist in student.txt file
#if yes then take the student to student menu
student_login() {
	echo
	echo -e "${BLACK}${BG_CYAN}------------ STUDENT LOGIN --------------${NC}"
	echo
	echo "Enter your Roll No: "
	read rollno
	echo "Enter password: "
	read s_password
	echo

	if grep -q "^$rollno|" $student_record_file; then
		sys_s_pass=$(grep "^$rollno|" $student_record_file | cut -d'|' -f3)
		if [[ $s_password == $sys_s_pass ]]; then
			echo -e "${GREEN}Student Login successful :)${NC}"
			sleep 2
			student_menu "$rollno"
		else
			echo -e "${RED}Incorrect password${NC}"
			sleep 2
			main_menu
		fi
	else
		echo -e "${RED}Student record not found${NC}"
		sleep 2
		main_menu
	fi
}

#------------------TEACHER MENU----------------
#provides a menu for the teacher to choose the task they want to perform
teacher_menu() {
	echo
	echo -e "${BLACK}${BG_CYAN}------------ TEACHER MENU --------------${NC}"
	echo
	echo "1. Add Student"
	echo "2. View Student details"
	echo "3. Update Student Information"
	echo "4. Delete Student"
	echo "5. Calculate Student Grade"
	echo "6. Calculate Student CGPA"
	echo "7. Generate Report"
	echo "8. Log out"
	echo -e "${CYAN}Enter your choice: ${NC}"
	read t_choice

	case $t_choice in
		1)
			add_student;;
		2)
			view_student;;
		3)
			update_student;;
		4)
			delete_student;;
		5)
			student_grade;;
		6)
			student_cgpa;;
		7)
			student_report;;
		8)
			echo "Logging out!"
			sleep 2
			main_menu;;
		*)
			echo -e "${RED}Enter a valid choice${NC}"
			sleep 2
			teacher_menu;;
	esac
}
#-------------ADD STUDENT-----------------
#allows teacher to add upto 20 students in record. Display error if students exceed 20
#asks the teacher for rollno, name, password and marks in each subject
#it then calcluate grades for each subject and overall cgpa
#the record is updated in student.txt
#if the file already contains the rollno, it gives error to prevent duplication
add_student() {
    echo
    echo -e "${BLACK}${BG_CYAN}------------ ADD STUDENT --------------${NC}"
    echo
    if [[ $(wc -l < "$student_record_file") -ge 20 ]]; then
        echo -e "${RED}Error: Cannot add more students. You can only add 20${NC}"
        sleep 2
        teacher_menu
    fi

    echo "Enter student Roll Number: "
    read rollno
    echo "Enter student name: "
    read s_name
    echo "Set student password: "
    read s_pass

    echo "Enter Operating System marks: "
    read os_marks
    echo "Enter Database System marks: "
    read db_marks
    echo "Enter Probability marks: "
    read prob_marks

    if grep -q "^$rollno|" "$student_record_file"; then
        echo "${RED}$rollno already exists${NC}"
        sleep 2
        teacher_menu
    fi

    os_grade=$(calculate_grade $os_marks)
    db_grade=$(calculate_grade $db_marks)
    prob_grade=$(calculate_grade $prob_marks)

    cgpa=$(calculate_cgpa_from_grades "$os_grade" "$db_grade" "$prob_grade")

    echo "$rollno|$s_name|$s_pass|$os_marks|$db_marks|$prob_marks|$os_grade|$db_grade|$prob_grade|$cgpa" >> "$student_record_file"
    echo -e "${GREEN}Student added :)${NC}"
    sleep 2
    teacher_menu
}

#----------------CALCULATE GRADE----------------
#calculate grade based on marks.
#fail below 45
calculate_grade() {
	marks=$1
	if [[ $marks -ge 95 ]]; then
		echo "A+"
	elif [[ $marks -ge 90 ]]; then
		echo "A"
	elif [[ $marks -ge 85 ]]; then
		echo "A-"
	elif [[ $marks -ge 80 ]]; then
		echo "B+"
	elif [[ $marks -ge 75 ]]; then
		echo "B"
	elif [[ $marks -ge 70 ]]; then
		echo "B-"
	elif [[ $marks -ge 65 ]]; then
		echo "C+"
	elif [[ $marks -ge 60 ]]; then
		echo "C"
	elif [[ $marks -ge 55 ]]; then
		echo "C-"
	elif [[ $marks -ge 50 ]]; then
		echo "D+"
	elif [[ $marks -ge 45 ]]; then 
		echo "D"
	else
		echo "F"
	fi
}

#----------------CALCULATE CGPA------------
#using grade from calculate grade function, using switch case, assign grades
#cgpa is assigned to each course and overall is calculated by taking average of those
calculate_gpa() {
	grade=$1
	case $grade in
		"A+")
			echo "4.0";;
		"A")
			echo "4.0";;
		"A-")
			echo "3.7";;
		"B+")
			echo "3.3";;
		"B")
			echo "3.0";;
		"B-")
			echo "2.8";;
		"C+")
			echo "2.5";;
		"C")
			echo "2.0";;
		"C-")
			echo "1.7";;
		"D+")
			echo "1.3";;
		"D")
			echo "1.0";;
		"F")
			echo "0.0";;
	esac
}

#--------------HELPER CGPA CALCULATOR-----------
#this function first calculate individual subject gpa grade point from grades
#it then calculates the overall cgpa by calculating average of all individual grade points
#assuming all courses are of same credit hours and hence have equal weight
calculate_cgpa_from_grades() {
    os_grade=$1
    db_grade=$2
    prob_grade=$3

    os_gpa=$(calculate_gpa $os_grade)
    db_gpa=$(calculate_gpa $db_grade)
    prob_gpa=$(calculate_gpa $prob_grade)
    cgpa=$(echo "scale=2; ($os_gpa + $db_gpa + $prob_gpa) / 3" | bc)
    echo "$cgpa"
}

#---------------STUDENT GRADE--------------
#This is option 5 from the teacher menu
#this function allows the teacher to directly calculate grades by assigned marks to a specific subject
#it also updates the gpa based on these new grades
#these grades and cgpa are updated for the student in the file
#grade is calculated and displayed
student_grade() {
    echo
    echo -e "${BLACK}${BG_CYAN}------------ CALCULATE GRADE --------------${NC}"
    echo
    echo "Enter Roll No of student: "
    read rollno

    if grep -q "^$rollno|" "$student_record_file"; then
        sys_student=$(grep "^$rollno|" "$student_record_file")
        IFS='|' read -r rollno s_name s_pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa <<< "$sys_student"

        echo -e "${CYAN}Select subject:${NC}"
        echo "1. Operating System"
        echo "2. Database System"
        echo "3. Probability"
        echo -e "${CYAN}Enter your choice: ${NC}"
        read subject_choice
        case $subject_choice in
            1)
                echo "Enter new Operating System marks: "
                read new_marks
                os_marks=$new_marks
                os_grade=$(calculate_grade $os_marks)
		echo "Grade in Operating System: " $os_grade
                ;;
            2)
                echo "Enter new Database System marks: "
                read new_marks
                db_marks=$new_marks
                db_grade=$(calculate_grade $db_marks)
		echo "Grade in Database System: " $db_grade
                ;;
            3)
                echo "Enter new Probability marks: "
                read new_marks
                prob_marks=$new_marks
                prob_grade=$(calculate_grade $prob_marks)
		echo "Grade in Probability: " $prob_grade
                ;;
            *)
                echo "${RED}Invalid choice${NC}"
                teacher_menu
                return
                ;;
        esac
        cgpa=$(calculate_cgpa_from_grades "$os_grade" "$db_grade" "$prob_grade")

        sed -i "/^$rollno|/d" "$student_record_file"
        echo "$rollno|$s_name|$s_pass|$os_marks|$db_marks|$prob_marks|$os_grade|$db_grade|$prob_grade|$cgpa" >> "$student_record_file"

        echo
        echo -e "${GREEN}Student Grade and CGPA updated in file!${NC}"
    else
        echo -e "${RED}Error: Student with roll number $rollno does not exist${NC}"
    fi
    echo
    echo -e "${YELLOW}Enter 't' to return to teacher menu${NC}"
    read key
    teacher_menu
}
#----------------- STUDENT CGPA ------------
#this is option 6 from teacher menu
#it allows teacher to view either marks and cgpa or grades and cgpa withour viewing other details of students
#it gives a meny to choose from
#teacher can calculate cgpa from marks/grades which will display marks/grades in all subjects and calculated cgpa
student_cgpa() {
    echo
    echo -e "${BLACK}${BG_CYAN}----------- CALCULATE CGPA --------------${NC}"
    echo
    echo "Enter Roll no of student: "
    read rollno

    if grep -q "^$rollno|" "$student_record_file"; then
        sys_student=$(grep "^$rollno|" "$student_record_file")
        IFS='|' read -r rollno s_name s_pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa <<< "$sys_student"

        echo "Current CGPA: $cgpa"
        echo
        echo "1. Calculate CGPA from grades"
        echo "2. Calculate CGPA from marks"
        echo -e "${CYAN}Enter your choice: ${NC}"
        read choice

        case $choice in
            1)
                echo "Current grades:"
                echo "Operating System: $os_grade"
                echo "Database System: $db_grade"
                echo "Probability: $prob_grade"
                cgpa=$(calculate_cgpa_from_grades "$os_grade" "$db_grade" "$prob_grade")
                echo "Calculated CGPA: $cgpa"

                sed -i "/^$rollno|/d" "$student_record_file"
                echo "$rollno|$s_name|$s_pass|$os_marks|$db_marks|$prob_marks|$os_grade|$db_grade|$prob_grade|$cgpa" >> "$student_record_file"
                ;;
            2)
                echo "Current marks:"
                echo "Operating System: $os_marks"
                echo "Database System: $db_marks"
                echo "Probability: $prob_marks"
                os_grade=$(calculate_grade $os_marks)
                db_grade=$(calculate_grade $db_marks)
                prob_grade=$(calculate_grade $prob_marks)
                cgpa=$(calculate_cgpa_from_grades "$os_grade" "$db_grade" "$prob_grade")
                echo "Calculated CGPA: $cgpa"

                sed -i "/^$rollno|/d" "$student_record_file"
                echo "$rollno|$s_name|$s_pass|$os_marks|$db_marks|$prob_marks|$os_grade|$db_grade|$prob_grade|$cgpa" >> "$student_record_file"
                ;;
            *)
                echo "${RED}Invalid choice${NC}"
                ;;
        esac
    else
        echo -e "${RED}Student with rollno $rollno not found${NC}"
    fi

    echo
    echo -e "${YELLOW}Enter 't' to return to teacher menu${NC}"
    read key
    teacher_menu
}

#------------------DELETE STUDENT--------------
#delete_student function allows the teacher to delete a student from record
#it inputs student rollno from teacher and deletes it from student record file
#display error message if there is no record with that rollno
delete_student() {
	echo -e "${BLACK}${BG_CYAN}------------ DELETE STUDENT --------------${NC}"
	echo
	echo "Enter the roll number of student you want to delete: "
	read rollno
	if grep -q "^$rollno|" "$student_record_file"; then
		sed -i "/^$rollno|/d" "$student_record_file"
		echo -e "${GREEN}Student with roll#: $rollno deleted!${NC}"
	else
		echo -e "${RED}ERROR: Sudent with this roll number does not exist${NC}"
	fi
	sleep 2
	teacher_menu
}

#--------------------VIEW STUDENT---------------
#it checks if the rollno exists in student.txt
#if it does then fetch the specific data from the file and display student details
#else display error message
view_student() {
    echo
    echo -e "${BLACK}${BG_CYAN}------------ VIEW STUDENT DETAILS --------------${NC}"
    echo
    echo "Enter Roll Number of the student: "
    read rollno

    if grep -q "^$rollno|" "$student_record_file"; then
        sys_student=$(grep "^$rollno|" "$student_record_file")
        IFS='|' read -r rollno s_name s_pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa <<< "$sys_student"
        echo
        echo -e "${CYAN}/STUDENT DETAILS/:${NC}"
        echo -e "${CYAN}----------------${NC}"
        echo "Roll Number: $rollno"
        echo "Name: $s_name"
        echo "Password: $s_pass"
        echo
        echo "Marks (Grade):"
        echo " -> Operating System: $os_marks ($os_grade)"
        echo " -> Database System: $db_marks ($db_grade)"
        echo " -> Probability: $prob_marks ($prob_grade)"
        echo
        echo "CGPA: $cgpa"
    else
        echo -e "${RED}Error: Student with Roll Number $rollno does not exist.${NC}"
    fi
    echo
    echo -e "${YELLOW}Enter 't' to return to the teacher menu${NC}"
    read key
    teacher_menu
}

#---------------UPDATE STUDENT---------------
#checks for the student in the file
#if rollno exist then fetch data
#ask the teacher for what to update
#based on th choosen option, it asks for the new data and update it in the file
update_student() {
    echo
    echo -e "${BLACK}${BG_CYAN}------------ UPDATE STUDENT INFORMATION --------------${NC}"
    echo
    echo "Enter Roll Number of student: "
    read rollno

    if grep -q "^$rollno|" "$student_record_file"; then
        sys_student=$(grep "^$rollno|" "$student_record_file")
        IFS='|' read -r rollno s_name s_pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa <<< "$sys_student"

        echo
        echo "1. Student Name"
        echo "2. Student Password"
        echo "3. Operating System Marks"
        echo "4. Database System Marks"
        echo "5. Probability Marks"
        echo -e "${CYAN}What do you want to update?${NC}"
        read choice

        case $choice in
            1)
                echo "Enter New Name: "
                read updated_name
                s_name="$updated_name"
                ;;
            2)
                echo "Enter New Password"
                read updated_password
                s_pass="$updated_password"
                ;;
            3)
                echo "Enter new Operating System marks: "
                read new_marks
                os_marks="$new_marks"
                os_grade=$(calculate_grade $os_marks)
                ;;
            4)
                echo "Enter new Database System marks: "
                read new_marks
                db_marks="$new_marks"
                db_grade=$(calculate_grade $db_marks)
                ;;
            5)
                echo "Enter new Probability marks: "
                read new_marks
                prob_marks="$new_marks"
                prob_grade=$(calculate_grade $prob_marks)
                ;;
            *)
                echo -e "${RED}No changes made. Enter valid choice${NC}"
                ;;
        esac

        if [[ $choice -ge 3 ]] && [[ $choice -le 5 ]]; then
            cgpa=$(calculate_cgpa_from_grades "$os_grade" "$db_grade" "$prob_grade")
        fi

        sed -i "/^$rollno|/d" "$student_record_file"
        echo "$rollno|$s_name|$s_pass|$os_marks|$db_marks|$prob_marks|$os_grade|$db_grade|$prob_grade|$cgpa" >> "$student_record_file"
        echo
        echo -e "${CYAN}Student Information Updated!${NC}"
    else
        echo -e "${RED}Error: Student with Roll Number $rollno not found${NC}"
    fi

    echo
    echo -e "${YELLOW}Enter 't' to return to teacher menu${NC}"
    read key
    teacher_menu
}

#------------------GENERATE REPORT------------------
#gives teacher choice to display students according to his preference
#pass threashold is set at cgpa=2.0
#1 will display all students saved in file in tabular form
#2 will display only passed student by checking against the threshold
#3 will display only fail student if any by checking against threshold
#4 will sort student in ascending order using inbuild sort function on cgpa
#5 will sort student in descending order according to cgpa using inbuild sort function
student_report() {
    echo
    echo -e "${BLACK}${BG_CYAN}------------ GENERATE STUDENT REPORT --------------${NC}"
    echo
    echo "1. List all students"
    echo "2. List passed students"
    echo "3. List failed students"
    echo "4. List students in ascending order"
    echo "5. List students in descending order"
    echo "6. Return to teacher menu"
    echo
    echo -e "${CYAN}Enter your choice:${NC}"
    read r_choice

    local passAt=2.0
    case $r_choice in
        1)
            echo
            echo -e"${CYAN}/DISPLAYING ALL STUDENTS/${NC}"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "Roll No" "Name" "Password" "OS" "DB" "Prob" "OS_G" "DB_G" "Prob_G" "CGPA"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            while IFS='|' read -r roll name pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa; do
                printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "$roll" "$name" "$pass" "$os_marks" "$db_marks" "$prob_marks" "$os_grade" "$db_grade" "$prob_grade" "$cgpa"
            done < "$student_record_file"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            ;;

        2)
            echo
            echo -e "${CYAN}/DISPLAYING PASSED STUDENTS/${NC}"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "Roll No" "Name" "Password" "OS" "DB" "Prob" "OS_G" "DB_G" "Prob_G" "CGPA"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            while IFS='|' read -r roll name pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa; do
                if (( $(echo "$cgpa >= $passAt" | bc -l) )); then
                    printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "$roll" "$name" "$pass" "$os_marks" "$db_marks" "$prob_marks" "$os_grade" "$db_grade" "$prob_grade" "$cgpa"
                fi
            done < "$student_record_file"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            ;;

        3)
            echo
            echo -e "${CYAN}/DISPLAYING FAILED STUDENTS/${NC}"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "Roll No" "Name" "Password" "OS" "DB" "Prob" "OS_G" "DB_G" "Prob_G" "CGPA"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            while IFS='|' read -r roll name pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa; do
                if (( $(echo "$cgpa < $passAt" | bc -l) )); then
                    printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "$roll" "$name" "$pass" "$os_marks" "$db_marks" "$prob_marks" "$os_grade" "$db_grade" "$prob_grade" "$cgpa"
                fi
            done < "$student_record_file"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            ;;

        4)
            echo
            echo -e "${CYAN}/DISPLAYING STUDENTS IN ASCENDING ORDER ACCORDING TO CGPA/${NC}"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "Roll No" "Name" "Password" "OS" "DB" "Prob" "OS_G" "DB_G" "Prob_G" "CGPA"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            sort -t'|' -k10,10n "$student_record_file" | while IFS='|' read -r roll name pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa; do
                printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "$roll" "$name" "$pass" "$os_marks" "$db_marks" "$prob_marks" "$os_grade" "$db_grade" "$prob_grade" "$cgpa"
            done
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            ;;

        5)
            echo
            echo -e "${CYAN}/DISPLAYING STUDENTS IN DESCENDING ORDER ACCORDING TO CGPA/${NC}"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "Roll No" "Name" "Password" "OS" "DB" "Prob" "OS_G" "DB_G" "Prob_G" "CGPA"
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            sort -t'|' -k10,10nr "$student_record_file" | while IFS='|' read -r roll name pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa; do
                printf "%-10s %-20s %-10s %-10s %-10s %-10s %-8s %-8s %-8s %-5s\n" "$roll" "$name" "$pass" "$os_marks" "$db_marks" "$prob_marks" "$os_grade" "$db_grade" "$prob_grade" "$cgpa"
            done
            echo -e "${CYAN}------------------------------------------------------------------------------------------------------------------------${NC}"
            ;;

        6)
            teacher_menu
            return
            ;;

        *)
            echo -e "${RED}Enter a valid choice (1-6)${NC}"
            ;;
    esac

    echo
    echo -e "${YELLOW}Enter 'c' to continue...${NC}"
    read key
    student_report
}
#-----------------STUDENT MENU-----------
#after student logins, display menu to choose from display grades or cgpa
#for invalid choice made, display error message in red color
student_menu() {
	rollno=$1
	echo
	echo -e "${BLACK}${BG_CYAN}------------ STUDENT MENU --------------${NC}"
	echo
	echo "1. View Grades"
	echo "2. View CGPA"
	echo "3. Log out"
	echo -e "${CYAN}Enter your choice: ${NC}"
	read s_choice

	case $s_choice in
		1)
			view_grades "$rollno"
			;;
		2)
			view_cgpa "$rollno"
			;;
		3)
			echo "Logging out!"
			sleep 2
			main_menu
			;;
		*)
			echo -e "${RED}Enter a valid choice${NC}"
			sleep 2
			student_menu "$rollno"
			;;
		esac
}
#--------------------VIEW GRADES-------------
#looks for the student in file, if student exist then retrived data from file and display
#else display error message
#upon user entering a key, take user back to student menu
view_grades() {
	rollno=$1
	echo
	echo -e "${BLACK}${BG_CYAN}------------ $rollno GRADES --------------${NC}"
	echo
	if grep -q "^$rollno|" "$student_record_file"; then
		IFS='|' read -r rollno s_name s_pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa <<< "$(grep "^$rollno|" "$student_record_file")"

		echo -e "${CYAN}/COURSE GRADES (MARKS)/${NC}"
		echo -e "${CYAN}--------------${NC}"
		echo "1. Operating System: $os_grade (Marks: $os_marks)"
		echo "2. Database System: $db_grade (Marks: $db_marks)"
		echo "3. Probability: $prob_grade (Marks: $prob_marks)"
	else
		echo -e "${RED} Student record not found!${NC}"
	fi
	echo
	echo -e "${YELLOW}Enter 's' to return to student menu${NC}"
	read key
	student_menu "$rollno"
}

#-----------------VIEW CGPA---------------
#checks for student in file
#if student exist, retrieves information from file and display it
#if student does not exist, display error message
#gives user the option to return to student menu upon entrying s
view_cgpa() {
	rollno=$1
	echo
	echo -e "${BLACK}{BG_CYAN}------------ $rollno CGPA --------------${NC}"
	echo
	if grep -q "^$rollno|" "$student_record_file"; then
        	IFS='|' read -r rollno s_name s_pass os_marks db_marks prob_marks os_grade db_grade prob_grade cgpa <<< "$(grep "^$rollno|" "$student_record_file")"

		echo -e "${CYAN}/OVERALL CGPA/${NC}"
		echo -e "${CYAN}--------------${NC}"
		echo "CGPA: $cgpa"
		echo

	else
		echo -e "${RED}Student record not found!${NC}"
	fi
	echo
	echo -e "${YELLOW}Enter 's' to return to the student menu${NC}"
	read key
	student_menu "$rollno"
}
#start program execution from main_menu
main_menu


