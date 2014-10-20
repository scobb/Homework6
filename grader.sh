#Name:Steve Cobb
#EID:scc2448

# IO filenames
filename='calculator.c'
result_file='result.csv'

# testcases
addcases=('1' '1 1' '-1 -1' '123 456' '12 34 56 78' '1000000 1000000')
addanswers=('1' '2' '-2' '579' '180' '2000000')
multcases=('1' '10 10' '100 100')
multanswers=('1' '100' '10000')
usage_word=('add' 'multiply' 'Usage' 'calculator')

# regex
eid='EID:([a-zA-z][a-zA-Z]*[0-9][0-9]*)'
main='[[:space:]]*int[[:space:]][[:space:]]*main'
commentregex='[[:space:]]*//.*'
return_statement='[[:space:]]*return[[:space:]]*0[[:space:]]*;'

#########################################################
check_usage()
# function to check that all required words are in arg $1
######################################################### 
{
	for word in ${usage_word[@]}; do
		if [[ $1 != *$word* ]]; then
			return 1
		fi
	done
	return 0
}

###########################################################
# main processing

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
			   # check line right before main decl to see if it's a comment
                           pre_main_flag=true
                       fi
                   fi
                   prev=$p
	       done < $dir/$file
                   
	       # compile
               gcc $dir/$filename -o$dir/calculator.o &>/dev/null
               if [[ $? != 0 ]]; then
		   # compile failed
                   grader_comments="${grader_comments}${prefix}compile fail"
		   prefix=';'
		   score=0
               else
		   # compile succeeded, continue tests
		   score=10
                   
		   ### run test cases ###
	   
                   ## usages cases ##
                   correct_usage=true
                   check_usage "$(./$dir/calculator.o)"
		   
		   if [[ $? != 0 ]]; then
		       correct_usage=false
		       let "score = score - 1"
		   fi
		   
		   check_usage "$(echo 10 -10 | ./$dir/calculator.o subtract)"
		   if [[ $? != 0 ]]; then
		       correct_usage=false
		       let "score = score - 1"
                   fi

		   # add appropriate comment if usage statement  wrong
		   if [[ $correct_usage = false ]]; then
      		       grader_comments="${grader_comments}${prefix}usage"
                       prefix=';'
                   fi

                   ## add cases ##
		   for i in "${!addcases[@]}"; do
                       answer=$(echo "${addcases[$i]}" | ./$dir/calculator.o add)
                       if [[ $answer != ${addanswers[$i]} ]]; then
                           let "score = score - 1"
                       fi
                   done

		   ## multiply cases ##
		   for i in "${!multcases[@]}"; do
                       answer=$(echo "${multcases[$i]}" | ./$dir/calculator.o multiply)
                       if [[ $answer != ${multanswers[$i]} ]]; then
		           let "score = score - 1"
	               fi
	           done
               fi
	       
	       # check for explicit return statement
	       if ! [[ `cat $dir/$file` =~ $return_statement ]]; then
	           let "score = score - 1"
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
        
