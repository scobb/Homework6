#Name:Steve Cobb
#EID:scc2448

# variables for use in grading
filename='calculator.c'
eid='EID:([a-zA-z][a-zA-Z]*[0-9][0-9]*)'
addcases=('1' '1 1' '-1 -1' '123 456' '12 34 56 78' '1000000 1000000')
addanswers=('1' '2' '-2' '579' '180' '2000000')
multcases=('1' '10 10' '100 100')
multanswers=('1' '100' '10000')
main='[[:space:]]*int[[:space:]][[:space:]]*main'
commentregex='[[:space:]]*//.*'
usage_word=('add' 'multiply' 'Usage' 'calculator')
return_statement='[[:space:]]*return[[:space:]]*0[[:space:]]*;'
result_file='result.csv'

check_usage()
# function to check that all required words are in arg $1 
{
	for word in ${usage_word[@]}; do
		if [[ $1 != *$word* ]]; then
			return 1
		fi
	done
	return 0
}

# ensure results file is present and empty
rm $result_file &>/dev/null
touch $result_file

for dir in $(ls); do
    if [[ -d "$dir" ]]; then
        # found a directory -- inspect
        for file in $(ls $dir); do
           if [[ $file = $filename ]]; then

	       # reset individual report variables
	       grader_comments=''
	       prefix=''
	       this_eid=''

	       # find EID using regex
               if [[ `cat $dir/$file` =~ $eid ]]; then
                   this_eid="${BASH_REMATCH[1]}"
	       fi
               if [[ -z $this_eid ]]; then
                   resp=$dir
		   grader_comments="${grader_comments}${prefix}missing eid"
		   prefix=';'
	       else
                   resp=$this_eid
               fi
               
 	       # comment check
	       comments=0
	       pre_main_flag=false
	       while read p; do
                   if [[ $p =~ $commentregex ]]; then
                       let "comments = comments + 1"
                   fi
		   if [[ $p =~ $main ]]; then
                       if [[ $prev =~ $commentregex ]]; then
                           pre_main_flag=true
                       fi
                   fi
                   prev=$p
	       done < $dir/$file
                   
	       # compile
               gcc $dir/$filename -o$dir/calculator.o &>/dev/null
               if [[ $? != 0 ]]; then
		   # compile check
                   grader_comments="${grader_comments}${prefix}compile fail"
		   prefix=';'
		   score=0
               else
		   score=10
                   
		   # run test cases
	           if ! [[ `cat $dir/$file` =~ $return_statement ]]; then
		       let "score = score - 1"
	           fi	
		   
                   # usages cases
                   correct_usage=true
                   test_usage="$(./$dir/calculator.o)"
		   check_usage "$test_usage"
		   
		   if [[ $? != 0 ]]; then
		       correct_usage=false
		   else
		       test_usage="$(echo 10 -10 | ./$dir/calculator.o subtract)"
		       check_usage "$test_usage"
		       if [[ $? != 0 ]]; then
		           correct_usage=false
		       fi
                   fi
		   if [[ $correct_usage = false ]]; then
      		       grader_comments="${grader_comments}${prefix}usage"
                       prefix=';'
                   fi


                   # add cases
		   for i in "${!addcases[@]}"; do
                       answer=$(echo "${addcases[$i]}" | ./$dir/calculator.o add)
                       if [[ $answer != ${addanswers[$i]} ]]; then
                           let "score = score - 1"
                       fi
                   done

		   # mult cases
		   for i in "${!multcases[@]}"; do
                       answer=$(echo "${multcases[$i]}" | ./$dir/calculator.o multiply)
                       if [[ $answer != ${multanswers[$i]} ]]; then
		           let "score = score - 1"
	               fi
	           done
               fi

	       # add score to output
               resp=$resp,$score

               # add style check to output
               if [[ $comments > 2 ]] && [[ $pre_main_flag = true ]]; then
                   resp=$resp,ok
               else
                   resp=$resp,notok
               fi

               # add comments to output
	       resp=$resp,$grader_comments

               # append to results file
	       echo $resp>>${result_file}
	    fi
        done
    fi
done
        
